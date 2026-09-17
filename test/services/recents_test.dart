// The list shown before typing: the last 30 distinct foods, newest first.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/models/food_entry.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/services/food_store.dart';
import 'package:simple_plate/services/storage_service.dart';

FoodItem food(String id, [String? name]) => FoodItem(
      id: id,
      name: name ?? id,
      caloriesPer100: 100,
      proteinPer100: 1,
      carbsPer100: 1,
      fatPer100: 1,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<FoodStore> store() async => FoodStore(await StorageService.init());

  test('most recently logged food comes first', () async {
    final s = await store();
    await s.logFood(food('apple'), 100, MealType.breakfast);
    await s.logFood(food('bread'), 100, MealType.lunch);

    expect(s.recents.map((i) => i.id), ['bread', 'apple']);
  });

  test('logging a food again moves it to the front instead of duplicating',
      () async {
    final s = await store();
    await s.logFood(food('apple'), 100, MealType.breakfast);
    await s.logFood(food('bread'), 100, MealType.lunch);
    await s.logFood(food('apple'), 50, MealType.snack);

    expect(s.recents.map((i) => i.id), ['apple', 'bread']);
  });

  test('keeps the last 30 distinct foods', () async {
    final s = await store();
    for (var i = 0; i < 35; i++) {
      await s.logFood(food('f$i'), 100, MealType.snack);
    }

    expect(s.recents, hasLength(FoodStore.maxRecents));
    expect(s.recents.first.id, 'f34');
    expect(s.recents.last.id, 'f5');
  });

  test('recents survive a restart', () async {
    final storage = await StorageService.init();
    final s = FoodStore(storage);
    await s.logFood(food('apple'), 100, MealType.breakfast);

    expect(FoodStore(storage).recents.map((i) => i.id), ['apple']);
  });

  group('localMatches', () {
    test('matches recents, custom foods and favourites by name or brand',
        () async {
      final s = await store();
      await s.logFood(food('r1', 'Greek yoghurt'), 100, MealType.breakfast);
      await s.addCustomFood(food('c1', 'Mum\'s lasagne'));
      await s.toggleFavourite(const FoodItem(
        id: 'fav1',
        name: 'Protein bar',
        brand: 'Yoghurt Co',
        caloriesPer100: 400,
        proteinPer100: 30,
        carbsPer100: 40,
        fatPer100: 10,
      ));

      expect(s.localMatches('yog').map((i) => i.id), ['r1', 'fav1']);
      expect(s.localMatches('LASAGNE').map((i) => i.id), ['c1']);
      expect(s.localMatches('pizza'), isEmpty);
      expect(s.localMatches('  '), isEmpty);
    });

    test('a food that is both recent and custom appears once, as recent',
        () async {
      final s = await store();
      final lasagne = food('c1', 'Lasagne');
      await s.addCustomFood(lasagne);
      await s.logFood(lasagne, 200, MealType.dinner);

      expect(s.localMatches('lasagne'), hasLength(1));
    });
  });
}
