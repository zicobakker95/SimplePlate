// Open Food Facts ranks by popularity, which puts "Banana Flavoured Yoghurt
// Drink" above a banana. The re-rank is what makes the list feel right, and
// it is also where a bad result is allowed to disappear.
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/services/openfoodfacts_service.dart';

FoodItem food(String name,
        {String brand = '',
        double kcal = 100,
        bool complete = true,
        String? id}) =>
    FoodItem(
      id: id ?? name,
      name: name,
      brand: brand,
      caloriesPer100: kcal,
      proteinPer100: 1,
      carbsPer100: 1,
      fatPer100: 1,
      hasCompleteNutrition: complete,
    );

List<String> names(List<FoodItem> items) => items.map((i) => i.name).toList();

void main() {
  group('rankResults', () {
    test('an exact name match comes first, whatever the popularity order', () {
      final ranked = OpenFoodFactsService.rankResults([
        food('Banana Flavoured Yoghurt Drink', brand: 'Yop'),
        food('Banana chips'),
        food('Banana'),
      ], 'banana');
      expect(names(ranked).first, 'Banana');
    });

    test('exact match is case- and whitespace-insensitive', () {
      final ranked = OpenFoodFactsService.rankResults([
        food('banana bread'),
        food('BANANA'),
      ], '  Banana ');
      expect(names(ranked).first, 'BANANA');
    });

    test('complete nutrition outranks a partial entry with the same name', () {
      final ranked = OpenFoodFactsService.rankResults([
        food('Oats', id: 'partial', complete: false),
        food('Oats', id: 'complete', complete: true),
      ], 'oats');
      expect(ranked.first.id, 'complete');
    });

    test('complete nutrition beats a slightly better name match', () {
      // A whole-word match with everything stated is more useful to log than
      // a prefix match that will leave the macro bars empty.
      final ranked = OpenFoodFactsService.rankResults([
        food('Chicken breast fillet', complete: false),
        food('Grilled chicken', complete: true),
      ], 'chicken');
      expect(names(ranked).first, 'Grilled chicken');
    });

    test('results without calorie data are dropped, not merely demoted', () {
      final ranked = OpenFoodFactsService.rankResults([
        food('Chocolate', kcal: 0),
        food('Chocolate bar', kcal: 530),
      ], 'chocolate');
      expect(names(ranked), ['Chocolate bar']);
    });

    test('ties keep the incoming (popularity) order', () {
      final ranked = OpenFoodFactsService.rankResults([
        food('Apple juice', id: 'a'),
        food('Apple sauce', id: 'b'),
        food('Apple pie', id: 'c'),
      ], 'apple');
      expect(ranked.map((i) => i.id), ['a', 'b', 'c']);
    });

    test('an empty query leaves order alone but still drops zero-calorie rows',
        () {
      final ranked = OpenFoodFactsService.rankResults([
        food('Water', kcal: 0),
        food('Milk', kcal: 64),
      ], '');
      expect(names(ranked), ['Milk']);
    });
  });

  group('parseProduct completeness', () {
    test('all four nutriments stated → complete', () {
      final item = OpenFoodFactsService.parseProduct('1', {
        'product_name': 'Rice',
        'nutriments': {
          'energy-kcal_100g': 130,
          'proteins_100g': 2.7,
          'carbohydrates_100g': 28,
          'fat_100g': 0.3,
        },
      });
      expect(item.hasCompleteNutrition, isTrue);
    });

    test('a missing macro → incomplete, even when calories are present', () {
      final item = OpenFoodFactsService.parseProduct('1', {
        'product_name': 'Rice',
        'nutriments': {'energy-kcal_100g': 130, 'proteins_100g': 2.7},
      });
      expect(item.hasCompleteNutrition, isFalse);
      expect(item.caloriesPer100, 130);
    });

    test('a stated zero counts as stated', () {
      final item = OpenFoodFactsService.parseProduct('1', {
        'product_name': 'Cola',
        'nutriments': {
          'energy-kcal_100g': 42,
          'proteins_100g': 0,
          'carbohydrates_100g': '10.6',
          'fat_100g': 0,
        },
      });
      expect(item.hasCompleteNutrition, isTrue);
    });
  });
}
