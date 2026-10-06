import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
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

  /// Orders already reported to analytics as sales, so the purchase stream
  /// and a later launch reconcile delivering the same order never count it
  /// twice (e.g. when the acknowledgement failed and Play re-delivers it).
  static const _kReportedKey = 'sp.premium.reportedOrders';

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isPremium = false;
  bool _storeAvailable = false;
  bool _purchasing = false;
  bool _paymentPending = false;
  bool _loadingProducts = true;
  List<ProductDetails> _products = const [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  /// Completed when the purchase stream has handled its next batch; a user
  /// Restore waits on it so the paywall reads the result, not the old state.
  Completer<void>? _batchHandled;

  bool get isPremium => _isPremium;

  /// A subscription was bought with a pay-later method (cash voucher, bank
  /// transfer) that has not been paid yet. Premium is NOT granted for it:
  /// Play grants it once the payment clears, through the purchase stream or
  /// the next launch's reconcile. The paywall tells the user so instead of
  /// leaving them wondering why nothing unlocked.
  bool get paymentPending => _paymentPending && !_isPremium;

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
    await _reconcilePurchases();
  }

  /// Silent launch reconcile. Re-grants premium after a reinstall or device
  /// switch, and picks up purchases the purchase stream never delivered: a
  /// pay-later payment (cash voucher, bank transfer) that cleared while the
  /// app was closed, or an app killed between payment and acknowledgement.
  /// Play refunds anything left unacknowledged for 3 days, so without this
  /// such a buyer loses both the subscription and their money. The results
  /// arrive through [_onPurchaseUpdates], which grants, acknowledges and
  /// reports them; no UI is shown and failures (offline, Play unavailable)
  /// only wait for the next launch.
  Future<void> _reconcilePurchases() async {
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      debugPrint('[subscriptions] launch reconcile failed: $e');
    }
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

  /// Resolves once the store has answered and the answer has been handled,
  /// so the caller can read [isPremium] / [paymentPending] straight after.
  Future<void> restorePurchases() async {
    if (!_storeAvailable) return;
    _purchasing = true;
    // Re-established by the restore itself if the payment is still open; an
    // expired voucher simply drops out of Play's list.
    _paymentPending = false;
    final handled = _batchHandled = Completer<void>();
    notifyListeners();
    try {
      await InAppPurchase.instance.restorePurchases();
      // Both stores deliver a batch (empty when there is nothing to
      // restore); don't hang the button if one never comes.
      await handled.future
          .timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (e) {
      debugPrint('[subscriptions] restore failed: $e');
    } finally {
      if (identical(_batchHandled, handled)) _batchHandled = null;
      _purchasing = false;
      notifyListeners();
    }
  }

  // ── Purchase stream handler ────────────────────────────────────────────────

  /// The purchase exists but is not paid yet. On Play a restored purchase is
  /// reported as `restored` even while its cash voucher or bank transfer is
  /// still open, so the real state has to be read from the Play purchase;
  /// granting on `restored` alone unlocked premium for nothing.
  static bool awaitingPayment(PurchaseDetails p) =>
      p.status == PurchaseStatus.pending ||
      (p is GooglePlayPurchaseDetails &&
          p.billingClientPurchase.purchaseState ==
              PurchaseStateWrapper.pending);

  /// A Play purchase nobody has acknowledged yet is a sale this app has not
  /// counted before, even when it arrives as `restored`: a pay-later payment
  /// that cleared while the app was closed reaches the app through the launch
  /// reconcile (a restore), never as `purchased`. A reinstall's restore is
  /// already acknowledged, so it is not counted again. Must be read before
  /// the purchase is acknowledged.
  static bool _isNewPlaySale(PurchaseDetails p) =>
      p is GooglePlayPurchaseDetails && !p.billingClientPurchase.isAcknowledged;

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> updates) async {
    try {
      for (final p in updates) {
        if (p.productID != kMonthlyId && p.productID != kYearlyId) {
          await _complete(p);
          continue;
        }
        if (awaitingPayment(p)) {
          // Unpaid: no premium, no sale, and nothing to acknowledge (Play
          // refuses to acknowledge a pending purchase). The store sheet has
          // closed, so the button stops spinning (see finally) and the
          // paywall explains that premium follows the payment.
          _paymentPending = true;
          continue;
        }
        switch (p.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            // Only a NEW purchase is a conversion. A restore is the same
            // subscriber on a second device, and counting it would teach the
            // bidder that reinstalls are revenue -- except a Play purchase
            // that was never acknowledged, which is a pay-later sale that
            // cleared since. Decided before _complete acknowledges it.
            final newSale =
                p.status == PurchaseStatus.purchased || _isNewPlaySale(p);
            _paymentPending = false;
            await _setPremium(true);
            await _complete(p);
            if (newSale) await _reportSaleOnce(p);
            break;
          case PurchaseStatus.error:
          case PurchaseStatus.canceled:
            _buying = null;
            await _complete(p);
            break;
          case PurchaseStatus.pending:
            break; // handled by awaitingPayment above
        }
        // Note: cancellation / expiry is handled via subscription management
        // in the store — we don't clear premium on error to avoid false
        // negatives caused by network issues.
      }
    } catch (e) {
      debugPrint('[subscriptions] purchase update failed: $e');
    } finally {
      _purchasing = false;
      final handled = _batchHandled;
      _batchHandled = null;
      if (handled != null && !handled.isCompleted) handled.complete();
      notifyListeners();
    }
  }

  Future<void> _complete(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) return;
    try {
      await InAppPurchase.instance.completePurchase(p);
    } catch (e) {
      // Not fatal: the next launch's reconcile acknowledges it again.
      debugPrint('[subscriptions] completePurchase failed: $e');
    }
  }

  /// [reportSale] at most once per order, across launches.
  Future<void> _reportSaleOnce(PurchaseDetails p) async {
    final id = p.purchaseID ?? '';
    if (id.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getStringList(_kReportedKey) ?? const <String>[];
      if (seen.contains(id)) return;
      // A short tail is enough: only a re-delivery of a recent order matters.
      final keep = [...seen, id];
      await prefs.setStringList(
        _kReportedKey,
        keep.length > 20 ? keep.sublist(keep.length - 20) : keep,
      );
    }
    await reportSale(p.productID, transactionId: id.isEmpty ? null : id);
  }

  /// Feeds a purchase-stream update straight in, as the store would.
  @visibleForTesting
  Future<void> debugHandlePurchases(List<PurchaseDetails> updates) =>
      _onPurchaseUpdates(updates);

  /// Tests only: back to a fresh, non-premium, idle service (it is a
  /// singleton, so state would otherwise leak between tests).
  @visibleForTesting
  void debugReset() {
    _isPremium = false;
    _paymentPending = false;
    _purchasing = false;
    _buying = null;
    _storeAvailable = false;
  }

  /// Tests only: pretend the store answered, so [restorePurchases] runs.
  @visibleForTesting
  void debugSetStoreAvailable() => _storeAvailable = true;

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
