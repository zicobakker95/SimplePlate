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

  /// One entry per subscription tier for the paywall.
  ///
  /// On Google Play a subscription can expose several offers (e.g. a base
  /// plan plus a free-trial offer) as separate [ProductDetails] that share
  /// one product id — which would otherwise render as duplicate cards. This
  /// collapses each id into a single tier that shows the recurring price but
  /// purchases the free-trial offer when one exists (so the trial belongs to
  /// the plan instead of being a separate option).
  List<PlanOption> get planOptions {
    final result = <PlanOption>[];
    for (final id in const [kMonthlyId, kYearlyId]) {
      final offers = _products.where((p) => p.id == id).toList();
      if (offers.isEmpty) continue;
      // The recurring-price offer (rawPrice > 0) drives the displayed price.
      final display =
          offers.firstWhere((p) => p.rawPrice > 0, orElse: () => offers.first);
      // A free-trial offer starts with a zero-price pricing phase.
      ProductDetails? trial;
      for (final o in offers) {
        if (o.rawPrice == 0) {
          trial = o;
          break;
        }
      }
      result.add(PlanOption(
        id: id,
        display: display,
        purchaseTarget: trial ?? display,
        hasFreeTrial: trial != null,
      ));
    }
    return result;
  }

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

/// A single subscription tier shown on the paywall (see
/// [SubscriptionService.planOptions]).
class PlanOption {
  PlanOption({
    required this.id,
    required this.display,
    required this.purchaseTarget,
    required this.hasFreeTrial,
  });

  /// The base product id (monthly / yearly).
  final String id;

  /// Offer used for the displayed recurring price and labels.
  final ProductDetails display;

  /// Offer actually purchased — the free-trial offer when one exists, so its
  /// offer token is applied and the trial is granted.
  final ProductDetails purchaseTarget;

  /// Whether [purchaseTarget] includes a free trial.
  final bool hasFreeTrial;

  String get price => display.price;
}
