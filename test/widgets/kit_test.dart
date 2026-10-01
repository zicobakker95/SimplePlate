// The design kit's behaviour: buttons, reduce-motion, appearance, and the
// Today screen's reactions (new-entry toast, target-window celebration).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/l10n/app_localizations.dart';
import 'package:simple_plate/models/food_entry.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/screens/home/today_screen.dart';
import 'package:simple_plate/services/food_store.dart';
import 'package:simple_plate/services/storage_service.dart';
import 'package:simple_plate/ui/kit.dart';
import 'package:simple_plate/ui/theme/appearance.dart';

import '../helpers/ui_harness.dart';

Widget host(Widget child, {FoodStore? store, bool reduceMotion = false}) {
  final app = MaterialApp(
    theme: buildPlateTheme(Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: c!,
    ),
    home: child,
  );
  return store == null
      ? app
      : ChangeNotifierProvider.value(value: store, child: app);
}

void main() {
  setUpAll(mockPlugins);

  group('PtButton', () {
    testWidgets('fires when enabled, not when disabled or loading',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(Scaffold(
        body: Column(children: [
          PtButton(label: 'Go', onPressed: () => taps++),
          const PtButton(label: 'Off', onPressed: null),
          PtButton(label: 'Busy', loading: true, onPressed: () => taps++),
        ]),
      )));
      await tester.tap(find.text('Go'));
      await tester.tap(find.text('Off'));
      await tester.tap(find.text('Busy'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(taps, 1);
    });

    testWidgets('meets the 48 dp tap target even when compact',
        (tester) async {
      await tester.pumpWidget(host(Scaffold(
        body: Center(
            child: PtButton(label: 'A', compact: true, onPressed: () {})),
      )));
      expect(tester.getSize(find.byType(PtButton)).height,
          greaterThanOrEqualTo(48));
    });
  });

  testWidgets('reduce motion shows entrances in their final state at once',
      (tester) async {
    await tester.pumpWidget(host(
      const Scaffold(body: FadeSlideIn(index: 5, child: Text('Hello'))),
      reduceMotion: true,
    ));
    await tester.pump();
    final opacity = find.ancestor(
        of: find.text('Hello'), matching: find.byType(Opacity));
    expect(opacity, findsNothing);
  });

  test('appearance defaults to the system and persists a choice', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final controller = AppearanceController(storage);
    expect(controller.value, ThemeMode.system);
    await controller.set(ThemeMode.dark);
    expect(AppearanceController(storage).value, ThemeMode.dark);
  });

  group('Today reactions', () {
    late FoodStore store;
    final en = lookupAppLocalizations(const Locale('en'));

    Future<void> pumpToday(WidgetTester tester, double eatenKcal) async {
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'sp.onboarding.v1': true,
        'sp.goals.v1':
            '{"dailyCalories":2000,"proteinGrams":150,"carbsGrams":200,"fatGrams":65}',
        'sp.entries.v1': [
          jsonEncode({
            'id': 'seed',
            'foodItemId': 'seed',
            'foodName': 'Breakfast bowl',
            'foodBrand': '',
            'servingGrams': 100,
            'caloriesPer100': eatenKcal,
            'proteinPer100': 10,
            'carbsPer100': 10,
            'fatPer100': 10,
            'meal': 'breakfast',
            'loggedAt': now.toIso8601String(),
          }),
        ],
      });
      store = FoodStore(await StorageService.init());
      await tester.pumpWidget(host(const TodayScreen(), store: store));
      await tester.pump(const Duration(seconds: 1));
    }

    const lunch = FoodItem(
      id: 'pasta',
      name: 'Pasta',
      caloriesPer100: 150,
      proteinPer100: 5,
      carbsPer100: 30,
      fatPer100: 1,
    );

    testWidgets('a newly logged food gets a toast naming it and its meal',
        (tester) async {
      await pumpToday(tester, 400);
      await store.logFood(lunch, 100, MealType.lunch);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(en.foodLoggedToast('Pasta', en.mealLunch)),
          findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('entering the target window celebrates once', (tester) async {
      await pumpToday(tester, 1600); // 80 %: below the window
      expect(find.text(en.goalReachedToast), findsNothing);
      await store.logFood(lunch, 100, MealType.lunch); // 1750 = 87.5 %
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(en.goalReachedToast), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('opening the app already on target does not celebrate',
        (tester) async {
      await pumpToday(tester, 1900);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(en.goalReachedToast), findsNothing);
    });
  });
}
