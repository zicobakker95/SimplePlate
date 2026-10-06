import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
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

  setUp(() {
    sales.clear();
    // InAppPurchase.instance installs the real Play store over any fake when
    // the target platform is Android, which it is under flutter_test.
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    SharedPreferences.setMockInitialValues({});
    store = _FakeStore();
    InAppPurchasePlatform.instance = store;
    svc.debugReset();
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

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
    expect(sales, ['purchase $monthly 4.99 EUR']);
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
      expect(sales, ['purchase $monthly 4.99 EUR']);
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
      expect(sales, ['purchase $yearly 29.99 EUR']);
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
}
