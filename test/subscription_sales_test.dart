import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' show InAppPurchase;
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/services/analytics_service.dart';
import 'package:simple_plate/services/subscription_service.dart';

/// A store offer as the plugin hands it over: Play lists a free-trial offer
/// as its own ProductDetails, sharing the product id, priced at zero.
ProductDetails _offer(String id, double price) => ProductDetails(
      id: id,
      title: 'Premium',
      description: 'Premium',
      price: price == 0 ? 'Free' : '€$price',
      rawPrice: price,
      currencyCode: 'EUR',
    );

/// Stands in for Google Play: records acknowledgements, and answers a
/// restore with [owned] the way the real plugin does (through the stream).
class _FakeStore extends InAppPurchasePlatform
    with MockPlatformInterfaceMixin {
  final completed = <PurchaseDetails>[];
  List<PurchaseDetails> owned = const [];
  bool available = true;
  List<ProductDetails> products = const [];
  bool queryThrows = false;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();

  @override
  Future<ProductDetailsResponse> queryProductDetails(
          Set<String> identifiers) async {
    if (queryThrows) throw PlatformException(code: 'BILLING_UNAVAILABLE');
    return ProductDetailsResponse(
        productDetails: products, notFoundIDs: const []);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completed.add(purchase);

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async =>
      true;

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    // The plugin pushes the result onto the purchase stream.
    SubscriptionService.instance.debugHandlePurchases(owned);
  }
}

/// Stands in for Play's purchase query (queryPastPurchases), which answers
/// with what the account owns right now, or with an error.
class _FakePlayQuery implements InAppPurchaseAndroidPlatformAddition {
  List<GooglePlayPurchaseDetails> owned = const [];
  IAPError? error;
  bool throws = false;
  int calls = 0;

