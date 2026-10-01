import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/ui/kit.dart';

/// Set with `flutter test --dart-define=UI_SHOTS=true test/ui_shots_test.dart`
/// to write PNGs to build/ui_shots/. Without it every screen is still built
/// and pumped (a smoke test), just not saved.
const bool kWriteShots = bool.fromEnvironment('UI_SHOTS');

bool _fontsLoaded = false;

/// Loads real fonts so text renders as text instead of test boxes: the
/// bundled Rubik, the Material icon font from the Flutter SDK and, when the
/// machine has it, Segoe UI Emoji for the meal emoji.
Future<void> loadUiFonts() async {
  FadeSlideIn.debugSkip = true;
  Sprout.debugStill = true;
  if (_fontsLoaded) return;
  _fontsLoaded = true;

  Future<ByteData> read(String path) async {
    final bytes = await File(path).readAsBytes();
    return ByteData.view(bytes.buffer);
  }

  final rubik = FontLoader('Rubik');
  for (final f in ['Regular', 'Medium', 'Bold']) {
    rubik.addFont(read('assets/fonts/Rubik-$f.ttf'));
  }
  await rubik.load();

  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? r'C:\src\flutter';
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      read(
        '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      ),
    );
  await icons.load();

  const emojiPath = r'C:\Windows\Fonts\seguiemj.ttf';
  if (File(emojiPath).existsSync()) {
    final emoji = FontLoader('Emoji')..addFont(read(emojiPath));
    await emoji.load();
    PtText.debugFontFallback = const ['Emoji'];
  }
}

/// Phone-sized surface (logical 390 x 844 at 3x).
Future<void> usePhoneSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Mocks the platform channels the screens touch (ads, analytics,
/// notifications, the home widget, in-app review) with polite no-ops.
void mockPlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in [
    'plugins.flutter.io/google_mobile_ads',
    'plugins.flutter.io/firebase_analytics',
    'plugins.flutter.io/firebase_core',
    'dexterous.com/flutter/local_notifications',
    'home_widget',
    'dev.britannio.in_app_review',
    'plugins.flutter.io/path_provider',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), (call) async {
      return null;
    });
  }
}

/// Settles animations without waiting forever: pumps in steps.
Future<void> settle(WidgetTester tester, {int frames = 14}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Captures the first RepaintBoundary (the app) to build/ui_shots/[name].png
/// when [kWriteShots] is set.
Future<void> shot(WidgetTester tester, String name) async {
  if (!kWriteShots) return;
  final target = find.byKey(shotKey);
  final boundary = tester.renderObject(target) as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.5);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final out = File('build/ui_shots/$name.png');
    await out.parent.create(recursive: true);
    await out.writeAsBytes(data!.buffer.asUint8List());
  });
}

const shotKey = ValueKey('ui-shot-boundary');

// ── Seed data ────────────────────────────────────────────────────────────────

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
}) => {
  'id': id,
  'name': name,
  'brand': brand,
  'caloriesPer100': kcal,
  'proteinPer100': p,
  'carbsPer100': c,
  'fatPer100': f,
  'isFavourite': false,
  'isCustom': false,
  'servingSizeGrams': ?serving,
  'hasCompleteNutrition': true,
};

