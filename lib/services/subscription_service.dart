import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages monthly/yearly premium subscriptions via in_app_purchase.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();
  static final instance = SubscriptionService._();

  // ── Product IDs (must match exactly in both stores) ────────────────────────
  static const kMonthlyId = 'simple_plate.premium_monthly';
  static const kYearlyId  = 'simple_plate.premium_yearly';

  static const _kCacheKey = 'sp.premium.active';

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isPremium = false;
  bool _storeAvailable = false;
  bool _purchasing = false;
  bool _loadingProducts = true;
  List<ProductDetails> _products = const [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  bool get isPremium => _isPremium;
  bool get storeAvailable => _storeAvailable;
  bool get purchasing => _purchasing;
  bool get loadingProducts => _loadingProducts;
  List<ProductDetails> get products => List.unmodifiable(_products);

  ProductDetails? get monthly => _byId(kMonthlyId);
  ProductDetails? get yearly => _byId(kYearlyId);

  ProductDetails? _byId(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_kCacheKey) ?? false;
    notifyListeners();

    _storeAvailable = await InAppPurchase.instance.isAvailable();
    if (!_storeAvailable) {
      _loadingProducts = false;
      notifyListeners();
      return;
    }

    _purchaseSub = InAppPurchase.instance.purchaseStream
        .listen(_onPurchaseUpdates, onError: (_) {});

    await _loadProducts();
    // Silently restore in case user reinstalled / switched device
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> _loadProducts() async {
    final response = await InAppPurchase.instance
        .queryProductDetails({kMonthlyId, kYearlyId});
    _products = List.of(response.productDetails)
      ..sort((a, b) => a.id == kMonthlyId ? -1 : 1); // monthly first
    _loadingProducts = false;
    notifyListeners();
  }

  // ── Purchase ───────────────────────────────────────────────────────────────
  Future<void> purchase(ProductDetails product) async {
    if (_purchasing) return;
    _purchasing = true;
    notifyListeners();
    try {
      await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
    } catch (_) {
      _purchasing = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    if (!_storeAvailable) return;
    _purchasing = true;
    notifyListeners();
    await InAppPurchase.instance.restorePurchases();
    // _purchasing cleared in _onPurchaseUpdates
  }

  // ── Purchase stream handler ────────────────────────────────────────────────
  void _onPurchaseUpdates(List<PurchaseDetails> updates) async {
    for (final p in updates) {
      if (p.productID == kMonthlyId || p.productID == kYearlyId) {
        if (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored) {
          await _setPremium(true);
        }
        // Note: cancellation / expiry is handled via subscription management
        // in the store — we don't clear premium on error to avoid false
        // negatives caused by network issues.
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
    _purchasing = false;
    notifyListeners();
  }

  Future<void> _setPremium(bool value) async {
    if (_isPremium == value) return;
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCacheKey, value);
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