  @override
  Future<QueryPurchaseDetailsResponse> queryPastPurchases(
      {String? applicationUserName}) async {
    calls++;
    if (throws) throw PlatformException(code: 'SERVICE_DISCONNECTED');
    return QueryPurchaseDetailsResponse(
      pastPurchases: error == null ? owned : const [],
      error: error,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A Play subscription purchase. [restored] mimics restorePurchases(), which
/// forces the status to `restored` whatever the payment state.
GooglePlayPurchaseDetails _play(
  String productId,
  PurchaseStateWrapper state, {
  bool acknowledged = false,
  bool restored = false,
  String orderId = 'GPA.voucher',
}) {
  final w = PurchaseWrapper(
    // Play gives an unpaid purchase no order id until it is paid.
    orderId: state == PurchaseStateWrapper.pending ? '' : orderId,
    packageName: 'com.zibaentertainment.simple_plate',
    purchaseTime: 0,
    purchaseToken: 'token',
    signature: '',
    products: [productId],
    isAutoRenewing: true,
    originalJson: '{}',
    isAcknowledged: acknowledged,
    purchaseState: state,
  );
  final p = GooglePlayPurchaseDetails.fromPurchase(w).single;
  if (restored) p.status = PurchaseStatus.restored;
  return p;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final svc = SubscriptionService.instance;
  final sales = AnalyticsService.instance.debugSales;
  final yearly = SubscriptionService.kYearlyId;
  final monthly = SubscriptionService.kMonthlyId;
  late _FakeStore store;
  late _FakePlayQuery play;

  setUp(() {
    sales.clear();
    // InAppPurchase.instance installs the real Play store over any fake when
    // the target platform is Android, which it is under flutter_test. It
    // only does so the first time, so it is created here, before any test
    // switches the platform to Android.
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    InAppPurchase.instance;
    SharedPreferences.setMockInitialValues({});
    store = _FakeStore();
    InAppPurchasePlatform.instance = store;
    play = _FakePlayQuery();
    InAppPurchasePlatformAddition.instance = play;
    svc.debugReset();
    svc.debugIsOnline = () async => true;
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    InAppPurchasePlatformAddition.instance = null;
  });

  test('a free-trial offer is a trial start, never a purchase', () {
    expect(SubscriptionService.startsFreeTrial(_offer(yearly, 0)), isTrue);
    expect(SubscriptionService.startsFreeTrial(_offer(yearly, 29.99)), isFalse);
  });

  test('starting the yearly trial logs start_trial, not a full-price purchase',
      () async {
    // The trial offer and the recurring offer, as Play returns them.
    svc.debugSetProducts([_offer(yearly, 29.99), _offer(yearly, 0)]);
    await svc.reportSale(yearly, transactionId: 'GPA.1');
    expect(sales, ['start_trial $yearly']);
  });

  test('a plan without a trial logs a purchase at its real price', () async {
    svc.debugSetProducts([_offer(monthly, 4.99)]);
    await svc.reportSale(monthly, transactionId: 'GPA.2');
    expect(sales, ['subscription_purchase $monthly 4.99 EUR']);
  });

  test('a purchase that arrives later is judged by the offer the paywall buys',
      () async {
    svc.debugSetProducts([_offer(yearly, 29.99), _offer(yearly, 0)]);
    expect(svc.offerBoughtFor(yearly)!.rawPrice, 0,
        reason: 'the paywall buys the trial offer when there is one');
  });

  group('pay-later (pending) Play purchases', () {
    test('an unpaid purchase stops the spinner but grants nothing', () async {
      svc.debugSetProducts([_offer(monthly, 4.99)]);
      await svc.purchase(svc.monthly!);
      expect(svc.purchasing, isTrue);

      await svc.debugHandlePurchases(
          [_play(monthly, PurchaseStateWrapper.pending)]);
      expect(svc.purchasing, isFalse, reason: 'button must not keep spinning');
      expect(svc.paymentPending, isTrue);
      expect(svc.isPremium, isFalse);
      expect(store.completed, isEmpty,
          reason: 'Play refuses to acknowledge an unpaid purchase');
      expect(sales, isEmpty, reason: 'an unpaid voucher is not revenue');
    });

    test('a restore reporting an unpaid voucher as `restored` grants nothing',
        () async {
      await svc.debugHandlePurchases([
        _play(yearly, PurchaseStateWrapper.pending, restored: true),
      ]);
      expect(svc.isPremium, isFalse);
      expect(svc.paymentPending, isTrue);
      expect(store.completed, isEmpty);
      expect(sales, isEmpty);
    });

    test('the voucher, once paid, unlocks and is counted once at its price',
        () async {
      svc.debugSetProducts([_offer(monthly, 4.99)]);
      await svc.purchase(svc.monthly!);
      await svc.debugHandlePurchases(
          [_play(monthly, PurchaseStateWrapper.pending)]);
      // Paid while the app was open: Play sends it again as purchased.
      final paid = _play(monthly, PurchaseStateWrapper.purchased);
      await svc.debugHandlePurchases([paid]);
      expect(svc.isPremium, isTrue);
      expect(svc.paymentPending, isFalse);
      expect(store.completed, [paid]);
      // The next launch's reconcile re-delivers it, still unacknowledged
      // because the acknowledgement failed: not a second sale.
      await svc.debugHandlePurchases(
          [_play(monthly, PurchaseStateWrapper.purchased, restored: true)]);
      expect(sales, ['subscription_purchase $monthly 4.99 EUR']);
    });

    test('a voucher paid while the app was closed is granted, acknowledged '
        'and counted at launch', () async {
      // Bought earlier; the trial offer is gone from this user's list.
      svc.debugSetProducts([_offer(yearly, 29.99)]);
      final paid = _play(yearly, PurchaseStateWrapper.purchased,
          restored: true, orderId: 'GPA.late');
      await svc.debugHandlePurchases([paid]);
      expect(svc.isPremium, isTrue);
      expect(store.completed, [paid],
          reason: 'Play refunds what is not acknowledged within 3 days');
      expect(sales, ['subscription_purchase $yearly 29.99 EUR']);
    });

    test('a reinstall restore (already acknowledged) is not revenue',
        () async {
      svc.debugSetProducts([_offer(yearly, 29.99)]);
      await svc.debugHandlePurchases([
        _play(yearly, PurchaseStateWrapper.purchased,
            acknowledged: true, restored: true),
      ]);
      expect(svc.isPremium, isTrue);
      expect(store.completed, isEmpty);
      expect(sales, isEmpty);
    });

    test('a trial bought through a pay-later flow stays a trial start',
        () async {
      svc.debugSetProducts([_offer(yearly, 29.99), _offer(yearly, 0)]);
      await svc.purchase(svc.planOptions.single.purchaseTarget);
      await svc.debugHandlePurchases(
          [_play(yearly, PurchaseStateWrapper.pending)]);
      await svc.debugHandlePurchases(
          [_play(yearly, PurchaseStateWrapper.purchased, orderId: 'GPA.t')]);
      expect(sales, ['start_trial $yearly']);
    });

    test('user Restore resolves with the voucher still pending', () async {
      svc.debugSetStoreAvailable();
      store.owned = [
        _play(monthly, PurchaseStateWrapper.pending, restored: true),
      ];
      await svc.restorePurchases();
      expect(svc.purchasing, isFalse);
      expect(svc.paymentPending, isTrue);
      expect(svc.isPremium, isFalse);
    });

    test('user Restore with nothing owned clears the spinner', () async {
      svc.debugSetStoreAvailable();
      await svc.restorePurchases();
      expect(svc.purchasing, isFalse);
      expect(svc.paymentPending, isFalse);
    });
  });

  group('launch reconcile ends a lapsed subscription', () {
    /// An app start for a user who had premium cached, on [platform].
    Future<void> launch({
      Map<String, Object> prefs = const {'sp.premium.active': true},
      TargetPlatform platform = TargetPlatform.android,
    }) async {
      SharedPreferences.setMockInitialValues(prefs);
      debugDefaultTargetPlatformOverride = platform;
      await svc.initialize();
    }

    Future<bool?> cachedPremium() async =>
        (await SharedPreferences.getInstance()).getBool('sp.premium.active');

    test('Play owns nothing any more: premium ends, nothing is logged',
        () async {
      var notified = 0;
      void listener() => notified++;
      svc.addListener(listener);
      addTearDown(() => svc.removeListener(listener));

      await launch();
      expect(play.calls, 1);
      expect(svc.isPremium, isFalse);
      expect(await cachedPremium(), isFalse,
          reason: 'must not come back on the next launch');
      expect(notified, greaterThan(1), reason: 'gated screens must rebuild');
      expect(sales, isEmpty, reason: 'a lapse is not a sale');
    });

    test('offline (Play answered empty from its cache) keeps premium',
        () async {
      svc.debugIsOnline = () async => false;
      await launch();
      expect(play.calls, 1);
      expect(svc.isPremium, isTrue);
      expect(await cachedPremium(), isTrue);
    });

    test('a query error keeps premium', () async {
      play.error = IAPError(
          source: 'google_play', code: 'restore_transactions_failed',
          message: 'BillingResponse.serviceUnavailable');
      await launch();
      expect(play.calls, 1);
      expect(svc.isPremium, isTrue);
      expect(await cachedPremium(), isTrue);
    });

    test('a query that throws (offline, billing unavailable) keeps premium',
        () async {
      play.throws = true;
      await launch();
      expect(play.calls, 1);
      expect(svc.isPremium, isTrue);
      expect(await cachedPremium(), isTrue);
    });

    test('no Play store on the device keeps premium', () async {
      store.available = false;
      await launch();
      expect(play.calls, 0);
      expect(svc.isPremium, isTrue);
    });

    test('an active subscription keeps premium and is not a new sale',
        () async {
      play.owned = [
        _play(yearly, PurchaseStateWrapper.purchased, acknowledged: true),
      ];
      await launch();
      expect(svc.isPremium, isTrue);
      expect(store.completed, isEmpty);
      expect(sales, isEmpty, reason: 'the order was counted when it was made');
    });

    test('a free trial in progress keeps premium', () async {
      // Play lists a trialling subscription as owned and paid.
      store.products = [_offer(monthly, 4.99), _offer(monthly, 0)];
      play.owned = [
        _play(monthly, PurchaseStateWrapper.purchased,
            acknowledged: true, orderId: 'GPA.trial'),
      ];
      await launch();
      expect(svc.isPremium, isTrue);
      expect(sales, isEmpty);
    });

    test('an unacknowledged paid order is granted, acknowledged and counted',
        () async {
      final paid = _play(monthly, PurchaseStateWrapper.purchased,
          orderId: 'GPA.cleared');
      store.products = [_offer(monthly, 4.99)];
      play.owned = [paid];
      await launch(prefs: const {});
      expect(svc.isPremium, isTrue);
      expect(store.completed, [paid]);
      expect(sales, ['subscription_purchase $monthly 4.99 EUR']);
    });

    test('only an unpaid pay-later purchase: premium ends, payment pending',
        () async {
      play.owned = [_play(yearly, PurchaseStateWrapper.pending)];
      await launch();
      expect(svc.isPremium, isFalse);
      expect(svc.paymentPending, isTrue);
      expect(store.completed, isEmpty);
      expect(sales, isEmpty);
    });

    test('another app product does not count as premium', () async {
      play.owned = [
        _play('simple_plate.something_else', PurchaseStateWrapper.purchased,
            acknowledged: true),
      ];
      await launch();
      expect(svc.isPremium, isFalse);
    });

    test('a debug-menu override is left alone', () async {
      await launch(prefs: const {
        'sp.premium.active': true,
        'sp.premium.debugOverride': true,
      });
      expect(play.calls, 1);
      expect(svc.isPremium, isTrue);
    });

    test('iOS never takes premium away', () async {
      // StoreKit restore answers with nothing owned.
      await launch(platform: TargetPlatform.iOS);
      expect(play.calls, 0, reason: 'the Play query is Android-only');
      expect(svc.isPremium, isTrue);
      expect(await cachedPremium(), isTrue);
    });
  });

  group('store test purchases are never revenue', () {
    test('a Play order without a GPA. order id is a test purchase', () {
      expect(
          SubscriptionService.isTestPurchase(_play(
              monthly, PurchaseStateWrapper.purchased,
              orderId: 'GPA.3312-1234-5678-12345')),
          isFalse);
      expect(
          SubscriptionService.isTestPurchase(
              _play(monthly, PurchaseStateWrapper.purchased, orderId: '')),
          isTrue);
      expect(
          SubscriptionService.isTestPurchase(_play(
              monthly, PurchaseStateWrapper.purchased,
              orderId: 'test-order-1')),
          isTrue);
    });

    test('a license-test Play purchase grants premium but logs no sale',
        () async {
      svc.debugSetProducts([_offer(monthly, 4.99)]);
      final p = _play(monthly, PurchaseStateWrapper.purchased, orderId: '')
        ..status = PurchaseStatus.purchased;
      await svc.debugHandlePurchases([p]);
      expect(svc.isPremium, isTrue);
      expect(store.completed, [p], reason: 'still acknowledged');
      expect(sales, ['test_purchase $monthly']);
    });

    test('StoreKit 2 environment is read from the transaction JSON', () {
      expect(
          SubscriptionService.appStoreEnvironment(
              '{"environment":"Sandbox","productId":"x"}'),
          'Sandbox');
      expect(
          SubscriptionService.appStoreEnvironment(
              '{"environment":"Production"}'),
          'Production');
      expect(SubscriptionService.appStoreEnvironment('MIIT...base64'), isNull);
      expect(SubscriptionService.appStoreEnvironment('{not json'), isNull);
    });

    test('a TestFlight / sandbox App Store purchase is a test purchase', () {
      PurchaseDetails ios(String json) => PurchaseDetails(
            purchaseID: '2000000123',
            productID: monthly,
            verificationData: PurchaseVerificationData(
              localVerificationData: json,
              serverVerificationData: 'jws',
              source: 'app_store',
            ),
            transactionDate: '0',
            status: PurchaseStatus.purchased,
          );
      expect(
          SubscriptionService.isTestPurchase(
              ios('{"environment":"Sandbox"}')),
          isTrue);
      expect(
          SubscriptionService.isTestPurchase(ios('{"environment":"Xcode"}')),
          isTrue);
      expect(
          SubscriptionService.isTestPurchase(
              ios('{"environment":"Production"}')),
          isFalse);
    });
  });

  group('product query failures', () {
    test('a throwing query ends loading with an error and still reconciles',
        () async {
      store.queryThrows = true;
      SharedPreferences.setMockInitialValues(const {});
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await svc.initialize();
      expect(svc.loadingProducts, isFalse,
          reason: 'the paywall spinner must stop');
      expect(svc.productsError, isTrue);
      expect(play.calls, 1,
          reason: 'the launch reconcile acknowledges undelivered purchases');
    });

    test('Try again loads the plans once the store answers', () async {
      store.queryThrows = true;
      SharedPreferences.setMockInitialValues(const {});
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await svc.initialize();
      expect(svc.productsError, isTrue);

      store
        ..queryThrows = false
        ..products = [_offer(monthly, 4.99)];
      await svc.reloadProducts();
      expect(svc.productsError, isFalse);
      expect(svc.loadingProducts, isFalse);
      expect(svc.monthly?.rawPrice, 4.99);
    });
  });
}
