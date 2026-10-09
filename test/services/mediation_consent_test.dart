import 'package:simple_plate/services/mediation_consent.dart';
import 'package:flutter_test/flutter_test.dart';

/// Packs 2-bit GPP fields after a 6-bit version into unpadded base64url.
String gpp(List<int> fields, {int version = 1}) {
  const alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  final bits = <int>[
    for (var i = 5; i >= 0; i--) (version >> i) & 1,
    for (final f in fields) ...[(f >> 1) & 1, f & 1],
  ];
  while (bits.length % 6 != 0) {
    bits.add(0);
  }
  final out = StringBuffer();
  for (var i = 0; i < bits.length; i += 6) {
    var v = 0;
    for (var j = 0; j < 6; j++) {
      v = (v << 1) | bits[i + j];
    }
    out.write(alphabet[v]);
  }
  return out.toString();
}

void main() {
  const unity = kUnityAdTechProviderId; // 3234

  group('parseAdditionalConsent', () {
    test('no string or garbage is unknown', () {
      expect(parseAdditionalConsent(null, unity), AcConsent.unknown);
      expect(parseAdditionalConsent('', unity), AcConsent.unknown);
      expect(parseAdditionalConsent('x~3234', unity), AcConsent.unknown);
    });

    test('spec v2: consented, refused, not disclosed', () {
      expect(parseAdditionalConsent('2~89.3234.2526~dv.1301.3234', unity),
          AcConsent.granted);
      expect(parseAdditionalConsent('2~89.2526~dv.1301.3234', unity),
          AcConsent.denied);
      expect(parseAdditionalConsent('2~89.2526~dv.1301', unity),
          AcConsent.unknown);
      expect(parseAdditionalConsent('2~~dv.3234', unity), AcConsent.denied);
    });

    test('spec v2 without the dv part is unknown', () {
      expect(parseAdditionalConsent('2~3234', unity), AcConsent.unknown);
      expect(parseAdditionalConsent('2~3234~1301', unity), AcConsent.unknown);
    });

    test('spec v1 only reports consent', () {
      expect(parseAdditionalConsent('1~89.3234', unity), AcConsent.granted);
      expect(parseAdditionalConsent('1~89.2526', unity), AcConsent.unknown);
      expect(parseAdditionalConsent('1', unity), AcConsent.unknown);
    });

    test('ids must match exactly, not as a prefix', () {
      expect(parseAdditionalConsent('2~32345~dv.32345', unity),
          AcConsent.unknown);
    });
  });

  group('parseUsPrivacy', () {
    // usnat: 6 notice fields, then SaleOptOut, SharingOptOut, TargetedAds.
    String usNat(int sale, int sharing, int targeted) =>
        gpp([1, 1, 1, 1, 1, 1, sale, sharing, targeted, 0, 0, 0]);
    // usca: 3 notice fields, then SaleOptOut, SharingOptOut.
    String usCa(int sale, int sharing) => gpp([1, 1, 1, sale, sharing, 0]);

    test('nothing stored is unknown', () {
      expect(parseUsPrivacy(), AcConsent.unknown);
      expect(parseUsPrivacy(usNat: '', usCa: '', usPrivacy: ''),
          AcConsent.unknown);
      expect(parseUsPrivacy(usNat: '!!'), AcConsent.unknown);
    });

    test('usnat: did not opt out / opted out of sale, sharing or ads', () {
      expect(parseUsPrivacy(usNat: usNat(2, 2, 2)), AcConsent.granted);
      expect(parseUsPrivacy(usNat: usNat(1, 2, 2)), AcConsent.denied);
      expect(parseUsPrivacy(usNat: usNat(2, 1, 2)), AcConsent.denied);
      expect(parseUsPrivacy(usNat: usNat(2, 2, 1)), AcConsent.denied);
      expect(parseUsPrivacy(usNat: usNat(0, 0, 0)), AcConsent.unknown);
      // Sub-segments after '.' (e.g. GPC) are ignored.
      expect(parseUsPrivacy(usNat: '${usNat(1, 0, 0)}.YA'), AcConsent.denied);
    });

    test('usca is used when usnat says nothing', () {
      expect(parseUsPrivacy(usCa: usCa(2, 2)), AcConsent.granted);
      expect(parseUsPrivacy(usCa: usCa(2, 1)), AcConsent.denied);
      expect(parseUsPrivacy(usNat: usNat(0, 0, 0), usCa: usCa(1, 0)),
          AcConsent.denied);
      expect(parseUsPrivacy(usNat: usNat(2, 2, 2), usCa: usCa(1, 1)),
          AcConsent.granted);
    });

    test('legacy uspv1 string', () {
      expect(parseUsPrivacy(usPrivacy: '1YYN'), AcConsent.denied);
      expect(parseUsPrivacy(usPrivacy: '1YNN'), AcConsent.granted);
      expect(parseUsPrivacy(usPrivacy: '1---'), AcConsent.unknown);
      expect(parseUsPrivacy(usPrivacy: '2YYN'), AcConsent.unknown);
    });
  });
}
