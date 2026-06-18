import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/food_item.dart';

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

  /// Look up a product by barcode. Returns null if not found.
  Future<FoodItem?> fetchByBarcode(String barcode) async {
    final uri = Uri.parse(
        '$_barcodeBase/api/v2/product/$barcode?fields=product_name,brands,nutriments,image_front_url');
    try {
      final resp = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (body['status'] != 1) return null;
      return _parseProduct(barcode, body['product'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Search food by text query. Returns up to [limit] results.
  Future<List<FoodItem>> search(String query, {int limit = 25}) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
        '$_searchBase/cgi/search.pl?search_terms=$encoded&search_simple=1&action=process&json=1&page_size=$limit&fields=code,product_name,brands,nutriments,image_front_url');
    try {
      final resp = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) return const [];
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final products = (body['products'] as List<dynamic>?) ?? const [];
      return products
          .cast<Map<String, dynamic>>()
          .map((p) => _parseProduct((p['code'] as String?) ?? '', p))
          // Only require a non-empty name; calorie data may be missing for many valid items
          .where((item) => item.name.isNotEmpty && item.name != 'Unknown')
          .toList();
    } catch (_) {
      return const [];
    }
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
