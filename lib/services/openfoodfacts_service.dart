import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
/// Search uses world.openfoodfacts.net (CGI endpoint — stable).
/// Barcode lookup uses world.openfoodfacts.org (v2 — reliable).
class OpenFoodFactsService {
  static const _searchBase = 'https://world.openfoodfacts.net';
  static const _barcodeBase = 'https://world.openfoodfacts.org';
  static const _userAgent =
      'SimplePlate/1.0 (com.zibaentertainment.simple_plate; contact@zibaentertainment.com)';

  static final OpenFoodFactsService instance = OpenFoodFactsService._();
  OpenFoodFactsService._();

  /// Look up a product by barcode. Returns null if genuinely not found.
  /// Throws [OpenFoodFactsException] on network/timeout/server errors so
  /// callers can tell "not found" apart from "couldn't check".
  Future<FoodItem?> fetchByBarcode(String barcode) async {
    final uri = Uri.parse(
        '$_barcodeBase/api/v2/product/$barcode?fields=product_name,brands,nutriments,image_front_url');
    try {
      final resp = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        throw OpenFoodFactsException(
            'Open Food Facts returned an error (HTTP ${resp.statusCode}).');
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (body['status'] != 1) return null;
      return _parseProduct(barcode, body['product'] as Map<String, dynamic>);
    } on OpenFoodFactsException {
      rethrow;
    } on TimeoutException {
      throw OpenFoodFactsException('Request timed out. Check your connection and try again.');
    } on SocketException {
      throw OpenFoodFactsException('No internet connection.');
    } catch (e) {
      throw OpenFoodFactsException('Could not reach Open Food Facts ($e).');
    }
  }

  /// Search food by text query. Returns up to [limit] results (possibly empty
  /// if there are genuinely no matches). Throws [OpenFoodFactsException] on
  /// network/timeout/server errors.
  ///
  /// Open Food Facts' raw search ranks by popularity, so a query like "banana"
  /// surfaces branded banana-flavoured products (yoghurts, drinks) above the
  /// plain fruit. We fetch a larger candidate pool and re-rank client-side so
  /// exact / whole-word name matches and simple generic foods come first.
  Future<List<FoodItem>> search(String query, {int limit = 25}) async {
    final q = query.trim();
    // Pull a bigger pool than we show so the re-rank has room to work.
    final poolSize = (limit * 3).clamp(30, 100);
    final encoded = Uri.encodeComponent(q);
    final uri = Uri.parse(
        '$_searchBase/cgi/search.pl?search_terms=$encoded&search_simple=1&action=process&json=1&page_size=$poolSize&fields=code,product_name,brands,nutriments,image_front_url');
    try {
      final resp = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) {
        throw OpenFoodFactsException(
            'Open Food Facts returned an error (HTTP ${resp.statusCode}).');
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final products = (body['products'] as List<dynamic>?) ?? const [];
      final items = products
          .cast<Map<String, dynamic>>()
          .map((p) => _parseProduct((p['code'] as String?) ?? '', p))
          // Only require a non-empty name; calorie data may be missing for many valid items
          .where((item) => item.name.isNotEmpty && item.name != 'Unknown')
          .toList();
      // Stable sort (Dart List.sort is stable) → ties keep OFF's popularity order.
      items.sort((a, b) => _relevance(b, q).compareTo(_relevance(a, q)));
      return items.take(limit).toList();
    } on OpenFoodFactsException {
      rethrow;
    } on TimeoutException {
      throw OpenFoodFactsException('Request timed out. Check your connection and try again.');
    } on SocketException {
      throw OpenFoodFactsException('No internet connection.');
    } catch (e) {
      throw OpenFoodFactsException('Could not reach Open Food Facts ($e).');
    }
  }

  /// Heuristic relevance score for re-ranking search results against [query].
  /// Higher is better. Rewards exact / prefix / whole-word name matches and
  /// simple generic foods (few words, no brand); a plain "Banana" beats
  /// "Banana Flavoured Yoghurt Drink".
  int _relevance(FoodItem item, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return 0;
    final name = item.name.toLowerCase().trim();
    final words = name.split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
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

    // Prefer simple, generic names — fewer words usually means the raw food.
    score -= (words.length - 1).clamp(0, 12) * 8;
    // Generic foods often have no brand.
    if (item.brand.isEmpty) score += 25;
    // Prefer items that actually carry calorie data (usable when logged).
    if (item.caloriesPer100 > 0) score += 30;

    return score;
  }

  FoodItem _parseProduct(String id, Map<String, dynamic> p) {
    final nutriments = (p['nutriments'] as Map<String, dynamic>?) ?? const {};

    double numVal(String key) {
      final v = nutriments[key];
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
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
    );
  }
}
