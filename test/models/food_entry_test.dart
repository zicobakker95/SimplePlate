import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/models/food_entry.dart';

void main() {
  group('FoodEntry', () {
    test('toJson/fromJson round trip preserves all fields', () {
      final entry = FoodEntry(
        id: 'e1',
        foodItemId: 'f1',
        foodName: 'Chicken breast',
        foodBrand: 'Generic',
        servingGrams: 150,
        caloriesPer100: 165,
        proteinPer100: 31,
        carbsPer100: 0,
        fatPer100: 3.6,
        meal: MealType.lunch,
        loggedAt: DateTime(2026, 6, 25, 12, 30),
      );

      final decoded = FoodEntry.fromJson(entry.toJson());

      expect(decoded.id, entry.id);
      expect(decoded.foodItemId, entry.foodItemId);
      expect(decoded.foodName, entry.foodName);
      expect(decoded.foodBrand, entry.foodBrand);
      expect(decoded.servingGrams, entry.servingGrams);
      expect(decoded.meal, entry.meal);
      expect(decoded.loggedAt, entry.loggedAt);
    });

    test('falls back to MealType.snack for an unrecognized meal value', () {
      final decoded = FoodEntry.fromJson({
        'id': 'e1',
        'foodItemId': 'f1',
        'foodName': 'Mystery food',
        'servingGrams': 100,
        'caloriesPer100': 100,
        'proteinPer100': 1,
        'carbsPer100': 1,
        'fatPer100': 1,
        'meal': 'brunch',
        'loggedAt': DateTime(2026, 1, 1).toIso8601String(),
      });

      expect(decoded.meal, MealType.snack);
    });

    test('calories/protein/carbs/fat scale with servingGrams', () {
      final entry = FoodEntry(
        id: 'e1',
        foodItemId: 'f1',
        foodName: 'Oats',
        servingGrams: 50,
        caloriesPer100: 389,
        proteinPer100: 17,
        carbsPer100: 66,
        fatPer100: 7,
        meal: MealType.breakfast,
        loggedAt: DateTime(2026, 6, 25),
      );

      expect(entry.calories, closeTo(194.5, 0.001));
      expect(entry.protein, 8.5);
      expect(entry.carbs, 33);
      expect(entry.fat, 3.5);
    });
  });
}
