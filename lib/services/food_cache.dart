import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../models/food_item.dart';
import 'database.dart';

/// On-device cache of Open Food Facts answers, backed by the drift database.
///
/// Two jobs. First, a search someone ran last week comes back instantly on
/// the tube with no signal, instead of as an error. Second, a slow mirror can
/// be papered over: the screen shows the cached list while the live one is
/// still loading. Rows older than [ttl] are treated as misses and pruned —
/// products change, and a month is long enough for a reformulation to land.
///
/// Only hits are cached. An empty search or an unknown barcode is cheap to
/// ask again, and caching it would hide a product added tomorrow.
class FoodCache {
  FoodCache(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  static const ttl = Duration(days: 30);

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Case, surrounding whitespace and repeated spaces do not make a different
  /// search — "Banana ", "banana" and "BANANA" share one row.
  static String normalise(String query) =>
      query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  bool _fresh(DateTime fetchedAt) => _clock().difference(fetchedAt) < ttl;

  /// Cached results for [query], or null on a miss or an expired row.
  Future<List<FoodItem>?> getSearch(String query) async {
    final key = normalise(query);
    if (key.isEmpty) return null;
    final row = await _db.searchCacheFor(key);
    if (row == null) return null;
    if (!_fresh(row.fetchedAt)) {
      await prune();
      return null;
    }
    return _decode(row.resultsJson);
  }

  Future<void> putSearch(String query, List<FoodItem> items) async {
    final key = normalise(query);
    if (key.isEmpty || items.isEmpty) return;
    await _db.upsertSearchCache(SearchCacheEntriesCompanion(
      normalisedQuery: Value(key),
      resultsJson: Value(jsonEncode(items.map((i) => i.toJson()).toList())),
      fetchedAt: Value(_clock()),
    ));
  }

  /// Cached product for [barcode], or null on a miss or an expired row.
  Future<FoodItem?> getBarcode(String barcode) async {
    final row = await _db.barcodeCacheFor(barcode.trim());
    if (row == null) return null;
    if (!_fresh(row.fetchedAt)) {
      await prune();
      return null;
    }
    try {
      return FoodItem.fromJson(
          jsonDecode(row.productJson) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('FoodCache.getBarcode: corrupt row for $barcode ($e)');
      return null;
    }
  }

  Future<void> putBarcode(String barcode, FoodItem item) async {
    await _db.upsertBarcodeCache(BarcodeCacheEntriesCompanion(
      barcode: Value(barcode.trim()),
      productJson: Value(jsonEncode(item.toJson())),
      fetchedAt: Value(_clock()),
    ));
  }

  /// Deletes every row past its TTL. Returns how many went.
  Future<int> prune() => _db.pruneCacheBefore(_clock().subtract(ttl));

  List<FoodItem>? _decode(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .cast<Map<String, dynamic>>()
          .map(FoodItem.fromJson)
          .toList();
    } catch (e) {
      debugPrint('FoodCache: corrupt search row ($e)');
      return null;
    }
  }
}
