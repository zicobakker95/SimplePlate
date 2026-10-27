// Layout at iPhone Duo sizes (and a phone and an iPad either side): every
// main screen must lay out without overflow, the day's dashboard puts the
// macros beside the ring on the inner display, and folding or unfolding
// (the window resizing while the app runs) keeps what the user was doing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/l10n/app_localizations.dart';
import 'package:simple_plate/models/food_entry.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/screens/goals/goals_screen.dart';
import 'package:simple_plate/screens/history/history_screen.dart';
import 'package:simple_plate/screens/home/home_shell.dart';
import 'package:simple_plate/screens/log/add_food_screen.dart';
import 'package:simple_plate/screens/log/create_custom_food_screen.dart';
import 'package:simple_plate/screens/log/create_recipe_screen.dart';
import 'package:simple_plate/screens/log/food_detail_screen.dart';
import 'package:simple_plate/screens/onboarding/onboarding_screen.dart';
import 'package:simple_plate/screens/premium/premium_screen.dart';
import 'package:simple_plate/services/food_store.dart';
import 'package:simple_plate/services/storage_service.dart';
import 'package:simple_plate/ui/theme/appearance.dart';
import 'package:simple_plate/ui/kit.dart';

import 'helpers/ui_harness.dart';

/// Logical sizes (pt). The Duo's are derived from its pixel specs at 3x.
const _sizes = <String, Size>{
  'phone': Size(390, 844),
  'small phone 360dp': Size(360, 740),
  'duo outer': Size(466, 678),
  'duo inner': Size(669, 951),
  'duo inner landscape': Size(951, 669),
  'ipad': Size(1024, 1366),
  'ipad landscape': Size(1366, 1024),
};

const _banana = FoodItem(
  id: 'banana',
  name: 'Banana',
  caloriesPer100: 89,
  proteinPer100: 1.1,
  carbsPer100: 23,
  fatPer100: 0.3,
  servingSizeGrams: 120,
);

Future<void> _settle(WidgetTester t) => settle(t, frames: 8);

void _resize(WidgetTester t, Size logical) {
  t.view.devicePixelRatio = 3;
  t.view.physicalSize = logical * 3;
}

Future<FoodStore> _pump(
  WidgetTester t,
  Size logical,
  Widget home, {
  bool fresh = false,
  bool emptyToday = false,
}) async {
  _resize(t, logical);
  addTearDown(t.view.reset);
  SharedPreferences.setMockInitialValues(
    fresh ? {} : seededPrefs(emptyToday: emptyToday),
  );
  final storage = (await t.runAsync(StorageService.init))!;
  final store = FoodStore(storage);
  await t.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: store),
        ChangeNotifierProvider(create: (_) => AppearanceController(storage)),
      ],
      child: MaterialApp(
        theme: buildPlateTheme(Brightness.light),
        locale: testLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await _settle(t);
  return store;
}

void main() {
  setUpAll(() async {
    await loadUiFonts();
    mockPlugins();
  });

  test('width bands', () {
    expect(widthBandFor(390), WidthBand.phone);
    expect(widthBandFor(466), WidthBand.phone); // Duo outer
    expect(widthBandFor(669), WidthBand.open); // Duo inner, upright
    expect(widthBandFor(951), WidthBand.tablet); // Duo inner, sideways
  });

  final screens = <String, (Widget, bool)>{
    'today': (const HomeShell(), false),
    'history': (const HistoryScreen(), false),
    'goals': (const GoalsScreen(), false),
    'add food': (const AddFoodScreen(defaultMeal: MealType.lunch), false),
    'food detail': (
      const FoodDetailScreen(item: _banana, defaultMeal: MealType.snack),
      false,
    ),
    'custom food': (
      const CreateCustomFoodScreen(defaultMeal: MealType.snack),
      false,
    ),
    'recipe builder': (const CreateRecipeScreen(), false),
    'premium': (const PremiumScreen(), false),
    'onboarding': (const OnboardingScreen(), true),
  };

  for (final s in _sizes.entries) {
    for (final screen in screens.entries) {
      testWidgets('${screen.key} lays out at ${s.key}', (t) async {
        final (home, fresh) = screen.value;
        await _pump(t, s.value, home, fresh: fresh);
        expect(t.takeException(), isNull);
      });
    }
    testWidgets('an empty today lays out at ${s.key}', (t) async {
      await _pump(t, s.value, const HomeShell(), emptyToday: true);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('content is capped and centred on the inner display', (t) async {
    await _pump(t, _sizes['duo inner landscape']!, const GoalsScreen());
    final card = t.getRect(find.byType(PtCard).first);
    expect(card.width, lessThanOrEqualTo(kContentMaxWidth));
    expect(card.center.dx, moreOrLessEquals(951 / 2, epsilon: 1));
  });

  testWidgets('the macros sit beside the ring on the inner display', (t) async {
    final en = lookupAppLocalizations(testLocale ?? const Locale('en'));
    Future<(Rect, Rect)> ringAndProtein(Size size) async {
      await _pump(t, size, const HomeShell());
      return (
        t.getRect(find.byType(PlateRing)),
        t.getRect(find.text(en.macroProtein)),
      );
    }

    final (phoneRing, phoneProtein) = await ringAndProtein(_sizes['phone']!);
    expect(phoneProtein.top, greaterThan(phoneRing.bottom));
    final (ring, protein) = await ringAndProtein(_sizes['duo inner']!);
    expect(protein.left, greaterThan(ring.right));
    expect(protein.top, lessThan(ring.bottom));
  });

  testWidgets('folding, unfolding and turning keeps the day scrolled', (
    t,
  ) async {
    await _pump(t, _sizes['duo inner']!, const HomeShell());
    final today = find.byType(Scrollable).first;
    await t.drag(today, const Offset(0, -400));
    await _settle(t);
    double offset() =>
        t.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;
    final scrolled = offset();
    expect(scrolled, greaterThan(100));

    for (final size in [
      'duo outer', // fold
      'duo inner', // unfold
      'duo inner landscape', // turn
      'duo outer', // fold again
    ]) {
      _resize(t, _sizes[size]!);
      await _settle(t);
      expect(t.takeException(), isNull, reason: size);
      expect(offset(), scrolled, reason: size);
    }
  });

  testWidgets('folding and unfolding keeps a half-typed serving', (t) async {
    await _pump(
      t,
      _sizes['duo inner']!,
      const FoodDetailScreen(item: _banana, defaultMeal: MealType.snack),
    );
    final field = find.byType(TextField).first;
    await t.enterText(field, '175');
    await _settle(t);

    for (final size in [
      'duo outer',
      'duo inner',
      'duo inner landscape',
      'duo outer',
    ]) {
      _resize(t, _sizes[size]!);
      await _settle(t);
      expect(t.takeException(), isNull, reason: size);
      expect(
        t.widget<TextField>(find.byType(TextField).first).controller!.text,
        '175',
        reason: size,
      );
    }
  });
}
