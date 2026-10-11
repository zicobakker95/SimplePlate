import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/cross_promo.dart';
import 'package:simple_plate/l10n/app_localizations.dart';
import 'package:simple_plate/screens/goals/goals_screen.dart';
import 'package:simple_plate/services/food_store.dart';
import 'package:simple_plate/services/storage_service.dart';
import 'package:simple_plate/ui/theme/appearance.dart';
import 'package:simple_plate/ui/theme/plate_theme.dart';

import 'helpers/ui_harness.dart';

/// Settings' "More from ZiBa" list, the Rate row and the feedback link.
void main() {
  setUpAll(mockPlugins);

  test(
    'the catalogue lists the published apps, La Famiglia in, Sip Sip Hooray out',
    () {
      expect(kZibaApps.map((a) => a.id).toList(), [
        'deadlight',
        'lafamiglia',
        'klacksort',
        'klack',
        'streaks',
        'platesimple',
        'medmate',
        'wordwaves',
      ]);
      final lf = kZibaApps.firstWhere((a) => a.id == 'lafamiglia');
      expect(lf.androidId, 'com.zibagames.la_famiglia_mobile');
      expect(lf.appleId, isEmpty);
      expect(
        kZibaApps.firstWhere((a) => a.id == 'platesimple').appleId,
        kSelfAppleId,
      );
    },
  );

  test('every app has its store icon under assets/promo', () {
    for (final a in kZibaApps) {
      expect(File(a.iconAsset).existsSync(), isTrue, reason: a.iconAsset);
    }
    expect(File('assets/promo/sipsiphooray.png').existsSync(), isFalse);
  });

  test(
    'on iOS an app with no App Store listing is hidden, never sent to Play',
    () {
      final android = zibaAppsFor(
        selfId: 'platesimple',
        platform: TargetPlatform.android,
      );
      final ios = zibaAppsFor(
        selfId: 'platesimple',
        platform: TargetPlatform.iOS,
      );
      expect(android.map((a) => a.id), contains('lafamiglia'));
      expect(ios.map((a) => a.id), isNot(contains('lafamiglia')));
      expect(ios.every((a) => a.appleId.isNotEmpty), isTrue);
      expect(android.map((a) => a.id), isNot(contains('platesimple')));
    },
  );

  test('feedback names the app', () {
    expect(
      kFeedbackUri.toString(),
      'https://zibaentertainment.com/feedback/?app=platesimple',
    );
  });

  test('every language has the Rate row', () {
    final en = lookupAppLocalizations(const Locale('en'));
    for (final locale in AppLocalizations.supportedLocales) {
      final l = lookupAppLocalizations(locale);
      expect(l.rateApp, contains('PlateSimple'), reason: '$locale');
      expect(l.rateAppSub, isNotEmpty, reason: '$locale');
      if (locale.languageCode != 'en') {
        expect(l.rateApp, isNot(en.rateApp), reason: '$locale is English');
      }
    }
  });

  testWidgets('settings has Rate, Share feedback and More from ZiBa', (
    tester,
  ) async {
    await usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues(seededPrefs());
    final storage = (await tester.runAsync(StorageService.init))!;
    final store = FoodStore(storage);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: store),
          ChangeNotifierProvider(create: (_) => AppearanceController(storage)),
        ],
        child: MaterialApp(
          theme: buildPlateTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GoalsScreen(),
        ),
      ),
    );
    await settle(tester);
    final list = find.byType(Scrollable).first;
    for (final key in ['settings_feedback', 'settings_rate']) {
      await tester.scrollUntilVisible(
        find.byKey(Key(key)),
        300,
        scrollable: list,
      );
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(find.text('Rate PlateSimple'), findsOneWidget);
    // No store or browser in a test: the taps must simply not throw.
    await tester.tap(find.byKey(const Key('settings_rate')));
    await tester.tap(find.byKey(const Key('settings_feedback')));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('ziba_app_wordwaves')),
      300,
      scrollable: list,
    );
    expect(find.byKey(const Key('ziba_app_platesimple')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
