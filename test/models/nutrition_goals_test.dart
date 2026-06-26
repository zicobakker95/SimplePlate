import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/models/nutrition_goals.dart';

void main() {
  group('NutritionGoals', () {
    test('defaults are sensible', () {
      const goals = NutritionGoals.defaults();

      expect(goals.dailyCalories, 2000);
      expect(goals.proteinGrams, 150);
      expect(goals.carbsGrams, 200);
      expect(goals.fatGrams, 65);
    });

    test('toJson/fromJson round trip preserves all fields', () {
      const goals = NutritionGoals(
        dailyCalories: 2400,
        proteinGrams: 180,
        carbsGrams: 250,
        fatGrams: 70,
      );

      final decoded = NutritionGoals.fromJson(goals.toJson());

      expect(decoded.dailyCalories, goals.dailyCalories);
      expect(decoded.proteinGrams, goals.proteinGrams);
      expect(decoded.carbsGrams, goals.carbsGrams);
      expect(decoded.fatGrams, goals.fatGrams);
    });

    test('copyWith only overrides provided fields', () {
      const goals = NutritionGoals.defaults();

      final updated = goals.copyWith(dailyCalories: 1800);

      expect(updated.dailyCalories, 1800);
      expect(updated.proteinGrams, goals.proteinGrams);
      expect(updated.carbsGrams, goals.carbsGrams);
      expect(updated.fatGrams, goals.fatGrams);
    });
  });
}
