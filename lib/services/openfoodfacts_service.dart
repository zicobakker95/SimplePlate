import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/food_item.dart';

/// Thrown when a request to Open Food Facts fails due to network issues,
/// timeouts, or an unexpected server response — as opposed to a normal
/// "no results"/"product not found" outcome.
class OpenFoodFactsException implements Exception {
  OpenFoodFactsException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Fetches food data from the Open Food Facts API.
///
/// Text search tries, in order, until one returns something:
///
///  1. the country subdomain for the device locale
///     (`nl.openfoodfacts.org` for a Dutch phone) — products sold locally
///     rank first there, which is where "banana" stops meaning a yoghurt;
///  2. `world.openfoodfacts.net`, the CGI mirror the app has always used;
///  3. `world.openfoodfacts.org/cgi/search.pl`.
///
/// Every request has an 8-second timeout. An endpoint that errors is skipped,
/// one that answers with nothing is trusted only once the others have also
/// answered with nothing — so an empty list here really is a miss, and a
/// thrown [OpenFoodFactsException] really is "could not check".
///
/// Barcode lookup uses world.openfoodfacts.org (v2 — reliable).
class OpenFoodFactsService {
  OpenFoodFactsService({
    http.Client? client,
    this.timeout = const Duration(seconds: 8),
    this.totalBudget = const Duration(seconds: 16),
  }) : _client = client ?? http.Client();

  static final OpenFoodFactsService instance = OpenFoodFactsService();

  static const _barcodeBase = 'https://world.openfoodfacts.org';
  static const _userAgent =
      'SimplePlate/1.1 (com.zibaentertainment.simple_plate; contact@zibaentertainment.com)';
  static const _searchFields =
      'code,product_name,brands,nutriments,image_front_url,serving_quantity,serving_size';

  final http.Client _client;

  /// Per-request timeout.
  final Duration timeout;

  /// Ceiling on the whole fallback chain, so three slow mirrors never add up
  /// to half a minute of spinner.
  final Duration totalBudget;

  // ── Locale → country subdomain ─────────────────────────────────────────────

  /// Open Food Facts uses ISO country codes as subdomains, except where it
  /// doesn't. Only the exceptions live here.
  static const _countryOverrides = <String, String>{'GB': 'uk'};

  /// A phone that reports a language but no region still usually belongs
  /// somewhere. These are the app's shipped locales; anything else is
  /// "world". Portuguese goes to Brazil because that is the market the app
  /// is listed in.
  static const _languageDefaults = <String, String>{
    'nl': 'nl',
    'de': 'de',
    'fr': 'fr',
    'es': 'es',
    'it': 'it',
    'ja': 'jp',
    'pt': 'br',
  };

  /// The Open Food Facts subdomain to try first for [locale]: `nl` for
  /// `nl_NL`, `uk` for `en_GB`, `world` when there is nothing to go on.
  static String countrySubdomain(Locale? locale) {
    if (locale == null) return 'world';
    final country = locale.countryCode?.toUpperCase();
    if (country != null && RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
      return _countryOverrides[country] ?? country.toLowerCase();
    }
    return _languageDefaults[locale.languageCode.toLowerCase()] ?? 'world';
  }

  /// The search endpoints for [query], in the order they are tried.
  @visibleForTesting
  static List<Uri> searchUris(String query,
      {Locale? locale, int poolSize = 50}) {
    final params = {
      'search_terms': query,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '$poolSize',
      'fields': _searchFields,
    };
    final country = countrySubdomain(locale);
    return [
      if (country != 'world')
        Uri.https('$country.openfoodfacts.org', '/cgi/search.pl', params),
      Uri.https('world.openfoodfacts.net', '/cgi/search.pl', params),
      Uri.https('world.openfoodfacts.org', '/cgi/search.pl', params),
    ];
  }

  // ── Barcode ────────────────────────────────────────────────────────────────

