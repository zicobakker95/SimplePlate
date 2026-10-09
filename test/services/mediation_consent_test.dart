import 'package:simple_plate/services/mediation_consent.dart';
import 'package:flutter_test/flutter_test.dart';

// Section strings built bit by bit from the IAB GPP specs:
// usnat = Version(6)=1, six notices=1, SaleOptOut, SharingOptOut, ...
// usca  = Version(6)=1, three notices=1, SaleOptOut, SharingOptOut, ...
// Opt-out values: 0 n/a, 1 opted out, 2 did not opt out.
const _usnatOptedOut = 'BVVVAAAAAAA'; // sale 1, sharing 1
const _usnatAllowed = 'BVVpAAAAAAA'; // sale 2, sharing 2
const _usnatSaleOnly = 'BVVZAAAAAAA'; // sale 1, sharing 2
const _usnatShareOnly = 'BVVlAAAAAAA'; // sale 2, sharing 1
const _usnatNa = 'BVVBAAAAAAA'; // sale 0, sharing 0
const _uscaOptedOut = 'BVUAAAAAAA';
const _uscaAllowed = 'BVoAAAAAAA';

void main() {
  group('decodeUsGppSection', () {
    test('usnat sale / sharing opt-out', () {
      expect(decodeUsGppSection(7, _usnatOptedOut), UsPrivacyChoice.optedOut);
      expect(decodeUsGppSection(7, _usnatAllowed), UsPrivacyChoice.allowed);
      expect(decodeUsGppSection(7, _usnatSaleOnly), UsPrivacyChoice.optedOut);
      expect(decodeUsGppSection(7, _usnatShareOnly), UsPrivacyChoice.optedOut);
      expect(decodeUsGppSection(7, _usnatNa), UsPrivacyChoice.unknown);
    });

    test('usnat with a GPC sub-section', () {
      expect(
        decodeUsGppSection(7, '$_usnatOptedOut.YA'),
        UsPrivacyChoice.optedOut,
      );
    });

    test('usca layout', () {
      expect(decodeUsGppSection(8, _uscaOptedOut), UsPrivacyChoice.optedOut);
      expect(decodeUsGppSection(8, _uscaAllowed), UsPrivacyChoice.allowed);
    });

    test('garbage, empty, too short and other sections are unknown', () {
      expect(decodeUsGppSection(7, null), UsPrivacyChoice.unknown);
      expect(decodeUsGppSection(7, ''), UsPrivacyChoice.unknown);
      expect(decodeUsGppSection(7, 'BV'), UsPrivacyChoice.unknown);
      expect(decodeUsGppSection(7, 'B!V*'), UsPrivacyChoice.unknown);
      expect(decodeUsGppSection(2, _usnatOptedOut), UsPrivacyChoice.unknown);
    });
  });

  group('decodeUsGpp (full string)', () {
    test('finds usnat by section id order', () {
      expect(
        decodeUsGpp('DBABLA~$_usnatOptedOut', '7'),
        UsPrivacyChoice.optedOut,
      );
      expect(
        decodeUsGpp('DBACNY~CPXXX~$_usnatAllowed', '2_7'),
        UsPrivacyChoice.allowed,
      );
    });

    test('section count mismatch or missing sids is unknown', () {
      expect(decodeUsGpp('DBABLA~$_usnatOptedOut', '2_7'),
          UsPrivacyChoice.unknown);
      expect(decodeUsGpp('DBABLA~$_usnatOptedOut', null),
          UsPrivacyChoice.unknown);
      expect(decodeUsGpp('DBABMA~CPXXX', '2'), UsPrivacyChoice.unknown);
    });
  });

  group('decodeUsPrivacyString', () {
    test('third character is the sale opt-out', () {
      expect(decodeUsPrivacyString('1YYN'), UsPrivacyChoice.optedOut);
      expect(decodeUsPrivacyString('1YNN'), UsPrivacyChoice.allowed);
      expect(decodeUsPrivacyString('1---'), UsPrivacyChoice.unknown);
      expect(decodeUsPrivacyString(null), UsPrivacyChoice.unknown);
      expect(decodeUsPrivacyString('2YYN'), UsPrivacyChoice.unknown);
    });
  });
}
