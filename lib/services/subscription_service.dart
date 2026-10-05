import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages monthly/yearly premium subscriptions via in_app_purchase.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();
  static final instance = SubscriptionService._();

  // ── Product IDs (must match exactly in each store) ─────────────────────────
  // iOS products are registered in App Store Connect under the fully-qualified
  // com.zibaentertainment.simple_plate.* namespace; Android (Play Console) keeps
  // the short ids. Resolve per platform so queryProductDetails matches.
  static const _kMonthlyAndroid = 'simple_plate.premium_monthly';
  static const _kYearlyAndroid = 'simple_plate.premium_yearly';
  static const _kMonthlyIOS = 'com.zibaentertainment.simple_plate.premium_monthly';
  static const _kYearlyIOS = 'com.zibaentertainment.simple_plate.premium_yearly';

  static final kMonthlyId = defaultTargetPlatform == TargetPlatform.iOS
      ? _kMonthlyIOS
      : _kMonthlyAndroid;
  static final kYearlyId = defaultTargetPlatform == TargetPlatform.iOS
      ? _kYearlyIOS
      : _kYearlyAndroid;

  static const _kCacheKey = 'sp.premium.active';

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isPremium = false;
  bool _storeAvailable = false;
  bool _purchasing = false;
  bool _loadingProducts = true;
  List<ProductDetails> _products = const [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  bool get isPremium => _isPremium;

  /// Debug builds only — see lib/debug.
  ///
  /// Premium is otherwise reachable only through a real store subscription,
  /// which leaves every gated screen untestable on a debug build. Written to
  /// the same cache key a real entitlement uses, so it survives a restart.
  Future<void> debugSetPremium(bool value) => _setPremium(value);

  /// Tests only: stands in for the store's product list so the paywall can
  /// be rendered (and screenshotted) with real-looking plans.
  @visibleForTesting
  void debugSetProducts(List<ProductDetails> products) {
    _products = List.of(products);
    _loadingProducts = false;
    notifyListeners();
  }
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
    for (final id in [kMonthlyId, kYearlyId]) {
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

  /// The recurring price of [id] as the store reports it, for analytics.
  /// Null when the product list has not loaded (offline, store unavailable),
  /// in which case the purchase event still fires with a zero value rather
  /// than not firing at all.
  ({double value, String currency})? priceOf(String id) {
    final p = _byId(id);
    if (p == null) return null;
    return (value: p.rawPrice, currency: p.currencyCode);
  }

  /// Whether buying [product] starts a free trial instead of charging.
  ///
  /// Play lists the trial as its own offer whose first phase costs nothing,
  /// and only lists offers the user is still eligible for. The App Store
  /// sells one product with an introductory free-trial offer; whether this
  /// user still qualifies is not known on the device, so a returning
  /// subscriber is counted as a trial too. Either way the money, when it
  /// comes, reaches Firebase through the stores' own revenue events.
  static bool startsFreeTrial(ProductDetails product) {
    if (product.rawPrice == 0) return true;
    if (product is AppStoreProductDetails) {
      final intro = product.skProduct.introductoryPrice;
      // NB: the plugin enum has a known typo, `freeTrail` (not freeTrial).
      return intro != null &&
          intro.paymentMode == SKProductDiscountPaymentMode.freeTrail;
    }
    return false;
  }

  /// The offer a completed purchase of [productId] was for: the one this
  /// session sent to the store, or, when the purchase arrives later (a
  /// pending payment, an app restart), the offer the paywall would buy.
  @visibleForTesting
  ProductDetails? offerBoughtFor(String productId) {
    final sent = _buying;
    if (sent != null && sent.id == productId) return sent;
    for (final plan in planOptions) {
      if (plan.id == productId) return plan.purchaseTarget;
    }
    return _byId(productId);
  }

  /// The offer last handed to the store by [purchase].
  ProductDetails? _buying;

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
    _buying = product;
    notifyListeners();
    try {
      await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
    } catch (_) {
      _purchasing = false;
      _buying = null;
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
          // Only a NEW purchase is a conversion. A restore is the same
          // subscriber on a second device, and counting it would teach the
          // bidder that reinstalls are revenue.
          if (p.status == PurchaseStatus.purchased) {
            await reportSale(p.productID, transactionId: p.purchaseID);
          }
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

  /// Tells analytics about a new subscription. A free-trial start is a
  /// `start_trial` with no value: nothing has been paid, and most trials end
  /// without a charge. It used to be a `purchase` at the full recurring
  /// price, which showed revenue in Firebase the stores never received and
  /// fed that value to Google Ads bidding. Only a paid start is a `purchase`,
  /// at the price of the offer actually bought.
  @visibleForTesting
  Future<void> reportSale(String productId, {String? transactionId}) async {
    final offer = offerBoughtFor(productId);
    _buying = null;
    if (offer != null && startsFreeTrial(offer)) {
      final display = priceOf(productId);
      await AnalyticsService.instance.logStartTrial(
        productId: productId,
        currency: display?.currency ?? offer.currencyCode,
      );
      return;
    }
    await AnalyticsService.instance.logPurchase(
      productId: productId,
      value: offer?.rawPrice ?? 0,
      currency: offer?.currencyCode ?? 'EUR',
      transactionId: transactionId,
    );
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
