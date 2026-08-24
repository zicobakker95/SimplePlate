// Ad frequency is a Remote Config value now, so a typo in the Firebase console
// is a live change to every user at once. These pin the two properties that
// make that survivable: the shipped defaults are what you get when Remote
// Config says nothing, and no server value can wreck the core loop.
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/services/ad_config.dart';

void main() {
  tearDown(() => AdConfig.debugOverrides = null);

  test('with no config at all, behaviour is what shipped', () {
    final c = AdConfig.instance;
    // One interstitial per session, however many meals are logged.
    expect(c.logInterstitialOncePerSession, isTrue);
    expect(c.logInterstitialEvery, 1);
    expect(c.bannerEnabled, isTrue);
    expect(c.scannerRewardedEnabled, isTrue);
    expect(c.scannerUnlockDays, 1);
  });

  test('a sane server value is used as given', () {
    AdConfig.debugOverrides = {AdConfig.kLogInterstitialEvery: 3};
    expect(AdConfig.instance.logInterstitialEvery, 3);
  });

  group('a bad console value cannot wreck the core loop', () {
    test('zero is treated as no answer, not as "every time"', () {
      AdConfig.debugOverrides = {AdConfig.kLogInterstitialEvery: 0};
      expect(AdConfig.instance.logInterstitialEvery, 1);
    });

    test('negatives are floored', () {
      AdConfig.debugOverrides = {AdConfig.kLogInterstitialEvery: -10};
      expect(AdConfig.instance.logInterstitialEvery,
          AdConfig.minLogInterstitialEvery);
    });

    test('an absurd value is capped so ads do not silently switch off', () {
      AdConfig.debugOverrides = {AdConfig.kLogInterstitialEvery: 99999};
      expect(AdConfig.instance.logInterstitialEvery,
          AdConfig.maxLogInterstitialEvery);
    });

    test('a scanner unlock cannot be granted for years', () {
      AdConfig.debugOverrides = {AdConfig.kScannerUnlockDays: 3650};
      expect(AdConfig.instance.scannerUnlockDays,
          AdConfig.maxScannerUnlockDays);
    });

    test('a zero-day unlock would make the reward useless', () {
      AdConfig.debugOverrides = {AdConfig.kScannerUnlockDays: 0};
      expect(AdConfig.instance.scannerUnlockDays, 1);
    });
  });

  test('kill switches turn a placement off entirely', () {
    AdConfig.debugOverrides = {
      AdConfig.kBannerEnabled: false,
      AdConfig.kScannerRewardedEnabled: false,
    };
    expect(AdConfig.instance.bannerEnabled, isFalse);
    expect(AdConfig.instance.scannerRewardedEnabled, isFalse);
  });

  group('the weekly-insights day unlock', () {
    test('is on by default, for one day', () {
      expect(AdConfig.instance.insightsRewardedEnabled, isTrue);
      expect(AdConfig.instance.insightsUnlockDays, 1);
    });

    test('can be switched off without a build', () {
      AdConfig.debugOverrides = {AdConfig.kInsightsRewardedEnabled: false};
      expect(AdConfig.instance.insightsRewardedEnabled, isFalse);
    });

    test('cannot be granted for years, or for zero days', () {
      AdConfig.debugOverrides = {AdConfig.kInsightsUnlockDays: 9999};
      expect(AdConfig.instance.insightsUnlockDays,
          AdConfig.maxScannerUnlockDays);
      AdConfig.debugOverrides = {AdConfig.kInsightsUnlockDays: 0};
      expect(AdConfig.instance.insightsUnlockDays, 1,
          reason: 'a zero-day unlock would make the reward useless');
    });
  });

  test('every exposed key has a default', () {
    for (final key in AdConfig.instance.snapshot().keys) {
      expect(AdConfig.defaults.containsKey(key), isTrue,
          reason: '$key is exposed but has no default');
    }
  });
}
