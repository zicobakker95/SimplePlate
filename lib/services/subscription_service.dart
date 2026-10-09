import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  /// Set while premium was switched on from the debug menu rather than
  /// bought, so the launch reconcile does not take a QA override away.
  static const _kDebugOverrideKey = 'sp.premium.debugOverride';

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isPremium = false;
  bool _debugOverride = false;

  /// Bumped on every store grant, so a reconcile can tell that the purchase
  /// stream granted premium while its query was still out.
  int _storeGrants = 0;
  bool _storeAvailable = false;
  bool _purchasing = false;
  bool _paymentPending = false;
  bool _loadingProducts = true;

  /// The last product query failed (threw, or the store reported an error).
  /// The paywall shows a retry instead of an endless spinner.
  bool _productsError = false;
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
  /// the same cache key a real entitlement uses, so it survives a restart,
  /// and marked as an override so the launch reconcile leaves it alone.
  Future<void> debugSetPremium(bool value) async {
    if (_isPremium == value && _debugOverride == value) return;
    _debugOverride = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDebugOverrideKey, value);
    await _setPremium(value);
  }

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
  bool get productsError => _productsError;
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
    _debugOverride = prefs.getBool(_kDebugOverrideKey) ?? false;
    notifyListeners();

    _storeAvailable = await InAppPurchase.instance.isAvailable();
    if (!_storeAvailable) {
      _loadingProducts = false;
      notifyListeners();
      return;
    }

    _listenToPurchases();

    // The reconcile must run even when the product query fails: it is what
    // acknowledges purchases the stream never delivered, and Play refunds
    // anything left unacknowledged for 3 days.
    try {
      await _loadProducts();
    } finally {
      await _reconcilePurchases();
    }
  }

  void _listenToPurchases() {
    _purchaseSub ??= InAppPurchase.instance.purchaseStream
        .listen(_onPurchaseUpdates, onError: (_) {});
  }

  /// The paywall's "Try again" after a failed or empty product query. Also
  /// covers a store that was unavailable at launch (Play Store updating,
  /// signed out) and has come back since.
  Future<void> reloadProducts() async {
    if (_loadingProducts) return;
    _loadingProducts = true;
    _productsError = false;
    notifyListeners();
    try {
      if (!_storeAvailable) {
        _storeAvailable = await InAppPurchase.instance.isAvailable();
        if (_storeAvailable) _listenToPurchases();
      }
    } catch (e) {
      debugPrint('[subscriptions] store check failed: $e');
      _storeAvailable = false;
    }
    if (!_storeAvailable) {
      _loadingProducts = false;
      _productsError = true;
      notifyListeners();
      return;
    }
    await _loadProducts();
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
  ///
  /// Only Android also takes premium away here (see [_reconcilePlay]). iOS
  /// never does: there is no server-side receipt check, and a StoreKit
  /// restore can prompt for the Apple ID password, so its answer is not
  /// trusted to end a subscription.
  Future<void> _reconcilePurchases() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _reconcilePlay();
      return;
    }
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      debugPrint('[subscriptions] launch reconcile failed: $e');
    }
  }

  /// The Android launch reconcile, which also ends a lapsed subscription.
  ///
  /// Play's purchase query returns only what the account owns right now:
  /// active subscriptions, including one cancelled but still inside its paid
  /// period, a free trial and a grace period. A query that succeeds without
  /// a paid premium purchase therefore means the subscription expired, was
  /// refunded or revoked, or is on account hold, and premium ends. Unlike
  /// restorePurchases(), the query reports a failure as an error instead of
  /// an empty list. A failed query says nothing about what is owned -- an
  /// offline launch must not take away a paid subscription -- so then
  /// nothing changes.
  Future<void> _reconcilePlay() async {
    final grantsBefore = _storeGrants;
    final QueryPurchaseDetailsResponse response;
    try {
      response = await InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .queryPastPurchases();
    } catch (e) {
      debugPrint('[subscriptions] launch reconcile failed: $e');
      return;
    }
    if (response.error != null) {
      debugPrint('[subscriptions] launch reconcile failed: ${response.error}');
      return;
    }
    // Marked as restorePurchases() marks them, so an order acknowledged
    // long ago is not counted as a new sale (see _isNewPlaySale).
    final owned = [
      for (final p in response.pastPurchases)
        p..status = PurchaseStatus.restored,
    ];
    // Granted, acknowledged and reported exactly as the stream would.
    await _onPurchaseUpdates(owned);
    final entitled = owned.any(
        (p) => _isPremiumProduct(p.productID) && !awaitingPayment(p));
    // A grant from the stream while the query was out is newer than it.
    if (entitled || _storeGrants != grantsBefore) return;
    await _endLapsedPremium();
  }

  /// Premium ends with the subscription. Neither a sale nor a refund as far
  /// as analytics is concerned (the stores report cancellations and refunds
  /// themselves), so nothing is logged. A debug-menu override is kept.
  Future<void> _endLapsedPremium() async {
    if (!_isPremium || _debugOverride) return;
    // Belt and braces: Play answers from its own cache, which can come back
    // empty but "OK" offline after the Play Store's data was cleared.
    if (!await _isOnline()) {
      debugPrint('[subscriptions] offline: premium kept');
      return;
    }
    debugPrint('[subscriptions] no active subscription on Play: premium ends');
    await _setPremium(false);
  }

  /// A cheap reachability check, only made when about to end premium.
  Future<bool> _isOnline() async {
    final hook = debugIsOnline;
    if (hook != null) return hook();
    try {
      final r = await InternetAddress.lookup('play.googleapis.com')
          .timeout(const Duration(seconds: 3));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Tests only: stands in for the reachability check.
  @visibleForTesting
  Future<bool> Function()? debugIsOnline;

  static bool _isPremiumProduct(String id) =>
      id == kMonthlyId || id == kYearlyId;

  /// Never throws, and always ends the loading state: an unguarded throw
  /// here left the paywall spinning forever and skipped the launch
  /// reconcile.
  Future<void> _loadProducts() async {
    try {
      final response = await InAppPurchase.instance
          .queryProductDetails({kMonthlyId, kYearlyId});
      if (response.error != null) {
        debugPrint('[subscriptions] product query: ${response.error}');
      }
      _products = List.of(response.productDetails)
        ..sort((a, b) => a.id == kMonthlyId ? -1 : 1); // monthly first
      _productsError = response.error != null && _products.isEmpty;
    } catch (e) {
      debugPrint('[subscriptions] product query failed: $e');
      _productsError = true;
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
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
        if (!_isPremiumProduct(p.productID)) {
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
            _storeGrants++;
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
        // An error never clears premium (it may only be the network);
        // expiry and refunds are picked up by the Android launch reconcile.
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

  /// A store test purchase, which must never be reported as a sale.
  ///
  /// * Google Play: a real order has an order id of the form `GPA.1234-...`.
  ///   License-test and other test orders have none or a different one.
  ///   This is a best-effort client check; Play's server API (purchaseType)
  ///   is the only definitive signal.
  /// * App Store (StoreKit 2): the transaction's JSON names its environment;
  ///   `Sandbox` covers TestFlight and sandbox testers, `Xcode` local
  ///   StoreKit testing. StoreKit 1 transactions carry no such field and
  ///   are treated as real.
  static bool isTestPurchase(PurchaseDetails p) {
    if (p is GooglePlayPurchaseDetails) {
      final orderId = p.billingClientPurchase.orderId.trim();
      return !orderId.startsWith('GPA.');
    }
    if (p.verificationData.source == 'app_store') {
      final env = appStoreEnvironment(p.verificationData.localVerificationData);
      return env != null && env != 'Production';
    }
    return false;
  }

  /// The `environment` of a StoreKit 2 transaction's JSON representation,
  /// or null when there is none (StoreKit 1 receipt, unparseable data).
  @visibleForTesting
  static String? appStoreEnvironment(String localVerificationData) {
    if (!localVerificationData.trimLeft().startsWith('{')) return null;
    try {
      final json = jsonDecode(localVerificationData);
      if (json is Map && json['environment'] is String) {
        return json['environment'] as String;
      }
    } catch (_) {
      // Not JSON: a StoreKit 1 base64 receipt.
    }
    return null;
  }

  /// [reportSale] at most once per order, across launches. Store test
  /// purchases (license testers, TestFlight, sandbox) are never reported.
  Future<void> _reportSaleOnce(PurchaseDetails p) async {
    if (isTestPurchase(p)) {
      AnalyticsService.instance.noteTestPurchase(p.productID);
      _buying = null;
      return;
    }
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
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _isPremium = false;
    _debugOverride = false;
    _paymentPending = false;
    _purchasing = false;
    _buying = null;
    _storeAvailable = false;
    _productsError = false;
    _loadingProducts = true;
    _products = const [];
    debugIsOnline = null;
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
    await AnalyticsService.instance.logSubscriptionPurchase(
      productId: productId,
      price: offer?.rawPrice ?? 0,
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
