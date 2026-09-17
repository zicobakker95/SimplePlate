// Cache and live search combined, as the screen sees it.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/services/database.dart';
import 'package:simple_plate/services/food_cache.dart';
import 'package:simple_plate/services/food_search_service.dart';
import 'package:simple_plate/services/openfoodfacts_service.dart';

const apple = FoodItem(
  id: '1',
  name: 'Apple',
  caloriesPer100: 52,
  proteinPer100: 0.3,
  carbsPer100: 14,
  fatPer100: 0.2,
);

const liveBody =
    '{"products":[{"code":"2","product_name":"Apple pie","nutriments":{"energy-kcal_100g":237,"proteins_100g":2,"carbohydrates_100g":34,"fat_100g":11}}]}';

void main() {
  late AppDatabase db;
  late FoodCache cache;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    cache = FoodCache(db);
  });
  tearDown(() => db.close());

  FoodSearchService service(MockClient client,
          {Duration cacheAfter = const Duration(milliseconds: 100)}) =>
      FoodSearchService(
        api: OpenFoodFactsService(
            client: client, timeout: const Duration(milliseconds: 300)),
        cache: cache,
        cacheAfter: cacheAfter,
      );

  test('a fast live answer is the only event, and it is cached', () async {
    final svc = service(MockClient((_) async => http.Response(liveBody, 200)));

    final events = await svc.search('apple').toList();

    expect(events, hasLength(1));
    expect(events.single.fromCache, isFalse);
    expect(events.single.items.single.name, 'Apple pie');
    expect(await cache.getSearch('apple'), isNotNull);
  });

  test('a slow live answer is preceded by the cached one', () async {
    await cache.putSearch('apple', [apple]);
    final svc = service(MockClient((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return http.Response(liveBody, 200);
    }));

    final events = await svc.search('apple').toList();

    expect(events.map((e) => e.fromCache), [true, false]);
    expect(events.first.items.single.name, 'Apple');
    expect(events.last.items.single.name, 'Apple pie');
  });

  test('offline with a cache → the cached list, flagged offline', () async {
    await cache.putSearch('apple', [apple]);
    final svc = service(MockClient((_) async => http.Response('', 503)));

    final events = await svc.search('apple').toList();

    expect(events.last.fromCache, isTrue);
    expect(events.last.offline, isTrue);
    expect(events.last.items.single.name, 'Apple');
  });

  test('offline with no cache → an error, never an empty list', () async {
    final svc = service(MockClient((_) async => http.Response('', 503)));
    expect(svc.search('apple').toList(),
        throwsA(isA<OpenFoodFactsException>()));
  });

  test('barcode: cache first, network only on a miss', () async {
    var calls = 0;
    final svc = service(MockClient((_) async {
      calls++;
      return http.Response(
          '{"status":1,"product":{"product_name":"Cola","nutriments":{"energy-kcal_100g":42}}}',
          200);
    }));

    expect((await svc.lookupBarcode('555'))?.name, 'Cola');
    expect((await svc.lookupBarcode('555'))?.name, 'Cola');
    expect(calls, 1);
  });
}
