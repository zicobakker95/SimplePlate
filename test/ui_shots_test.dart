// Builds every redesigned screen, sheet and dialog with realistic local data,
// in light and dark (plus 1.3x text on a few). A smoke test on its own; with
//   flutter test --dart-define=UI_SHOTS=true test/ui_shots_test.dart
// it also writes build/ui_shots/*.png (see tool/ui_contact_sheet.py).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/l10n/app_localizations.dart';
import 'package:simple_plate/models/food_entry.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/screens/log/add_food_screen.dart';
import 'package:simple_plate/screens/log/create_custom_food_screen.dart';
import 'package:simple_plate/screens/log/create_recipe_screen.dart';
import 'package:simple_plate/screens/log/food_detail_screen.dart';
import 'package:simple_plate/widgets/edit_entry_sheet.dart';
import 'package:simple_plate/widgets/quick_add_sheet.dart';
import 'package:simple_plate/widgets/share_card.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:simple_plate/screens/goals/goals_screen.dart';
import 'package:simple_plate/screens/goals/tdee_calculator_sheet.dart';
import 'package:simple_plate/screens/history/history_screen.dart';
import 'package:simple_plate/screens/home/home_shell.dart';
import 'package:simple_plate/screens/premium/premium_screen.dart';
import 'package:simple_plate/screens/onboarding/onboarding_screen.dart';
import 'package:simple_plate/services/food_store.dart';
import 'package:simple_plate/services/storage_service.dart';
import 'package:simple_plate/services/subscription_service.dart';
import 'package:simple_plate/ui/theme/appearance.dart';
import 'package:simple_plate/ui/theme/plate_theme.dart';

import 'helpers/ui_harness.dart';

