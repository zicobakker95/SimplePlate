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
  });
}
