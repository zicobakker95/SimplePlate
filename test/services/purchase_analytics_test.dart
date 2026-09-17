import 'package:flutter_test/flutter_test.dart';

/// What the acquisition side of the account can actually optimise toward.
///
/// The Google Ads account measured installs and nothing else: six conversion
/// actions, every one of them "(Android) installs", every one with a value of
/// 0.00. A campaign told to maximise that buys the cheapest install available,
/// which is how the PlateSimple test spent EUR 40.36 on 224 LATAM installs and
/// recorded no in-app action after any of them.
///
/// These are the rules the app now follows when it reports a purchase. They
/// are pure so they can be tested without Firebase or a store connection.
({double value, String currency, bool isTrial}) purchaseEvent({
  required double rawPrice,
  required String currencyCode,
}) =>
    (value: rawPrice, currency: currencyCode, isTrial: rawPrice == 0);

/// Whether a store update should be reported as a conversion.
bool isConversion(String status) => status == 'purchased';

void main() {
  test('a new purchase converts, a restore does not', () {
    expect(isConversion('purchased'), isTrue);
    expect(isConversion('restored'), isFalse,
        reason: 'a restore is the same subscriber on a second device; '
            'counting it would teach the bidder that reinstalls are revenue');
    expect(isConversion('pending'), isFalse);
    expect(isConversion('error'), isFalse);
  });

  test('the event carries the real price and currency', () {
    final yearly = purchaseEvent(rawPrice: 29.99, currencyCode: 'EUR');
    expect(yearly.value, 29.99);
    expect(yearly.currency, 'EUR');
    expect(yearly.isTrial, isFalse);

    final usd = purchaseEvent(rawPrice: 4.99, currencyCode: 'USD');
    expect(usd.currency, 'USD',
        reason: 'value-based bidding needs the buyer currency, not ours');
  });

  test('a zero-price offer is a trial, not revenue', () {
    final trial = purchaseEvent(rawPrice: 0, currencyCode: 'EUR');
    expect(trial.isTrial, isTrue);
    expect(trial.value, 0,
        reason: 'a free trial must not be reported as paid revenue');
  });
}
