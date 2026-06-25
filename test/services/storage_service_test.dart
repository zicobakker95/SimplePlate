import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/models/food_entry.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/models/nutrition_goals.dart';
import 'package:simple_plate/services/storage_service.dart';

void main() {
  group('StorageService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadGoals returns defaults when nothing is stored', () async {
      final storage = await StorageService.init();

      expect(storage.loadGoals(), const NutritionGoals.defaults());
    });

    test('loadGoals falls back to defaults instead of throwing on corrupted data', () async {
      SharedPreferences.setMockInitialValues({'sp.goals.v1': 'not valid json {{{'});
      final storage = await StorageService.init();

      expect(storage.loadGoals(), const NutritionGoals.defaults());
    });

    test('saveGoals/loadGoals round trip', () async {
      final storage = await StorageService.init();
      const goals = NutritionGoals(
          dailyCalories: 2200, proteinGrams: 160, carbsGrams: 220, fatGrams: 60);

      await storage.saveGoals(goals);

      expect(storage.loadGoals().dailyCalories, 2200);
    });

    test('saveEntries/loadEntries round trip', () async {
      final storage = await StorageService.init();
      final entries = [
        FoodEntry(
          id: '1',
          foodItemId: 'f1',
          foodName: 'Eggs',
          servingGrams: 100,
          caloriesPer100: 155,
          proteinPer100: 13,
          carbsPer100: 1.1,
          fatPer100: 11,
          meal: MealType.breakfast,
          loggedAt: DateTime(2026, 6, 25, 8),
        ),
      ];

      await storage.saveEntries(entries);
      final loaded = storage.loadEntries();

      expect(loaded, hasLength(1));
      expect(loaded.first.foodName, 'Eggs');
    });

    test('loadEntries skips corrupted entries instead of losing the whole list', () async {
      final goodEntry = FoodEntry(
        id: '1',
        foodItemId: 'f1',
        foodName: 'Eggs',
        servingGrams: 100,
        caloriesPer100: 155,
        proteinPer100: 13,
        carbsPer100: 1.1,
        fatPer100: 11,
        meal: MealType.breakfast,
        loggedAt: DateTime(2026, 6, 25, 8),
      );
      SharedPreferences.setMockInitialValues({
        'sp.entries.v1': [
          '{"this": "is", "missing": "required fields"}',
          jsonEncode(goodEntry.toJson()),
          'not even json',
        ],
      });
      final storage = await StorageService.init();

      final loaded = storage.loadEntries();

      expect(loaded, hasLength(1));
      expect(loaded.first.foodName, 'Eggs');
    });

    test('loadFavourites skips corrupted entries instead of throwing', () async {
      const goodItem = FoodItem(
        id: 'x',
        name: 'Banana',
        caloriesPer100: 89,
        proteinPer100: 1.1,
        carbsPer100: 22.8,
        fatPer100: 0.3,
      );
      SharedPreferences.setMockInitialValues({
        'sp.favourites.v1': ['{garbage', jsonEncode(goodItem.toJson())],
      });
      final storage = await StorageService.init();

      final loaded = storage.loadFavourites();

      expect(loaded, hasLength(1));
      expect(loaded.first.name, 'Banana');
    });

    test('onboarding flag defaults to false and persists once set', () async {
      final storage = await StorageService.init();

      expect(storage.onboardingDone, false);

      await storage.setOnboardingDone(true);

      expect(storage.onboardingDone, true);
    });
  });
}
