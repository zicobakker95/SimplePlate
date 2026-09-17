// Which Open Food Facts mirror a phone asks first. The country subdomain
// ranks locally-sold products first, which is the difference between
// "banana" finding a banana and finding a yoghurt.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/services/openfoodfacts_service.dart';

void main() {
  group('countrySubdomain', () {
    test('uses the region when the locale has one', () {
      expect(OpenFoodFactsService.countrySubdomain(const Locale('nl', 'NL')),
          'nl');
      expect(OpenFoodFactsService.countrySubdomain(const Locale('de', 'AT')),
          'at');
      expect(OpenFoodFactsService.countrySubdomain(const Locale('en', 'US')),
          'us');
    });

    test('maps Open Food Facts\' exceptions to its own naming', () {
      expect(OpenFoodFactsService.countrySubdomain(const Locale('en', 'GB')),
          'uk');
    });

    test('falls back to a sensible country for a bare shipped language', () {
      expect(OpenFoodFactsService.countrySubdomain(const Locale('nl')), 'nl');
      expect(OpenFoodFactsService.countrySubdomain(const Locale('ja')), 'jp');
      expect(OpenFoodFactsService.countrySubdomain(const Locale('pt')), 'br');
    });

    test('is "world" when there is nothing to go on', () {
      expect(OpenFoodFactsService.countrySubdomain(null), 'world');
      expect(OpenFoodFactsService.countrySubdomain(const Locale('en')), 'world');
      expect(OpenFoodFactsService.countrySubdomain(const Locale('xx')), 'world');
    });

    test('an odd region code is not turned into a hostname', () {
      expect(
          OpenFoodFactsService.countrySubdomain(const Locale('en', '419')),
          'world');
    });
  });

  group('searchUris', () {
    test('country first, then the .net mirror, then world search.pl', () {
      final hosts = OpenFoodFactsService.searchUris('banana',
              locale: const Locale('nl', 'NL'))
          .map((u) => u.host)
          .toList();
      expect(hosts, [
        'nl.openfoodfacts.org',
        'world.openfoodfacts.net',
        'world.openfoodfacts.org',
      ]);
    });

    test('no country → no duplicate world entry', () {
      final hosts = OpenFoodFactsService.searchUris('banana')
          .map((u) => u.host)
          .toList();
      expect(hosts, ['world.openfoodfacts.net', 'world.openfoodfacts.org']);
    });

    test('every endpoint is the CGI search with the query encoded', () {
      for (final uri in OpenFoodFactsService.searchUris('pain au chocolat',
          locale: const Locale('fr', 'FR'))) {
        expect(uri.path, '/cgi/search.pl');
        expect(uri.queryParameters['search_terms'], 'pain au chocolat');
        expect(uri.queryParameters['json'], '1');
      }
    });
  });
}
