// Screenshot capture harness for App Store / Google Play marketing shots.
//
// Seeds SharedPreferences with realistic sample data, pumps the real app,
// and captures the Today / History / Goals / Add-food screens as PNGs.
//
// Run on a booted simulator or emulator:
//   flutter drive \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/screenshot_test.dart \
//     -d <device-id>
//
// Raw PNGs are written to store/screenshots/raw/ by the driver, then
// post-processed into store-ready sizes by store/screenshots/frame_screenshots.py
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simple_plate/main.dart';
import 'package:simple_plate/services/storage_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(_seedData());
  });

  // Video walkthrough: hold each screen in real time (recorded by simctl recordVideo).
  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    await Future<void>.delayed(const Duration(seconds: 3));
    await tester.pump();
  }

  testWidgets('capture store screenshots', (tester) async {
    final storage = await StorageService.init();
    await tester.pumpWidget(SimplePlateApp(storage: storage));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 1) Today
    await shot(tester, '01_today');

    // 2) History — second bottom-nav destination
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    await shot(tester, '02_history');

    // 3) Goals — third bottom-nav destination
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();
    await shot(tester, '03_goals');

    // 4) Add food — back to Today, then FAB
    await tester.tap(find.byIcon(Icons.restaurant_menu_outlined));
    await tester.pumpAndSettle();
    final fab = find.text('Log food');
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();
      await shot(tester, '04_add_food');
    }
  });
}

/// Realistic sample data so the screenshots look populated, not empty.
Map<String, Object> _seedData() {
  String entry({
    required String id,
    required String name,
    String brand = '',
    required double grams,
    required double kcal,
    required double p,
    required double c,
    required double f,
    required String meal,
    required int hour,
  }) {
    final now = DateTime.now();
    final at = DateTime(now.year, now.month, now.day, hour, 0)
        .toIso8601String();
    return '{"id":"$id","foodItemId":"$id","foodName":"$name",'
        '"foodBrand":"$brand","servingGrams":$grams,"caloriesPer100":$kcal,'
        '"proteinPer100":$p,"carbsPer100":$c,"fatPer100":$f,'
        '"meal":"$meal","loggedAt":"$at"}';
  }

  return <String, Object>{
    'sp.onboarding.v1': true,
    'sp.streak.v1': 7,
    'sp.water.enabled.v1': true,
    'sp.water.goal.v1': 8,
    'sp.water.date.v1':
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    'sp.water.glasses.v1': 5,
    'sp.goals.v1':
        '{"dailyCalories":2200,"proteinGrams":150,"carbsGrams":240,"fatGrams":70}',
    'sp.entries.v1': <String>[
      entry(
          id: 'e1',
          name: 'Greek Yogurt',
          brand: 'Fage',
          grams: 170,
          kcal: 97,
          p: 9,
          c: 4,
          f: 5,
          meal: 'breakfast',
          hour: 8),
      entry(
          id: 'e2',
          name: 'Banana',
          grams: 120,
          kcal: 89,
          p: 1.1,
          c: 23,
          f: 0.3,
          meal: 'breakfast',
          hour: 8),
      entry(
          id: 'e3',
          name: 'Grilled Chicken Breast',
          grams: 200,
          kcal: 165,
          p: 31,
          c: 0,
          f: 3.6,
          meal: 'lunch',
          hour: 13),
      entry(
          id: 'e4',
          name: 'Brown Rice',
          grams: 150,
          kcal: 123,
          p: 2.7,
          c: 26,
          f: 1,
          meal: 'lunch',
          hour: 13),
      entry(
          id: 'e5',
          name: 'Almonds',
          grams: 30,
          kcal: 579,
          p: 21,
          c: 22,
          f: 50,
          meal: 'snack',
          hour: 16),
    ],
  };
}
