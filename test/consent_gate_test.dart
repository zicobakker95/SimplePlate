import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ump/user_messaging_codec.dart';
import 'package:simple_plate/services/consent_gate.dart';

// The consent update call can fail (offline). A stored answer still says
// whether the form is required, so the "Privacy options" row must survive.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('privacy options stay available when the consent update fails', () async {
    final channel = MethodChannel(
      'plugins.flutter.io/google_mobile_ads/ump',
      StandardMethodCodec(UserMessagingCodec()),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'ConsentInformation#requestConsentInfoUpdate':
          throw PlatformException(code: '2', message: 'Network error');
        case 'ConsentInformation#canRequestAds':
          return false;
        case 'ConsentInformation#getPrivacyOptionsRequirementStatus':
          return 1; // required
      }
      return null;
    });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final gate = ConsentGate.instance;
    expect(gate.privacyOptionsRequired.value, isFalse);
    await gate.gather(onCanRequestAds: () async {});
    expect(gate.privacyOptionsRequired.value, isTrue);
    // No stored answer allows ads, so nothing may start.
    expect(gate.canRequestAds.value, isFalse);
  });
}
