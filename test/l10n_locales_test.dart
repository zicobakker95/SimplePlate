import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:simple_plate/l10n/l10n.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _placeholders(String s) =>
    RegExp(r'\{([a-zA-Z_]\w*)\}').allMatches(s).map((m) => m[1]!).toSet();

void main() {
  const supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('pl'),
    Locale('it'),
    Locale('zh'),
  ];

  group('ARB parity', () {
    final en = _arb('en');
    final keys = en.keys.where((k) => !k.startsWith('@')).toList();
    for (final code in ['tr', 'pl', 'it', 'zh_Hant']) {
      test('$code has every key with the same placeholders', () {
        final t = _arb(code);
        for (final k in keys) {
          expect(t.containsKey(k), isTrue, reason: '$code missing $k');
          expect(
            _placeholders(t[k] as String),
            _placeholders(en[k] as String),
            reason: '$code $k',
          );
          expect('\n'.allMatches(t[k] as String).length,
              '\n'.allMatches(en[k] as String).length,
              reason: '$code $k newlines');
        }
      });
    }

    test('Polish plurals carry few and many', () {
      final t = _arb('pl');
      for (final k in keys) {
        if ((en[k] as String).contains('{count, plural')) {
          final s = t[k] as String;
          if (s.contains('plural')) {
            expect(s, contains('few{'), reason: k);
            expect(s, contains('many{'), reason: k);
          }
        }
      }
    });

    test('Traditional Chinese has no non-Big5 CJK characters', () {
      final s = (_arb('zh_Hant').values.whereType<String>()).join();
      // Dart has no Big5 codec; the full Big5 check is done with Python when
      // translating. Here: no kana, no common Simplified-only forms.
      expect(RegExp(r'[぀-ヿ]').hasMatch(s), isFalse);
      for (final simp in ['计', '热', '饮', '记', '时', '设', '数', '体']) {
        expect(s.contains(simp), isFalse, reason: simp);
      }
    });
  });

  group('locale resolution', () {
    Locale? r(Locale d) => resolveAppLocale(d, supportedLocales);

    test('zh_TW / HK / MO / Hant resolve to Traditional', () {
      for (final d in [
        const Locale('zh', 'TW'),
        const Locale('zh', 'HK'),
        const Locale('zh', 'MO'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
      ]) {
        final out = r(d)!;
        expect(out.languageCode, 'zh', reason: '$d');
        expect(out.scriptCode, 'Hant', reason: '$d');
      }
    });

    test('Simplified Chinese stays out of the Traditional text', () {
      expect(r(const Locale('zh', 'CN')), const Locale('en'));
      expect(
        r(Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')),
        const Locale('en'),
      );
    });

    test('other languages match by language code', () {
      expect(r(const Locale('tr', 'TR')), const Locale('tr'));
      expect(r(const Locale('pl', 'PL')), const Locale('pl'));
      expect(r(const Locale('it', 'CH')), const Locale('it'));
      expect(r(const Locale('sv')), const Locale('en'));
    });
  });

  group('dates and case', () {
    setUpAll(() async {
      for (final l in ['tr', 'pl', 'it', 'zh_TW']) {
        await initializeDateFormatting(l);
      }
    });

    test('Traditional Chinese dates format with zh_TW', () {
      final d = DateTime(2026, 11, 2);
      expect(DateFormat('MMM d', 'zh_TW').format(d), contains('11'));
      expect(DateFormat('EEEE', 'zh_TW').format(d), contains('星期'));
    });

    testWidgets('Turkish upper-casing keeps the dotted İ', (tester) async {
      late String tr, en;
      Future<void> pump(Locale l, void Function(BuildContext) f) async {
        await tester.pumpWidget(MaterialApp(
          locale: l,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (c) {
            f(c);
            return const SizedBox();
          }),
        ));
      }

      await pump(const Locale('tr'), (c) => tr = 'iyi gün ılık'.upperFor(c));
      await pump(const Locale('en'), (c) => en = 'iyi'.upperFor(c));
      expect(tr, 'İYİ GÜN ILIK');
      expect(en, 'IYI');
    });
  });
}
