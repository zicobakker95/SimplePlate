// The on-device cache: a hit inside 30 days, a miss after, and never a
// cached nothing.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/services/database.dart';
import 'package:simple_plate/services/food_cache.dart';

const banana = FoodItem(
  id: '3017620422003',
  name: 'Banana',
  caloriesPer100: 89,
  proteinPer100: 1.1,
  carbsPer100: 23,
  fatPer100: 0.3,
  servingSizeGrams: 120,
);

void main() {
  late AppDatabase db;
  late DateTime now;
  late FoodCache cache;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    now = DateTime(2026, 9, 1, 12);
    cache = FoodCache(db, clock: () => now);
  });

  tearDown(() => db.close());

  test('a stored search comes back intact', () async {
    await cache.putSearch('Banana', [banana]);

    final hit = await cache.getSearch('banana');

    expect(hit, isNotNull);
    expect(hit!.single.name, 'Banana');
    expect(hit.single.servingSizeGrams, 120);
    expect(hit.single.hasCompleteNutrition, isTrue);
  });

  test('queries are normalised: case, trim and inner whitespace', () async {
    await cache.putSearch('  Peanut   Butter ', [banana]);
    expect(await cache.getSearch('peanut butter'), isNotNull);
    expect(FoodCache.normalise('  Peanut   Butter '), 'peanut butter');
  });

  test('a miss is null, and an empty result is never stored', () async {
    expect(await cache.getSearch('nothing'), isNull);
    await cache.putSearch('nothing', const []);
    expect(await cache.getSearch('nothing'), isNull);
  });

  test('still served on day 29, gone on day 31', () async {
    await cache.putSearch('banana', [banana]);

    now = now.add(const Duration(days: 29));
    expect(await cache.getSearch('banana'), isNotNull);

    now = now.add(const Duration(days: 2));
    expect(await cache.getSearch('banana'), isNull);
  });

  test('an expired read prunes the row rather than leaving it around',
      () async {
    await cache.putSearch('banana', [banana]);
    await cache.putBarcode('111', banana);
    now = now.add(const Duration(days: 40));

    await cache.getSearch('banana');

    expect(await db.searchCacheFor('banana'), isNull);
    expect(await db.barcodeCacheFor('111'), isNull);
  });

  test('a fresh search overwrites the old row and its timestamp', () async {
    await cache.putSearch('banana', [banana]);
    now = now.add(const Duration(days: 20));
    await cache.putSearch('banana', [banana.copyWith(isFavourite: true)]);

    now = now.add(const Duration(days: 20)); // 40 after the first, 20 after
    expect(await cache.getSearch('banana'), isNotNull);
  });

  group('barcodes', () {
    test('hit inside the TTL, miss after it', () async {
      await cache.putBarcode('3017620422003', banana);
      expect((await cache.getBarcode('3017620422003'))?.name, 'Banana');

      now = now.add(const Duration(days: 31));
      expect(await cache.getBarcode('3017620422003'), isNull);
    });

    test('unknown barcode is a miss', () async {
      expect(await cache.getBarcode('000'), isNull);
    });
  });
}
