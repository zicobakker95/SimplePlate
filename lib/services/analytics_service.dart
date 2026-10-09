import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper over Firebase Analytics for marketing / user-acquisition
/// event logging.
///
/// Every call is fire-and-forget and never throws, so analytics cannot crash
/// the app. Firebase also auto-collects `first_open`, `app_open`,
/// `session_start`, and (via [observer]) screen views.
///
/// The handle is resolved lazily and guarded rather than being a field
/// initialiser. `final _fa = FirebaseAnalytics.instance` runs the moment the
/// singleton is first touched and throws outright if Firebase has not come up,
/// which would make the "never throws" promise above untrue on any device
/// where init fails — no Play Services, bad config, offline first run — and
/// would take the first screen build down with it.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _cached;
  bool _tried = false;

  /// The Firebase handle, or null when Firebase is unavailable.
  FirebaseAnalytics? get _fa {
    if (_tried) return _cached;
    _tried = true;
    try {
      _cached = FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('Analytics unavailable: $e');
      _cached = null;
    }
    return _cached;
  }

  /// True when events are actually going somewhere.
  bool get isAvailable => _fa != null;

  /// Navigator observer that auto-logs `screen_view`, or null when Firebase is
  /// unavailable. Callers should spread it: `navigatorObservers: [?observer]`.
  FirebaseAnalyticsObserver? get observer {
    final fa = _fa;
    return fa == null ? null : FirebaseAnalyticsObserver(analytics: fa);
  }

  /// Log a custom event. Parameter values must be String or num.
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    try {
      await _fa?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics "$name" failed: $e');
    }
  }

  /// A completed, paid subscription purchase, as the custom
  /// `subscription_purchase` event: a funnel step, NOT a revenue event.
  ///
  /// It used to be Firebase's standard `purchase` event with a value. Since
  /// Google Play was linked to Firebase (2026-10-05), the stores' own revenue
  /// reaches GA4 as the automatically collected `in_app_purchase` event
  /// (App Store auto-collection does the same on iOS), and GA4 adds both to
  /// purchase revenue, so every subscription was counted twice. The store
  /// events are the trustworthy source -- they come from the store, include
  /// renewals and leave out refunds -- so they own revenue and this event
  /// carries the price as `price`, never as `value`. Import
  /// `in_app_purchase` into Google Ads as the value conversion.
  ///
  /// A free-trial start is NOT a purchase; see [logStartTrial]. Neither is
  /// sent from a debug build, nor for a store test purchase (see
  /// SubscriptionService.isTestPurchase): a developer's test subscriptions
  /// once made up all of PlateSimple's "revenue" in Firebase while the
  /// stores showed none.
  Future<void> logSubscriptionPurchase({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  }) async {
    if (kDebugMode) {
      debugSales.add('subscription_purchase $productId $price $currency');
      return;
    }
    await logEvent('subscription_purchase', <String, Object>{
      'product_id': productId,
      'price': price,
      'currency': currency,
      if (transactionId != null && transactionId.isNotEmpty)
        'transaction_id': transactionId,
    });
  }

  /// A subscription began with a free trial: nothing paid yet, so no value.
  /// The paid conversion, if it happens, reaches Firebase through the
  /// stores' own revenue events (Google Play link, App Store auto-collection).
  Future<void> logStartTrial({
    required String productId,
    required String currency,
  }) async {
    if (kDebugMode) {
      debugSales.add('start_trial $productId');
      return;
    }
    await logEvent('start_trial', {
      'product_id': productId,
      'currency': currency,
      'value': 0,
    });
  }

  /// A store test purchase (license tester, TestFlight, sandbox) that is
  /// deliberately not reported. Nothing is sent, in any build.
  void noteTestPurchase(String productId) {
    debugPrint('[analytics] test purchase $productId: not reported');
    if (kDebugMode) debugSales.add('test_purchase $productId');
  }

  /// What [logSubscriptionPurchase] / [logStartTrial] were asked to send,
  /// newest last.
  /// Recorded in debug builds only, where nothing is sent; tests read it.
  @visibleForTesting
  final List<String> debugSales = [];

  /// The paywall was shown. The denominator for paywall conversion, and a
  /// usable optimisation signal on its own while purchases are still rare.
  Future<void> logPaywallView(String source) =>
      logEvent('paywall_view', {'source': source});

  /// The user tapped subscribe and the store sheet is coming up.
  Future<void> logBeginCheckout({
    required String productId,
    required double value,
    required String currency,
  }) async {
    try {
      await _fa?.logBeginCheckout(
        currency: currency,
        value: value,
        parameters: <String, Object>{'product_id': productId},
      );
    } catch (e) {
      debugPrint('Analytics begin_checkout failed: $e');
    }
  }

  /// Set a user property used to segment reports. Values must be strings.
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _fa?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics property "$name" failed: $e');
    }
  }
}
