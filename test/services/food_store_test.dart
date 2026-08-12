import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/models/food_entry.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/services/food_store.dart';
import 'package:simple_plate/services/storage_service.dart';

const _apple = FoodItem(
  id: 'apple',
  name: 'Apple',
  caloriesPer100: 52,
  proteinPer100: 0.3,
  carbsPer100: 14,
  fatPer100: 0.2,
);

void main() {
  group('FoodStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('logFood adds an entry visible in todayEntries and updates totals', () async {
      final store = FoodStore(await StorageService.init());

      await store.logFood(_apple, 200, MealType.breakfast);

      expect(store.todayEntries, hasLength(1));
      expect(store.todayCalories(), 104); // 52 * 200/100
    });

    test('logFood records the item in recents', () async {
      final store = FoodStore(await StorageService.init());

      await store.logFood(_apple, 150, MealType.snack);

      expect(store.recents.map((i) => i.id), contains('apple'));
    });

    test('deleteEntry removes the entry from todayEntries', () async {
      final store = FoodStore(await StorageService.init());
      await store.logFood(_apple, 100, MealType.lunch);
      final entryId = store.todayEntries.first.id;

      await store.deleteEntry(entryId);

      expect(store.todayEntries, isEmpty);
    });

    test('first log of the day sets streak to 1', () async {
      final store = FoodStore(await StorageService.init());

      await store.logFood(_apple, 100, MealType.dinner);

      expect(store.streak, 1);
    });

    test('logging again the same day does not double-count the streak', () async {
      final store = FoodStore(await StorageService.init());

      await store.logFood(_apple, 100, MealType.breakfast);
      await store.logFood(_apple, 50, MealType.snack);

      expect(store.streak, 1);
    });

    test('toggleFavourite adds then removes an item from favourites', () async {
      final store = FoodStore(await StorageService.init());

      await store.toggleFavourite(_apple);
      expect(store.isFavourite('apple'), true);

      await store.toggleFavourite(_apple);
      expect(store.isFavourite('apple'), false);
    });

    test('entries persist across FoodStore instances via StorageService', () async {
      final storage = await StorageService.init();
      final store = FoodStore(storage);
      await store.logFood(_apple, 100, MealType.breakfast);

      final reloaded = FoodStore(storage);

      expect(reloaded.todayEntries, hasLength(1));
    });

    group('editing a previous day', () {
      // Two entries logged three days ago — the case from the user request:
      // spotting a wrong portion after the fact.
      final past = DateTime.now().subtract(const Duration(days: 3));
      FoodEntry entry(String id, double grams) => FoodEntry(
            id: id,
            foodItemId: 'apple',
            foodName: 'Apple',
            servingGrams: grams,
            caloriesPer100: 52,
            proteinPer100: 0.3,
            carbsPer100: 14,
            fatPer100: 0.2,
            meal: MealType.lunch,
            loggedAt: past,
          );

      Future<FoodStore> seeded() async {
        final storage = await StorageService.init();
        await storage.saveEntries([entry('a', 200), entry('b', 100)]);
        return FoodStore(storage);
      }

      test('entriesForDay returns that day\'s entries', () async {
        final store = await seeded();
        expect(store.entriesForDay(past), hasLength(2));
        expect(store.caloriesTotalsForDay(past), closeTo(156, 0.001));
      });

      test('updateEntryServing recomputes that day\'s totals', () async {
        final store = await seeded();

        await store.updateEntryServing('a', 50); // 200 g -> 50 g

        final entries = store.entriesForDay(past);
        expect(entries.firstWhere((e) => e.id == 'a').servingGrams, 50);
        // 52*50/100 + 52*100/100 = 26 + 52
        expect(store.caloriesTotalsForDay(past), closeTo(78, 0.001));
      });

      test('deleteEntry removes it and updates that day\'s totals', () async {
        final store = await seeded();

        await store.deleteEntry('a');

        expect(store.entriesForDay(past), hasLength(1));
        expect(store.caloriesTotalsForDay(past), closeTo(52, 0.001));
      });

      test('edits survive a reload and do not touch other days', () async {
        final storage = await StorageService.init();
        await storage.saveEntries([entry('a', 200), entry('b', 100)]);
        final store = FoodStore(storage);
        await store.logFood(_apple, 100, MealType.breakfast); // today

        await store.deleteEntry('b');

        final reloaded = FoodStore(storage);
        expect(reloaded.entriesForDay(past), hasLength(1));
        expect(reloaded.todayEntries, hasLength(1),
            reason: 'today must be unaffected by editing a past day');
      });
    });
  });
}
