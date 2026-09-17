import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../models/food_item.dart';
import 'database.dart';
import 'food_cache.dart';
import 'openfoodfacts_service.dart';

/// One answer from [FoodSearchService.search]. A search can produce two: a
/// cached list first, then the live one.
class FoodSearchResult {
  const FoodSearchResult(this.items,
      {this.fromCache = false, this.offline = false});

  final List<FoodItem> items;

  /// Served from the on-device cache rather than Open Food Facts.
  final bool fromCache;

  /// The live request failed and this is all there is. Only ever true
  /// together with [fromCache].
  final bool offline;
}

/// Food search as the screen sees it: cache and Open Food Facts combined.
///
/// The rule is that the user is never left looking at nothing that could have
/// been something. A live search is always started; if it has not answered
/// within [cacheAfter] and the cache has this query, the cached list is shown
/// while it finishes. If it fails, the cached list stands. Only with no cache
/// at all does a failure reach the screen as an error — and the screen then
/// offers a retry, never a blank.
class FoodSearchService {
  FoodSearchService({
    OpenFoodFactsService? api,
    FoodCache? cache,
    this.cacheAfter = const Duration(milliseconds: 1500),
  })  : _api = api ?? OpenFoodFactsService.instance,
        _cacheOverride = cache;

  static final FoodSearchService instance = FoodSearchService();

  final OpenFoodFactsService _api;
  final FoodCache? _cacheOverride;
  FoodCache? _cache;

  /// How long to give the live request before falling back to a cached
  /// answer. Short enough that a slow mirror feels like a fast one; long
  /// enough that a normal answer arrives first and the list never flickers.
  final Duration cacheAfter;

  FoodCache get cache => _cache ??= _cacheOverride ?? FoodCache(AppDatabase());

  /// Searches [query]. Emits at most two results (cached, then live) or one
  /// error when neither exists. The stream closes after the live outcome.
  Stream<FoodSearchResult> search(String query, {Locale? locale}) async* {
    final q = query.trim();
    if (q.isEmpty) {
      yield const FoodSearchResult([]);
      return;
    }

    // The cache read is local and fast; the live request starts alongside it.
    final live = _api.search(q, locale: locale);
    // A failure is handled below, after the cache race, never left unobserved.
    live.ignore();
    final cached = await _safeCached(q);

    var liveDone = false;
    List<FoodItem>? liveItems;
    Object? liveError;
    final settled = live.then((items) {
      liveDone = true;
      liveItems = items;
    }, onError: (Object e) {
      liveDone = true;
      liveError = e;
    });

    if (cached != null) {
      await Future.any([settled, Future<void>.delayed(cacheAfter)]);
      if (!liveDone) yield FoodSearchResult(cached, fromCache: true);
    }

    await settled;
    if (liveError == null) {
      final items = liveItems ?? const <FoodItem>[];
      if (items.isNotEmpty) await _safePut(q, items);
      yield FoodSearchResult(items);
      return;
    }
    if (cached != null) {
      yield FoodSearchResult(cached, fromCache: true, offline: true);
      return;
    }
    throw liveError!;
  }

  /// Barcode lookup, cache first: a product scanned in the last month comes
  /// back without a network round-trip. Throws [OpenFoodFactsException] when
  /// the product is unknown locally and Open Food Facts could not be reached.
  Future<FoodItem?> lookupBarcode(String barcode) async {
    final code = barcode.trim();
    if (code.isEmpty) return null;
    FoodItem? hit;
    try {
      hit = await cache.getBarcode(code);
    } catch (e) {
      debugPrint('FoodSearchService: barcode cache read failed ($e)');
    }
    if (hit != null) return hit;

    final item = await _api.fetchByBarcode(code);
    if (item != null) {
      try {
        await cache.putBarcode(code, item);
      } catch (e) {
        debugPrint('FoodSearchService: barcode cache write failed ($e)');
      }
    }
    return item;
  }

  Future<List<FoodItem>?> _safeCached(String q) async {
    try {
      return await cache.getSearch(q);
    } catch (e) {
      // A broken cache must never break search; it is only ever a bonus.
      debugPrint('FoodSearchService: cache read failed ($e)');
      return null;
    }
  }

  Future<void> _safePut(String q, List<FoodItem> items) async {
    try {
      await cache.putSearch(q, items);
    } catch (e) {
      debugPrint('FoodSearchService: cache write failed ($e)');
    }
  }
}
