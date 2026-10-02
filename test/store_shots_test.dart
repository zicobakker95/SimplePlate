// Store screenshots: the real screens, every listing language, at the store
// device sizes, seeded with a believable, lived-in day.
//
//   flutter test test/store_shots_test.dart --dart-define=STORE_SHOTS=true
//       [--dart-define=DEVICES=phone,tablet,ipad]
//       [--dart-define=LOCALES=en,nl,de,fr,es,it,pt]
//   flutter test test/store_shots_test.dart --dart-define=STORE_SHOTS=true
//       --dart-define=LOCALES=ja          (Japanese runs on its own: CJK font)
//
// Raw PNGs land in build/store_shots/<device>/<locale>_<NN_name>.png plus
// Sprout poses in build/store_art/; store_assets/v2/make_store_shots.py
// frames them with captions. Adapted from the Word Waves pipeline.
//
// The barcode screen is captured over a black camera feed (a widget test
// has no camera); the framing script puts a product under it.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/l10n/app_localizations.dart';
import 'package:simple_plate/models/food_entry.dart';
import 'package:simple_plate/models/food_item.dart';
import 'package:simple_plate/screens/history/history_screen.dart';
import 'package:simple_plate/screens/home/home_shell.dart';
import 'package:simple_plate/screens/log/add_food_screen.dart';
import 'package:simple_plate/screens/log/barcode_screen.dart';
import 'package:simple_plate/screens/log/create_recipe_screen.dart';
import 'package:simple_plate/screens/log/food_detail_screen.dart';
import 'package:simple_plate/services/food_store.dart';
import 'package:simple_plate/services/storage_service.dart';
import 'package:simple_plate/services/subscription_service.dart';
import 'package:simple_plate/ui/kit.dart';
import 'package:simple_plate/ui/theme/appearance.dart';

import 'helpers/ui_harness.dart';

const bool kWrite = bool.fromEnvironment('STORE_SHOTS');
const String kDevices = String.fromEnvironment(
  'DEVICES',
  defaultValue: 'phone,tablet,ipad',
);
const String kLocales = String.fromEnvironment(
  'LOCALES',
  defaultValue: 'en,nl,de,fr,es,it,pt',
);

/// Logical size and pixel ratio per raw capture.
///   phone  -> Play phone 1080x1920 and iPhone 6.9" 1290x2796 frames
///   tablet -> Play 10" tablet 1600x2560
///   ipad   -> iPad 13" 2048x2732 (zoomed like the tablet)
/// The app has a phone layout only, so tablets are captured zoomed (like
/// the "Larger Text" display zoom) to keep it legible.
const devices = {
  'phone': (Size(390, 844), 3.0),
  'tablet': (Size(600, 960), 1600 / 600),
  'ipad': (Size(512, 683), 4.0),
};