  /// Look up a product by barcode. Returns null if genuinely not found.
  /// Throws [OpenFoodFactsException] on network/timeout/server errors so
  /// callers can tell "not found" apart from "couldn't check".
  Future<FoodItem?> fetchByBarcode(String barcode) async {
    final uri = Uri.parse(
        '$_barcodeBase/api/v2/product/$barcode?fields=product_name,brands,nutriments,image_front_url,serving_quantity,serving_size');
    try {
      final resp = await _get(uri, timeout);
      if (resp.statusCode != 200) {
        throw OpenFoodFactsException(
            'Open Food Facts returned an error (HTTP ${resp.statusCode}).');
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (body['status'] != 1) return null;
      return parseProduct(barcode, body['product'] as Map<String, dynamic>);
    } on OpenFoodFactsException {
      rethrow;
    } catch (e) {
      throw _wrap(e);
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  /// Search food by text query. Returns up to [limit] results (possibly empty
  /// if there are genuinely no matches). Throws [OpenFoodFactsException] only
  /// when every endpoint failed.
  ///
  /// Open Food Facts' raw search ranks by popularity, so a query like "banana"
  /// surfaces branded banana-flavoured products (yoghurts, drinks) above the
  /// plain fruit. We fetch a larger candidate pool and re-rank client-side —
  /// see [rankResults].
  Future<List<FoodItem>> search(String query,
      {int limit = 25, Locale? locale}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    // Pull a bigger pool than we show so the re-rank has room to work.
    final poolSize = (limit * 3).clamp(30, 100);

    final started = Stopwatch()..start();
    OpenFoodFactsException? lastError;
    var answered = false;
    for (final uri in searchUris(q, locale: locale, poolSize: poolSize)) {
      final remaining = totalBudget - started.elapsed;
      if (remaining <= Duration.zero) break;
      final perRequest = remaining < timeout ? remaining : timeout;
      try {
        final items = await _searchAt(uri, perRequest);
        answered = true;
        final ranked = rankResults(items, q);
        if (ranked.isNotEmpty) return ranked.take(limit).toList();
      } on OpenFoodFactsException catch (e) {
        lastError = e;
        debugPrint('OpenFoodFactsService: ${uri.host} failed: $e');
      }
    }
    if (answered) return const [];
    throw lastError ??
        OpenFoodFactsException(
            'Request timed out. Check your connection and try again.');
  }

  Future<List<FoodItem>> _searchAt(Uri uri, Duration perRequest) async {
    try {
      final resp = await _get(uri, perRequest);
      if (resp.statusCode != 200) {
        throw OpenFoodFactsException(
            'Open Food Facts returned an error (HTTP ${resp.statusCode}).');
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final products = (body['products'] as List<dynamic>?) ?? const [];
      return products
          .cast<Map<String, dynamic>>()
          .map((p) => parseProduct((p['code'] as String?) ?? '', p))
          .where((item) => item.name.isNotEmpty && item.name != 'Unknown')
          .toList();
    } on OpenFoodFactsException {
      rethrow;
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<http.Response> _get(Uri uri, Duration limit) =>
      _client.get(uri, headers: {'User-Agent': _userAgent}).timeout(limit);

  OpenFoodFactsException _wrap(Object e) {
    if (e is TimeoutException) {
      return OpenFoodFactsException(
          'Request timed out. Check your connection and try again.');
    }
    if (e is SocketException) {
      return OpenFoodFactsException('No internet connection.');
    }
    return OpenFoodFactsException('Could not reach Open Food Facts ($e).');
  }

  // ── Ranking ────────────────────────────────────────────────────────────────

  /// Re-ranks [items] for [query]: exact name matches first, then products
  /// with complete nutrition, then everything else by how well the name
  /// matches. Anything without a calorie figure is dropped — it cannot be
  /// logged as anything but zero, and a zero-calorie "Chocolate" in the list
  /// is exactly the kind of result that gets an app called broken.
  ///
  /// The sort is stable, so ties keep Open Food Facts' popularity order.
  static List<FoodItem> rankResults(List<FoodItem> items, String query) {
    final usable = items.where((i) => i.caloriesPer100 > 0).toList();
    usable.sort((a, b) => relevance(b, query).compareTo(relevance(a, query)));
    return usable;
  }

  /// Heuristic relevance score for [item] against [query]. Higher is better.
  /// Rewards exact / prefix / whole-word name matches, complete nutrition, and
  /// simple generic foods (few words, no brand); a plain "Banana" beats
  /// "Banana Flavoured Yoghurt Drink".
  @visibleForTesting
  static int relevance(FoodItem item, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return 0;
    final name = item.name.toLowerCase().trim();
    final words = name
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((w) => w.isNotEmpty)
        .toList();

    var score = 0;
    if (name == q) {
      score += 1000; // exact product name
    } else if (name.startsWith('$q ') || name.startsWith('$q,')) {
      score += 600; // name begins with the query
    } else if (words.contains(q)) {
      score += 350; // query is a whole word in the name
    } else if (name.contains(q)) {
      score += 100; // query appears somewhere (e.g. inside another word)
    }

    // All four macros stated: the entry will move every bar, not just the
    // ring. Worth more than the gap between a prefix and a whole-word match
    // (600 vs 350), so "Grilled chicken" with everything stated beats
    // "Chicken breast fillet" with only an energy value — but never an
    // exact name.
    if (item.hasCompleteNutrition) score += 300;

    // Prefer simple, generic names — fewer words usually means the raw food.
    score -= (words.length - 1).clamp(0, 12) * 8;
    // Generic foods often have no brand.
    if (item.brand.isEmpty) score += 25;

    return score;
  }

  // ── Parsing ────────────────────────────────────────────────────────────────

  /// A [FoodItem] from an Open Food Facts product map.
  @visibleForTesting
  static FoodItem parseProduct(String id, Map<String, dynamic> p) {
    final nutriments = (p['nutriments'] as Map<String, dynamic>?) ?? const {};

    double numVal(String key) {
      final v = nutriments[key];
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    bool stated(String key) {
      final v = nutriments[key];
      if (v == null) return false;
      return v is num || double.tryParse(v.toString()) != null;
    }

    return FoodItem(
      id: id.isEmpty ? 'off-${p.hashCode}' : id,
      name: (p['product_name'] as String?)?.trim() ?? 'Unknown',
      brand: (p['brands'] as String?)?.trim() ?? '',
      caloriesPer100: numVal('energy-kcal_100g'),
      proteinPer100: numVal('proteins_100g'),
      carbsPer100: numVal('carbohydrates_100g'),
      fatPer100: numVal('fat_100g'),
      imageUrl: p['image_front_url'] as String?,
      servingSizeGrams: servingGramsFromProduct(p),
      hasCompleteNutrition: stated('energy-kcal_100g') &&
          stated('proteins_100g') &&
          stated('carbohydrates_100g') &&
          stated('fat_100g'),
    );
  }

  /// Grams in one serving, or null when the product does not say.
  ///
  /// Open Food Facts is crowd-sourced and this field is messy: it arrives as a
  /// number, as a numeric string, or not at all, and `serving_size` is free
  /// text like "30 g", "1 cup (240 ml)" or "2 biscuits". Only a value that
  /// parses to a positive number of grams is trusted — a guess here would put
  /// a wrong serving count in front of someone counting calories.
  @visibleForTesting
  static double? servingGramsFromProduct(Map<String, dynamic> p) {
    final q = p['serving_quantity'];
    double? grams;
    if (q is num) {
      grams = q.toDouble();
    } else if (q is String) {
      grams = double.tryParse(q.trim());
    }

    // Fall back to the leading number of the free-text field, but only when it
    // is stated in grams. "1 cup (240 ml)" is not something to convert.
    if (grams == null) {
      final raw = (p['serving_size'] as String?)?.trim().toLowerCase();
      if (raw != null && raw.isNotEmpty) {
        // Accepts "30 g", "30g", "30 grams"; rejects "250 ml",
        // "2 biscuits" and "3 gallon" - a bare \s*g takes the 3
        // out of that last one.
        final m = RegExp(
                r'^([0-9]+(?:[.,][0-9]+)?)\s*(?:g|gr|grams?|grammes?)(?![a-z])')
            .firstMatch(raw);
        if (m != null) {
          grams = double.tryParse(m.group(1)!.replaceAll(',', '.'));
        }
      }
    }

    if (grams == null || grams <= 0) return null;
    // Sanity bound. A "serving" of 5 kg is bad data, and dividing by it would
    // render every amount as 0.0 servings.
    if (grams > 2000) return null;
    return grams;
  }
}