/// A realistic, well-used account: two weeks of meals, today half done,
/// water, weigh-ins, an activity, recents, favourites, a recipe.
Map<String, Object> seededPrefs({bool emptyToday = false}) {
  final now = DateTime.now();
  final entries = <String>[];
  var n = 0;
  void log(
    DateTime day,
    String name,
    double grams,
    double kcal,
    double p,
    double c,
    double f,
    String meal, {
    String brand = '',
    double? serving,
  }) {
    entries.add(
      jsonEncode({
        'id': 'e${n++}',
        'foodItemId': name.toLowerCase().replaceAll(' ', '-'),
        'foodName': name,
        'foodBrand': brand,
        'servingGrams': grams,
        'caloriesPer100': kcal,
        'proteinPer100': p,
        'carbsPer100': c,
        'fatPer100': f,
        'meal': meal,
        'loggedAt': DateTime(
          day.year,
          day.month,
          day.day,
          12,
        ).toIso8601String(),
        'servingSizeGrams': serving,
      }),
    );
  }

  if (!emptyToday) {
    log(now, 'Greek yoghurt', 170, 97, 9, 4, 5, 'breakfast', brand: 'Fage');
    log(now, 'Blueberries', 80, 57, 0.7, 14, 0.3, 'breakfast');
    log(now, 'Grilled chicken breast', 180, 165, 31, 0, 3.6, 'lunch');
    log(now, 'Brown rice', 150, 123, 2.7, 26, 1, 'lunch', serving: 75);
    log(now, 'Almonds', 30, 579, 21, 22, 50, 'snack');
  }
  // Two weeks behind, a mix of on-target, under and over days.
  const totals = [
    2050,
    1720,
    2400,
    1980,
    0,
    2120,
    1890,
    2260,
    1500,
    2010,
    1950,
    0,
    2180,
    1840,
  ];
  for (var d = 1; d <= totals.length; d++) {
    final kcal = totals[d - 1].toDouble();
    if (kcal == 0) continue;
    final day = now.subtract(Duration(days: d));
    log(day, 'Oat porridge', 250, kcal * 0.25 / 2.5, 5, 20, 3, 'breakfast');
    log(day, 'Pasta al pomodoro', 300, kcal * 0.4 / 3, 5, 30, 2, 'lunch');
    log(day, 'Salmon and greens', 350, kcal * 0.35 / 3.5, 12, 4, 7, 'dinner');
  }

  final weights = <String>[
    for (var i = 0; i < 9; i++)
      jsonEncode({
        'id': 'w$i',
        'kg': 79.6 - i * 0.18 + (i.isEven ? 0.2 : -0.1),
        'loggedAt': now.subtract(Duration(days: (8 - i) * 3)).toIso8601String(),
      }),
  ];

  final recents = [
    _food('greek-yoghurt', 'Greek yoghurt', 97, 9, 4, 5, brand: 'Fage'),
    _food('banana', 'Banana', 89, 1.1, 23, 0.3, serving: 120),
    _food('chicken', 'Grilled chicken breast', 165, 31, 0, 3.6),
    _food('brown-rice', 'Brown rice', 123, 2.7, 26, 1, serving: 75),
    _food('almonds', 'Almonds', 579, 21, 22, 50),
    _food('avocado-toast', 'Avocado toast', 195, 5, 18, 11),
  ];

  return <String, Object>{
    'sp.onboarding.v1': true,
    'sp.streak.v1': 12,
    'sp.lastLogged.v1': _day(now),
    'sp.water.enabled.v1': true,
    'sp.water.goal.v1': 8,
    'sp.water.date.v1': _day(now),
    'sp.water.glasses.v1': emptyToday ? 0 : 5,
    'sp.goals.v1':
        '{"dailyCalories":2100,"proteinGrams":140,"carbsGrams":230,"fatGrams":70}',
    'sp.entries.v1': entries,
    'sp.weightLog.v1': weights,
    'sp.activities.v1': [
      if (!emptyToday)
        jsonEncode({
          'id': 'a1',
          'name': 'Cycling',
          'caloriesBurned': 260,
          'durationMinutes': 35,
          'loggedAt': now.toIso8601String(),
        }),
    ],
    'sp.recents.v1': [for (final r in recents) jsonEncode(r)],
    'sp.favourites.v1': [jsonEncode(recents[1]), jsonEncode(recents[4])],
    'sp.customFoods.v1': [
      jsonEncode(
        _food('custom-granola', 'Homemade granola', 452, 11, 58, 19)
          ..['isCustom'] = true,
      ),
    ],
    'sp.recipes.v1': [
      jsonEncode({
        'id': 'r1',
        'name': 'Lentil curry',
        'description': 'Weeknight staple',
        'servings': 4,
        'ingredients': [
          {
            'item': _food('lentils', 'Red lentils', 352, 24, 60, 1),
            'grams': 300,
          },
          {
            'item': _food('coconut', 'Coconut milk', 197, 2, 3, 21),
            'grams': 400,
          },
          {
            'item': _food('tomato', 'Chopped tomatoes', 21, 1, 4, 0.2),
            'grams': 400,
          },
        ],
      }),
    ],
  };
}