/// Demo food names, translated so every listing shows a local plate.
const _names = <String, List<String>>{
  //       0 yoghurt, 1 blueberries, 2 granola, 3 chicken, 4 rice, 5 avocado,
  //       6 almonds, 7 banana, 8 avocado toast, 9 lentil curry,
  //       10 recipe note, 11 red lentils, 12 coconut milk, 13 tomatoes,
  //       14 salmon, 15 cycling, 16 porridge, 17 pasta, 18 cappuccino
  'en': [
    'Greek yoghurt', 'Blueberries', 'Homemade granola',
    'Grilled chicken breast', 'Brown rice', 'Avocado', 'Almonds', 'Banana',
    'Avocado toast', 'Lentil curry', 'Weeknight favourite', 'Red lentils',
    'Coconut milk', 'Chopped tomatoes', 'Salmon with greens', 'Cycling',
    'Oat porridge', 'Pasta al pomodoro', 'Cappuccino',
  ],
  'nl': [
    'Griekse yoghurt', 'Blauwe bessen', 'Zelfgemaakte granola',
    'Gegrilde kipfilet', 'Zilvervliesrijst', 'Avocado', 'Amandelen', 'Banaan',
    'Avocadotoast', 'Linzencurry', 'Doordeweekse favoriet', 'Rode linzen',
    'Kokosmelk', 'Tomatenblokjes', 'Zalm met groenten', 'Fietsen',
    'Havermout', 'Pasta al pomodoro', 'Cappuccino',
  ],
  'de': [
    'Griechischer Joghurt', 'Heidelbeeren', 'Selbstgemachtes Granola',
    'Gegrillte Hähnchenbrust', 'Naturreis', 'Avocado', 'Mandeln', 'Banane',
    'Avocado-Toast', 'Linsen-Curry', 'Feierabend-Klassiker', 'Rote Linsen',
    'Kokosmilch', 'Gehackte Tomaten', 'Lachs mit Gemüse', 'Radfahren',
    'Haferbrei', 'Pasta al pomodoro', 'Cappuccino',
  ],
  'fr': [
    'Yaourt grec', 'Myrtilles', 'Granola maison', 'Blanc de poulet grillé',
    'Riz complet', 'Avocat', 'Amandes', 'Banane', "Toast à l'avocat",
    'Curry de lentilles', 'Le classique de la semaine', 'Lentilles corail',
    'Lait de coco', 'Tomates concassées', 'Saumon et légumes verts', 'Vélo',
    "Porridge d'avoine", 'Pâtes al pomodoro', 'Cappuccino',
  ],
  'es': [
    'Yogur griego', 'Arándanos', 'Granola casera',
    'Pechuga de pollo a la plancha', 'Arroz integral', 'Aguacate',
    'Almendras', 'Plátano', 'Tostada de aguacate', 'Curry de lentejas',
    'Un clásico entre semana', 'Lentejas rojas', 'Leche de coco',
    'Tomate triturado', 'Salmón con verduras', 'Ciclismo', 'Gachas de avena',
    'Pasta al pomodoro', 'Capuchino',
  ],
  'it': [
    'Yogurt greco', 'Mirtilli', 'Granola fatta in casa',
    'Petto di pollo alla griglia', 'Riso integrale', 'Avocado', 'Mandorle',
    'Banana', "Toast all'avocado", 'Curry di lenticchie',
    'Il classico infrasettimanale', 'Lenticchie rosse', 'Latte di cocco',
    'Polpa di pomodoro', 'Salmone con verdure', 'Ciclismo', "Porridge d'avena",
    'Pasta al pomodoro', 'Cappuccino',
  ],
  'pt': [
    'Iogurte grego', 'Mirtilos', 'Granola caseira', 'Peito de frango grelhado',
    'Arroz integral', 'Abacate', 'Amêndoas', 'Banana', 'Torrada com abacate',
    'Curry de lentilhas', 'Clássico do dia a dia', 'Lentilhas vermelhas',
    'Leite de coco', 'Tomate picado', 'Salmão com legumes', 'Ciclismo',
    'Mingau de aveia', 'Macarrão ao sugo', 'Cappuccino',
  ],
  'ja': [
    'ギリシャヨーグルト', 'ブルーベリー', '自家製グラノーラ', 'グリルチキン', '玄米',
    'アボカド', 'アーモンド', 'バナナ', 'アボカドトースト', 'レンズ豆のカレー', '平日の定番',
    '赤レンズ豆', 'ココナッツミルク', 'カットトマト', 'サーモンと青菜', 'サイクリング',
    'オートミール', 'トマトパスタ', 'カプチーノ',
  ],
};

final _root = GlobalKey();
final _navKey = GlobalKey<NavigatorState>();

