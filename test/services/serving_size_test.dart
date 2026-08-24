// Open Food Facts is crowd-sourced, and `serving_size` is free text typed by
// strangers: "30 g", "30g", "1 cup (240 ml)", "2 biscuits". A serving count is
// shown to someone counting calories, so a wrong one is worse than none —
// every case that cannot be trusted must come back null.
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/services/openfoodfacts_service.dart';

double? parse(Object? quantity, [String? sizeText]) =>
    OpenFoodFactsService.servingGramsFromProduct({
      if (quantity != null) 'serving_quantity': quantity,
      if (sizeText != null) 'serving_size': sizeText,
    });

void main() {
  group('serving_quantity, the clean field', () {
    test('a number is taken as grams', () => expect(parse(30), 30));
    test('a numeric string is parsed', () => expect(parse('45.5'), 45.5));
    test('junk in the field falls through', () => expect(parse('about one'), isNull));
  });

  group('serving_size free text, the messy field', () {
    test('grams in the forms people actually type', () {
      expect(parse(null, '30 g'), 30);
      expect(parse(null, '30g'), 30);
      expect(parse(null, '30 grams'), 30);
      expect(parse(null, '12,5 g'), 12.5, reason: 'comma decimal separator');
      expect(parse(null, '100 g (2 servings)'), 100);
    });

    test('anything not stated in grams is refused', () {
      expect(parse(null, '250 ml'), isNull);
      expect(parse(null, '1 cup (240 ml)'), isNull);
      expect(parse(null, '2 biscuits'), isNull);
      expect(parse(null, ''), isNull);
      expect(parse(null, '3 gallon'), isNull,
          reason: 'a bare g-match takes the 3 out of "gallon"');
    });
  });

  group('values that would produce nonsense', () {
    test('zero and negatives, which would divide by zero', () {
      expect(parse(0), isNull);
      expect(parse(-5), isNull);
    });

    test('an absurd serving is bad data, not a serving', () {
      // Every amount would render as 0.0 servings.
      expect(parse(5000), isNull);
      expect(parse(2001), isNull);
      expect(parse(2000), 2000, reason: 'the bound itself is still allowed');
    });

    test('a product that says nothing yields nothing', () {
      expect(OpenFoodFactsService.servingGramsFromProduct(const {}), isNull);
    });
  });

  test('serving_quantity wins over the free text when both are present', () {
    expect(parse(30, '999 g'), 30);
  });
}