void main() {
  final navKey = GlobalKey<NavigatorState>();
  final en = lookupAppLocalizations(const Locale('en'));
  BuildContext ctx() => navKey.currentContext!;

  Future<void> push(WidgetTester tester, Widget screen) async {
    navKey.currentState!.push(MaterialPageRoute(builder: (_) => screen));
    await settle(tester);
  }

  const banana = FoodItem(
    id: 'banana',
    name: 'Banana',
    caloriesPer100: 89,
    proteinPer100: 1.1,
    carbsPer100: 23,
    fatPer100: 0.3,
    servingSizeGrams: 120,
  );

  setUpAll(() async {
    await loadUiFonts();
    mockPlugins();
  });

  tearDown(() => SubscriptionService.instance.debugSetPremium(false));

  Future<FoodStore> pumpApp(
    WidgetTester tester,
    Widget home, {
    bool dark = false,
    bool emptyToday = false,
    bool fresh = false,
    double textScale = 1,
    bool reduceMotion = false,
  }) async {
    await usePhoneSurface(tester);
    SharedPreferences.setMockInitialValues(
      fresh ? {} : seededPrefs(emptyToday: emptyToday),
    );
    final storage = (await tester.runAsync(StorageService.init))!;
    final store = FoodStore(storage);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: store),
          ChangeNotifierProvider(create: (_) => AppearanceController(storage)),
        ],
        child: RepaintBoundary(
          key: shotKey,
          child: MaterialApp(
            navigatorKey: navKey,
            debugShowCheckedModeBanner: false,
            theme: buildPlateTheme(Brightness.light),
            darkTheme: buildPlateTheme(Brightness.dark),
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(
                textScaler: TextScaler.linear(textScale),
                disableAnimations: reduceMotion,
              ),
              child: child!,
            ),
            home: home,
          ),
        ),
      ),
    );
    await settle(tester);
    return store;
  }

  // Crashed on OnePlus phones with "Remove animations" on: nextPage() with
  // Duration.zero throws a LateInitializationError ('_controller').
  testWidgets('onboarding pages forward with animations off', (tester) async {
    await pumpApp(tester, const OnboardingScreen(), fresh: true, reduceMotion: true);
    await tester.tap(find.text(en.getStarted));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text(en.continueLabel), findsOneWidget);
    await tester.tap(find.text(en.continueLabel));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    final s = dark ? '_dark' : '';

    testWidgets('today$s', (tester) async {
      await pumpApp(tester, const HomeShell(), dark: dark);
      expect(find.text('PlateSimple'), findsWidgets);
      await shot(tester, '01_today$s');
    });

    testWidgets('today_empty$s', (tester) async {
      await pumpApp(tester, const HomeShell(), dark: dark, emptyToday: true);
      await shot(tester, '02_today_empty$s');
    });

    testWidgets('add_food$s', (tester) async {
      await pumpApp(tester, const HomeShell(), dark: dark);
      await push(tester, const AddFoodScreen(defaultMeal: MealType.lunch));
      await shot(tester, '03_add_food_search$s');
      await tester.tap(find.text(en.tabRecentFav));
      await settle(tester);
      await shot(tester, '04_add_food_my_foods$s');
      await tester.tap(find.text(en.tabRecipes));
      await settle(tester);
      await shot(tester, '05_add_food_recipes$s');
    });

    testWidgets('add_food_empty$s', (tester) async {
      await pumpApp(tester, const AddFoodScreen(), dark: dark, fresh: true);
      await shot(tester, '06_add_food_empty$s');
    });

    testWidgets('food_detail$s', (tester) async {
      await pumpApp(tester, const HomeShell(), dark: dark);
      await push(
        tester,
        const FoodDetailScreen(item: banana, defaultMeal: MealType.snack),
      );
      await shot(tester, '07_food_detail$s');
    });

    testWidgets('custom_food$s', (tester) async {
      await pumpApp(tester, const HomeShell(), dark: dark);
      await push(
        tester,
        const CreateCustomFoodScreen(defaultMeal: MealType.snack),
      );
      await shot(tester, '08_custom_food$s');
    });

    testWidgets('recipe$s', (tester) async {
      final store = await pumpApp(tester, const HomeShell(), dark: dark);
      await push(tester, CreateRecipeScreen(existing: store.recipes.first));
      await shot(tester, '09_recipe_builder$s');
    });

    testWidgets('sheets$s', (tester) async {
      final store = await pumpApp(tester, const HomeShell(), dark: dark);
      showQuickAddSheet(ctx(), defaultMeal: MealType.lunch);
      await settle(tester);
      await shot(tester, '10_sheet_quick_add$s');
      navKey.currentState!.pop();
      await settle(tester);

      showEditEntrySheet(ctx(), store.todayEntries[2]);
      await settle(tester);
      await shot(tester, '11_sheet_edit_entry$s');
      navKey.currentState!.pop();
      await settle(tester);

      ShareCard.show(
        ctx(),
        date: DateTime.now(),
        calories: 1890,
        goalCalories: 2100,
        protein: 120,
        carbs: 190,
        fat: 64,
        streak: 12,
      );
      await settle(tester);
      await shot(tester, '12_sheet_share$s');
      navKey.currentState!.pop();
      await settle(tester);

      await tester.scrollUntilVisible(
        find.text(en.addActivity),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(en.addActivity));
      await settle(tester);
      await tester.tap(find.text(en.actCycling).last);
      await settle(tester);
      await shot(tester, '13_sheet_activity$s');
      navKey.currentState!.pop();
      await settle(tester);

      confirmDeleteEntry(ctx(), store.todayEntries.first);
      await settle(tester);
      await shot(tester, '14_dialog_delete$s');
    });

    testWidgets('history$s', (tester) async {
      await pumpApp(tester, const HistoryScreen(), dark: dark);
      await shot(tester, '15_history_free$s');
      await SubscriptionService.instance.debugSetPremium(true);
      await settle(tester);
      await shot(tester, '16_history_premium$s');
      showDaySheet(ctx(), DateTime.now().subtract(const Duration(days: 1)));
      await settle(tester);
      await shot(tester, '17_sheet_day$s');
    });

    testWidgets('premium$s', (tester) async {
      SubscriptionService.instance.debugSetProducts([
        ProductDetails(
          id: SubscriptionService.kMonthlyId,
          title: 'Monthly',
          description: '',
          price: '€3.99',
          rawPrice: 3.99,
          currencyCode: 'EUR',
        ),
        ProductDetails(
          id: SubscriptionService.kYearlyId,
          title: 'Yearly',
          description: '',
          price: '€24.99',
          rawPrice: 24.99,
          currencyCode: 'EUR',
        ),
      ]);
      await pumpApp(tester, const PremiumScreen(), dark: dark);
      await shot(tester, '18_premium$s');
    });

    testWidgets('goals$s', (tester) async {
      await pumpApp(tester, const GoalsScreen(), dark: dark);
      await shot(tester, '19_goals$s');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -1500));
      await settle(tester);
      await shot(tester, '19_goals_more$s');
      TdeeCalculatorSheet.show(ctx());
      await settle(tester);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '34');
      await tester.enterText(fields.at(1), '178');
      await tester.enterText(fields.at(2), '79');
      await tester.tap(find.text(en.calculate));
      await settle(tester);
      await shot(tester, '20_sheet_tdee$s');
    });

    testWidgets('onboarding$s', (tester) async {
      await pumpApp(tester, const OnboardingScreen(), dark: dark, fresh: true);
      await shot(tester, '21_onboarding_welcome$s');
      await tester.tap(find.text(en.getStarted));
      await settle(tester);
      await shot(tester, '22_onboarding_goals$s');
      await tester.tap(find.text(en.goalModePercent));
      await settle(tester);
      await tester.tap(find.text(en.continueLabel));
      await settle(tester);
      await shot(tester, '23_onboarding_reminders$s');
    });
  }

  testWidgets('history_text13', (tester) async {
    await pumpApp(tester, const HistoryScreen(), textScale: 1.3);
    await shot(tester, '91_history_text13');
  });

  testWidgets('goals_text13', (tester) async {
    await pumpApp(tester, const GoalsScreen(), textScale: 1.3);
    await shot(tester, '92_goals_text13');
  });

  testWidgets('onboarding_text13', (tester) async {
    await pumpApp(tester, const OnboardingScreen(),
        fresh: true, textScale: 1.3);
    await shot(tester, '93_onboarding_text13');
  });

  testWidgets('today_text13', (tester) async {
    await pumpApp(tester, const HomeShell(), textScale: 1.3);
    await shot(tester, '90_today_text13');
  });
}