String _day(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Map<String, Object?> _food(
  String id,
  String name,
  double kcal,
  double p,
  double c,
  double f, {
  String brand = '',
  double? serving,
  bool custom = false,
}) => {
  'id': id,
  'name': name,
  'brand': brand,
  'caloriesPer100': kcal,
  'proteinPer100': p,
  'carbsPer100': c,
  'fatPer100': f,
  'isFavourite': false,
  'isCustom': custom,
  'servingSizeGrams': ?serving,
  'hasCompleteNutrition': true,
};

/// Foods by key: (name index, kcal, protein, carbs, fat, brand, serving).
const _foods = <String, (int, double, double, double, double, String, double?)>{
  'yoghurt': (0, 97, 9, 4, 5, 'Fage', null),
  'blueberries': (1, 57, 0.7, 14, 0.3, '', null),
  'granola': (2, 452, 11, 58, 19, '', null),
  'chicken': (3, 165, 31, 0, 3.6, '', null),
  'rice': (4, 123, 2.7, 26, 1, '', 75),
  'avocado': (5, 160, 2, 9, 15, '', null),
  'almonds': (6, 579, 21, 22, 50, '', null),
  'banana': (7, 89, 1.1, 23, 0.3, '', 120),
  'avotoast': (8, 195, 5, 18, 11, '', null),
  'salmon': (14, 175, 14, 4, 11, '', null),
  'porridge': (16, 100, 4, 16, 2.4, '', null),
  'pasta': (17, 131, 4.6, 24, 2, '', null),
  'cappuccino': (18, 40, 2, 3.4, 1.6, '', null),
};

FoodItem foodItem(String loc, String key) {
  final f = _foods[key]!;
  return FoodItem(
    id: key,
    name: _names[loc]![f.$1],
    brand: f.$6,
    caloriesPer100: f.$2,
    proteinPer100: f.$3,
    carbsPer100: f.$4,
    fatPer100: f.$5,
    servingSizeGrams: f.$7,
  );
}

/// Twelve days into a streak, today about half eaten (plus a bike ride),
/// two weeks of history, a gentle weight trend down, recents, favourites,
/// a custom food and a recipe. [dinner] adds a dinner that lands the day
/// in the target window; [water] sets the glasses.
Map<String, Object> storeSeed(String loc, {bool dinner = false, int water = 5}) {
  final names = _names[loc]!;
  final now = DateTime.now();
  final entries = <String>[];
  var n = 0;
  void log(DateTime day, String key, double grams, String meal, {int hour = 12}) {
    final f = _foods[key]!;
    entries.add(
      jsonEncode({
        'id': 'e${n++}',
        'foodItemId': key,
        'foodName': names[f.$1],
        'foodBrand': f.$6,
        'servingGrams': grams,
        'caloriesPer100': f.$2,
        'proteinPer100': f.$3,
        'carbsPer100': f.$4,
        'fatPer100': f.$5,
        'meal': meal,
        'loggedAt': DateTime(day.year, day.month, day.day, hour).toIso8601String(),
        'servingSizeGrams': f.$7,
      }),
    );
  }

  final today = DateTime(now.year, now.month, now.day);
  log(today, 'yoghurt', 170, 'breakfast', hour: 7);
  log(today, 'blueberries', 80, 'breakfast', hour: 7);
  log(today, 'granola', 45, 'breakfast', hour: 7);
  log(today, 'cappuccino', 200, 'breakfast', hour: 8);
  log(today, 'chicken', 180, 'lunch', hour: 12);
  log(today, 'rice', 200, 'lunch', hour: 12);
  log(today, 'avocado', 80, 'lunch', hour: 12);
  log(today, 'almonds', 25, 'snack', hour: 15);
  log(today, 'banana', 120, 'snack', hour: 16);
  if (dinner) log(today, 'salmon', 380, 'dinner', hour: 19);

  // Six weeks behind: mostly on target, a few over or light, two skipped.
  const totals = [
    2050, 1980, 2240, 1930, 2010, 2120, 1890, 2060, 1610, 2010, 1950, 0, //
    2180, 1840, 1990, 2070, 2380, 1920, 2030, 1880, 2100, 1700, 1960, //
    2040, 1910, 2290, 2000, 1870, 0, 2060, 1990, 1930, 2150, 1820, 2010, //
    1960, 2440, 1890, 2020, 1940,
  ];
  for (var d = 1; d <= totals.length; d++) {
    final kcal = totals[d - 1].toDouble();
    if (kcal == 0) continue;
    final day = today.subtract(Duration(days: d));
    log(day, 'porridge', kcal * 0.25, 'breakfast', hour: 8);
    log(day, 'pasta', kcal * 0.4 / 1.31, 'lunch', hour: 13);
    log(day, 'salmon', kcal * 0.35 / 1.75, 'dinner', hour: 19);
  }

  final weights = <String>[
    for (var i = 0; i < 11; i++)
      jsonEncode({
        'id': 'w$i',
        'kg': 80.4 - i * 0.2 + (i % 3 == 0 ? 0.25 : (i % 3 == 1 ? -0.1 : 0.05)),
        'loggedAt': today
            .subtract(Duration(days: (10 - i) * 3))
            .add(const Duration(hours: 7))
            .toIso8601String(),
      }),
  ];

  Map<String, Object?> item(String key) {
    final f = _foods[key]!;
    return _food(key, names[f.$1], f.$2, f.$3, f.$4, f.$5, brand: f.$6, serving: f.$7);
  }

  final recents = [
    for (final k in ['yoghurt', 'banana', 'chicken', 'rice', 'almonds', 'avotoast', 'blueberries'])
      item(k),
  ];

  return <String, Object>{
    'sp.onboarding.v1': true,
    'sp.streak.v1': 12,
    'sp.lastLogged.v1': _day(now),
    'sp.water.enabled.v1': true,
    'sp.water.goal.v1': 8,
    'sp.water.date.v1': _day(now),
    'sp.water.glasses.v1': water,
    'sp.goals.v1':
        '{"dailyCalories":2100,"proteinGrams":140,"carbsGrams":230,"fatGrams":70}',
    'sp.entries.v1': entries,
    'sp.weightLog.v1': weights,
    'sp.activities.v1': [
      jsonEncode({
        'id': 'a1',
        'name': names[15],
        'caloriesBurned': 260,
        'durationMinutes': 35,
        'loggedAt': today.add(const Duration(hours: 18)).toIso8601String(),
      }),
    ],
    'sp.recents.v1': [for (final r in recents) jsonEncode(r)],
    'sp.favourites.v1': [jsonEncode(recents[1]), jsonEncode(recents[4])],
    'sp.customFoods.v1': [
      jsonEncode(_food('custom-granola', names[2], 452, 11, 58, 19, custom: true)),
    ],
    'sp.recipes.v1': [
      jsonEncode({
        'id': 'r1',
        'name': names[9],
        'description': names[10],
        'servings': 4,
        'ingredients': [
          {'item': _food('lentils', names[11], 352, 24, 60, 1), 'grams': 300},
          {'item': _food('coconut', names[12], 197, 2, 3, 21), 'grams': 400},
          {'item': _food('tomato', names[13], 21, 1, 4, 0.2), 'grams': 400},
          {'item': item('rice'), 'grams': 300},
        ],
      }),
    ],
  };
}

void main() {
  final locales = kLocales.split(',').where((l) => l.isNotEmpty).toList();
  final cjk = locales.contains('ja');
  assert(!cjk || locales.length == 1, 'Run LOCALES=ja on its own');

  setUpAll(() async {
    await loadUiFonts();
    mockPlugins();
    Future<ByteData> read(String path) async =>
        ByteData.view((await File(path).readAsBytes()).buffer);
    if (cjk) {
      final ja = FontLoader('CjkFallback')
        ..addFont(read('C:/Windows/Fonts/YuGothM.ttc'))
        ..addFont(read('C:/Windows/Fonts/YuGothB.ttc'));
      await ja.load();
      PtText.debugFontFallback = ['CjkFallback', ...?PtText.debugFontFallback];
    }
    // No camera in a widget test: the scanner start call just never answers,
    // so the preview stays black.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.steenbakker.mobile_scanner/scanner/method'),
          (call) => Completer<Object?>().future,
        );
  });

  tearDown(() => SubscriptionService.instance.debugSetPremium(false));

  Future<void> useDevice(WidgetTester tester, String device) async {
    final (size, dpr) = devices[device]!;
    tester.view.devicePixelRatio = dpr;
    tester.view.physicalSize = size * dpr;
    final pad = FakeViewPadding(top: 26 * dpr, bottom: 14 * dpr);
    tester.view.padding = pad;
    tester.view.viewPadding = pad;
    addTearDown(tester.view.reset);
  }

  Future<FoodStore> pumpApp(
    WidgetTester tester,
    String device,
    String loc,
    Widget home, {
    bool dark = false,
    bool dinner = false,
    int water = 5,
  }) async {
    await useDevice(tester, device);
    SharedPreferences.setMockInitialValues(
      storeSeed(loc, dinner: dinner, water: water),
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
          key: _root,
          child: MaterialApp(
            navigatorKey: _navKey,
            debugShowCheckedModeBanner: false,
            locale: Locale(loc),
            theme: buildPlateTheme(Brightness.light),
            darkTheme: buildPlateTheme(Brightness.dark),
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: home,
          ),
        ),
      ),
    );
    await settle(tester);
    return store;
  }

  Future<void> push(WidgetTester tester, Widget screen) async {
    _navKey.currentState!.push(MaterialPageRoute(builder: (_) => screen));
    await settle(tester);
  }

  Future<void> snap(
    WidgetTester tester,
    String device,
    String loc,
    String name, {
    GlobalKey? key,
    String dir = 'store_shots',
  }) async {
    expect(tester.takeException(), isNull);
    if (!kWrite) return;
    final (_, dpr) = devices[device]!;
    final boundary =
        (key ?? _root).currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: dpr);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final out = File(
        dir == 'store_shots'
            ? 'build/store_shots/$device/${loc}_$name.png'
            : 'build/$dir/$name.png',
      );
      await out.parent.create(recursive: true);
      await out.writeAsBytes(png!.buffer.asUint8List());
    });
  }

  if (!cjk) {
    testWidgets('art sprout poses', (tester) async {
      await useDevice(tester, 'phone');
      final key = GlobalKey();
      for (final mood in [
        SproutMood.happy,
        SproutMood.celebrate,
        SproutMood.idle,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildPlateTheme(Brightness.light),
            home: ColoredBox(
              color: const Color(0x00000000),
              child: Center(
                child: RepaintBoundary(
                  key: key,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Sprout(mood: mood, size: 300),
                  ),
                ),
              ),
            ),
          ),
        );
        await settle(tester);
        await snap(tester, 'phone', 'en', 'sprout_${mood.name}',
            key: key, dir: 'store_art');
      }
    });
  }

  for (final device in kDevices.split(',')) {
    for (final loc in locales) {
      final tag = '$device $loc';

      testWidgets('$tag 01_today', (tester) async {
        await pumpApp(tester, device, loc, const HomeShell());
        await snap(tester, device, loc, '01_today');
      });

      testWidgets('$tag 02_log', (tester) async {
        await pumpApp(tester, device, loc, const HomeShell());
        await push(tester, const AddFoodScreen(defaultMeal: MealType.lunch));
        await snap(tester, device, loc, '02_log');
      });

      testWidgets('$tag 03_scan', (tester) async {
        await pumpApp(tester, device, loc, const HomeShell());
        await push(tester, const BarcodeScreen());
        await snap(tester, device, loc, '03_scan');
        _navKey.currentState!.pop();
        await settle(tester);
      });

      testWidgets('$tag 04_detail', (tester) async {
        await pumpApp(tester, device, loc, const HomeShell());
        await push(
          tester,
          FoodDetailScreen(
            item: foodItem(loc, 'yoghurt'),
            defaultMeal: MealType.breakfast,
          ),
        );
        await snap(tester, device, loc, '04_detail');
      });

      testWidgets('$tag 05_recipes', (tester) async {
        final store = await pumpApp(tester, device, loc, const HomeShell());
        await push(tester, CreateRecipeScreen(existing: store.recipes.first));
        await snap(tester, device, loc, '05_recipes');
      });

      testWidgets('$tag 06_celebrate', (tester) async {
        // Dinner lands the day in the target window: food confetti, the
        // goal toast and a cheering Sprout. Two items at once, so the
        // single-item "logged" toast stays out of the way.
        final store = await pumpApp(
          tester,
          device,
          loc,
          const HomeShell(),
          water: 8,
        );
        await tester.runAsync(() async {
          await store.logFood(foodItem(loc, 'salmon'), 300, MealType.dinner);
          await store.logFood(foodItem(loc, 'rice'), 150, MealType.dinner);
        });
        await tester.pump();
        for (var i = 0; i < 7; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await snap(tester, device, loc, '06_celebrate');
        await settle(tester, frames: 40);
      });

      testWidgets('$tag 07_history', (tester) async {
        await SubscriptionService.instance.debugSetPremium(true);
        await pumpApp(tester, device, loc, const HistoryScreen());
        // Last month: a full calendar of logged days.
        await tester.tap(
          find.byIcon(Icons.chevron_left_rounded),
          warnIfMissed: false,
        );
        await settle(tester);
        await snap(tester, device, loc, '07_history');
      });

      testWidgets('$tag 08_dark', (tester) async {
        await pumpApp(tester, device, loc, const HomeShell(), dark: true);
        await snap(tester, device, loc, '08_dark');
      });
    }
  }
}
