import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/food_entry.dart';
import '../models/weight_entry.dart';
import '../models/activity_entry.dart';

class ExportService {
  static Future<void> exportCsv({
    required List<FoodEntry> entries,
    required List<WeightEntry> weightLog,
    required List<ActivityEntry> activities,
  }) async {
    final rows = <List<dynamic>>[
      ['date', 'meal', 'food', 'brand', 'grams', 'calories', 'protein_g', 'carbs_g', 'fat_g'],
    ];
    for (final e in entries) {
      rows.add([
        e.loggedAt.toIso8601String(),
        e.meal.name,
        e.foodName,
        e.foodBrand,
        e.servingGrams,
        e.calories.toStringAsFixed(1),
        e.protein.toStringAsFixed(1),
        e.carbs.toStringAsFixed(1),
        e.fat.toStringAsFixed(1),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/platesimple_food_log.csv');
    await file.writeAsString(csv);

    final weightCsv = _buildWeightCsv(weightLog);
    final weightFile = File('${dir.path}/platesimple_weight_log.csv');
    await weightFile.writeAsString(weightCsv);

    final activityCsv = _buildActivityCsv(activities);
    final activityFile = File('${dir.path}/platesimple_activities.csv');
    await activityFile.writeAsString(activityCsv);

    await Share.shareXFiles(
      [XFile(file.path), XFile(weightFile.path), XFile(activityFile.path)],
      subject: 'PlateSimple data export',
      text: 'Your PlateSimple food, weight, and activity data.',
    );
  }

  static Future<void> exportJson({
    required List<FoodEntry> entries,
    required List<WeightEntry> weightLog,
    required List<ActivityEntry> activities,
  }) async {
    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'food_entries': entries.map((e) => e.toJson()).toList(),
      'weight_log': weightLog.map((w) => w.toJson()).toList(),
      'activities': activities.map((a) => a.toJson()).toList(),
    };

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/platesimple_export.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'PlateSimple JSON export',
      text: 'Your full PlateSimple data export.',
    );
  }

  static String _buildWeightCsv(List<WeightEntry> log) {
    final rows = <List<dynamic>>[
      ['date', 'weight_kg'],
      ...log.map((w) => [w.loggedAt.toIso8601String(), w.kg]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static String _buildActivityCsv(List<ActivityEntry> acts) {
    final rows = <List<dynamic>>[
      ['date', 'activity', 'duration_min', 'calories_burned'],
      ...acts.map((a) => [
        a.loggedAt.toIso8601String(),
        a.name,
        a.durationMinutes,
        a.caloriesBurned,
      ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }
}
