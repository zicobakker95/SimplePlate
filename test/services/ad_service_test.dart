import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/screens/premium/premium_screen.dart';
import 'package:simple_plate/services/ad_service.dart';

void main() {
  group('ad load retry', () {
    test('backs off 10 s, 20 s, 40 s ... and caps at 10 minutes', () {
      expect(AdService.retryDelay(0), Duration.zero);
      expect(AdService.retryDelay(1), const Duration(seconds: 10));
      expect(AdService.retryDelay(2), const Duration(seconds: 20));
      expect(AdService.retryDelay(3), const Duration(seconds: 40));
      expect(AdService.retryDelay(6), const Duration(seconds: 320));
      expect(AdService.retryDelay(7), const Duration(minutes: 10));
      expect(AdService.retryDelay(500), const Duration(minutes: 10),
          reason: 'a long no-fill streak must not overflow or speed up');
    });
  });

  group('loaded ad expiry', () {
    final loaded = DateTime(2026, 10, 9, 12);

    test('a fresh ad can be shown', () {
      expect(
          AdService.isExpired(loaded, loaded.add(const Duration(minutes: 59))),
          isFalse);
    });

    test('an ad loaded an hour ago is dropped', () {
      expect(AdService.isExpired(loaded, loaded.add(const Duration(hours: 1))),
          isTrue);
      expect(AdService.isExpired(loaded, loaded.add(const Duration(hours: 5))),
          isTrue);
    });

    test('no load time means nothing to show', () {
      expect(AdService.isExpired(null, loaded), isTrue);
    });
  });

  group('paywall terms link', () {
    test('Android links the app\'s own terms, iOS the Apple EULA', () {
      expect(termsOfUseUrlFor(TargetPlatform.android),
          'https://zibaentertainment.com/terms-of-use-platesimple.html');
      expect(termsOfUseUrlFor(TargetPlatform.iOS),
          contains('apple.com/legal/internet-services/itunes/dev/stdeula'));
    });
  });
}
