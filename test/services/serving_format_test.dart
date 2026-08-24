// "100 g (2 servings)" -- the format a user asked for. The rules that matter:
// grams are never replaced, only annotated, and a food with no declared
// serving size must render exactly as it did before this feature existed.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/l10n/app_localizations.dart';
import 'package:simple_plate/utils/serving_format.dart';

late AppLocalizations l10n;

void main() {
  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('the requested format', () {
    test('the example from the request', () {
      expect(gramsWithServings(l10n, 100, 50), '100 g (2 servings)');
    });

    test('one serving is singular', () {
      expect(gramsWithServings(l10n, 50, 50), '50 g (1 serving)');
    });

    test('fractions read naturally rather than as long decimals', () {
      expect(gramsWithServings(l10n, 75, 50), '75 g (1.5 servings)');
      expect(gramsWithServings(l10n, 25, 50), '25 g (0.5 servings)');
    });
  });

  group('a food with no serving size is untouched', () {
    test('null renders as plain grams', () {
      expect(gramsWithServings(l10n, 100, null), '100 g');
    });

    test('zero and negatives cannot divide by zero into infinity servings', () {
      expect(gramsWithServings(l10n, 100, 0), '100 g');
      expect(gramsWithServings(l10n, 100, -50), '100 g');
    });

    test('servingLabel returns null so callers can hide the whole line', () {
      expect(servingLabel(l10n, 100, null), isNull);
      expect(servingLabel(l10n, 100, 0), isNull);
      expect(servingLabel(l10n, 0, 50), isNull, reason: 'zero grams is no serving');
    });
  });

  group('number formatting', () {
    test('whole numbers lose the trailing .0', () {
      expect(formatServings(2), '2');
      expect(formatServings(2.0), '2');
      expect(formatServings(10), '10');
    });

    test('one decimal place, rounded', () {
      expect(formatServings(1.5), '1.5');
      expect(formatServings(1.44), '1.4');
      expect(formatServings(1.46), '1.5');
      expect(formatServings(0.333), '0.3');
    });

    test('a rounding that lands on a whole number still loses the .0', () {
      expect(formatServings(1.98), '2');
    });
  });

  test('it is localized, not hardcoded English', () async {
    final nl = await AppLocalizations.delegate.load(const Locale('nl'));
    expect(gramsWithServings(nl, 100, 50), '100 g (2 porties)');
    expect(gramsWithServings(nl, 50, 50), '50 g (1 portie)');
  });
}
