// The fallback chain, driven with a fake HTTP client: an endpoint that
// errors is skipped, one that answers empty is only believed once they all
// have, and the user gets an exception only when nothing answered at all.
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simple_plate/services/openfoodfacts_service.dart';

String body(List<Map<String, Object>> products) =>
    jsonEncode({'products': products});

Map<String, Object> product(String code, String name) => {
      'code': code,
      'product_name': name,
      'nutriments': {
        'energy-kcal_100g': 89,
        'proteins_100g': 1.1,
        'carbohydrates_100g': 23,
        'fat_100g': 0.3,
      },
    };

void main() {
  test('country mirror answers → nothing else is asked', () async {
    final asked = <String>[];
    final svc = OpenFoodFactsService(
      client: MockClient((req) async {
        asked.add(req.url.host);
        return http.Response(body([product('1', 'Banaan')]), 200);
      }),
    );

    final items = await svc.search('banaan', locale: const Locale('nl', 'NL'));

    expect(items.map((i) => i.name), ['Banaan']);
    expect(asked, ['nl.openfoodfacts.org']);
  });

  test('country empty, .net errors → world search.pl answer is used', () async {
    final asked = <String>[];
    final svc = OpenFoodFactsService(
      client: MockClient((req) async {
        asked.add(req.url.host);
        switch (req.url.host) {
          case 'nl.openfoodfacts.org':
            return http.Response(body([]), 200);
          case 'world.openfoodfacts.net':
            return http.Response('boom', 503);
          default:
            return http.Response(body([product('2', 'Banana')]), 200);
        }
      }),
    );

    final items = await svc.search('banana', locale: const Locale('nl', 'NL'));

    expect(items.map((i) => i.name), ['Banana']);
    expect(asked, [
      'nl.openfoodfacts.org',
      'world.openfoodfacts.net',
      'world.openfoodfacts.org',
    ]);
  });

  test('every endpoint empty → an empty list, not an error', () async {
    final svc = OpenFoodFactsService(
      client: MockClient((_) async => http.Response(body([]), 200)),
    );
    expect(await svc.search('zzzz'), isEmpty);
  });

  test('every endpoint failing → OpenFoodFactsException', () async {
    final svc = OpenFoodFactsService(
      client: MockClient((_) async => http.Response('down', 500)),
    );
    expect(svc.search('banana'), throwsA(isA<OpenFoodFactsException>()));
  });

  test('a hanging endpoint is abandoned after the timeout', () async {
    final svc = OpenFoodFactsService(
      timeout: const Duration(milliseconds: 50),
      client: MockClient((req) async {
        if (req.url.host == 'world.openfoodfacts.net') {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
        return http.Response(body([product('3', 'Banana')]), 200);
      }),
    );

    final sw = Stopwatch()..start();
    final items = await svc.search('banana');
    expect(items, isNotEmpty);
    expect(sw.elapsed, lessThan(const Duration(seconds: 1)));
  });
}
