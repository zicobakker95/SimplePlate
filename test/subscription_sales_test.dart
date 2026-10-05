import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

void main() {
  final svc = SubscriptionService.instance;
  final sales = AnalyticsService.instance.debugSales;
  final yearly = SubscriptionService.kYearlyId;
  final monthly = SubscriptionService.kMonthlyId;

  setUp(sales.clear);

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
}
