import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../models/nutrition_goals.dart';
import 'storage_service.dart';

/// Central app state. Exposes today's entries, macros, streak, and goals.
/// ChangeNotifier so it works with [Provider].
class FoodStore extends ChangeNotifier {
  FoodStore(this._storage) {
    _goals = _storage.loadGoals();
    _allEntries = _storage.loadEntries();
    _favourites = _storage.loadFavourites();
    _recents = _storage.loadRecents();
    _streak = _storage.streak;
    _lastLoggedDate = _storage.lastLoggedDate;

    // Water — reset if stored date != today
    final todayKey = _dayKey(DateTime.now());
    if (_storage.waterDate == todayKey) {
      _waterGlasses = _storage.waterGlasses;
    } else {
      _waterGlasses = 0;
    }
  }

  final StorageService _storage;
  final _uuid = const Uuid();

  late NutritionGoals _goals;
  late List<FoodEntry> _allEntries;
  late List<FoodItem> _favourites;
  late List<FoodItem> _recents;
  late int _streak;
  String? _lastLoggedDate;
  int _waterGlasses = 0;

  // --- Public getters ---
  NutritionGoals get goals => _goals;
  List<FoodItem> get favourites => List.unmodifiable(_favourites);
  List<FoodItem> get recents => List.unmodifiable(_recents);
  int get streak => _streak;
  int get waterGlasses => _waterGlasses;
  bool get waterEnabled => _storage.waterEnabled;
  int get waterGoal => _storage.waterGoal;
  bool get reminderEnabled => _storage.reminderEnabled;
  int get reminderHour => _storage.reminderHour;
  int get reminderMinute => _storage.reminderMinute;

  /// All entries for [date] (local calendar day).
  List<FoodEntry> entriesForDay(DateTime date) {
    final key = _dayKey(date);
    return _allEntries.where((e) => _dayKey(e.loggedAt) == key).toList();
  }

  /// Today's entries.
  List<FoodEntry> get todayEntries => entriesForDay(DateTime.now());

  /// Sorted unique dates that have at least one entry (for history).
  List<DateTime> get loggedDates {
    final keys = <String>{};
    final dates = <DateTime>[];
    for (final e in _allEntries) {
      final k = _dayKey(e.loggedAt);
      if (keys.add(k)) {
        dates.add(DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day));
      }
    }
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  // --- Computed daily totals ---
  double todayCalories() => todayEntries.fold(0, (s, e) => s + e.calories);
  double todayProtein() => todayEntries.fold(0, (s, e) => s + e.protein);
  double todayCarbs() => todayEntries.fold(0, (s, e) => s + e.carbs);
  double todayFat() => todayEntries.fold(0, (s, e) => s + e.fat);

  double caloriesTotalsForDay(DateTime d) =>
      entriesForDay(d).fold(0, (s, e) => s + e.calories);

  // --- Mutators ---
  Future<void> logFood(FoodItem item, double grams, MealType meal) async {
    final entry = FoodEntry(
      id: _uuid.v4(),
      foodItemId: item.id,
      foodName: item.name,
      foodBrand: item.brand,
      servingGrams: grams,
      caloriesPer100: item.caloriesPer100,
      proteinPer100: item.proteinPer100,
      carbsPer100: item.carbsPer100,
      fatPer100: item.fatPer100,
      meal: meal,
      loggedAt: DateTime.now(),
    );
    _allEntries = [..._allEntries, entry];
    await _storage.saveEntries(_allEntries);

    // Update recents (most recent first, max 20 unique by id).
    _recents = [
      item,
      ..._recents.where((r) => r.id != item.id),
    ].take(20).toList();
    await _storage.saveRecents(_recents);

    // Update streak.
    await _updateStreak();

    notifyListeners();
  }

  Future<void> deleteEntry(String entryId) async {
    _allEntries = _allEntries.where((e) => e.id != entryId).toList();
    await _storage.saveEntries(_allEntries);
    notifyListeners();
  }

  Future<void> updateEntryServing(String entryId, double newGrams) async {
    _allEntries = _allEntries.map((e) {
      if (e.id != entryId) return e;
      return FoodEntry(
        id: e.id,
        foodItemId: e.foodItemId,
        foodName: e.foodName,
        foodBrand: e.foodBrand,
        servingGrams: newGrams,
        caloriesPer100: e.caloriesPer100,
        proteinPer100: e.proteinPer100,
        carbsPer100: e.carbsPer100,
        fatPer100: e.fatPer100,
        meal: e.meal,
        loggedAt: e.loggedAt,
      );
    }).toList();
    await _storage.saveEntries(_allEntries);
    notifyListeners();
  }

  Future<void> toggleFavourite(FoodItem item) async {
    final exists = _favourites.any((f) => f.id == item.id);
    if (exists) {
      _favourites = _favourites.where((f) => f.id != item.id).toList();
    } else {
      _favourites = [item.copyWith(isFavourite: true), ..._favourites];
    }
    await _storage.saveFavourites(_favourites);
    notifyListeners();
  }

  bool isFavourite(String foodId) => _favourites.any((f) => f.id == foodId);

  // --- Water intake ---
  Future<void> addWater() async {
    _waterGlasses += 1;
    await _storage.setWater(_dayKey(DateTime.now()), _waterGlasses);
    notifyListeners();
  }

  Future<void> removeWater() async {
    if (_waterGlasses > 0) _waterGlasses -= 1;
    await _storage.setWater(_dayKey(DateTime.now()), _waterGlasses);
    notifyListeners();
  }

  Future<void> resetWater() async {
    _waterGlasses = 0;
    await _storage.setWater(_dayKey(DateTime.now()), 0);
    notifyListeners();
  }

  Future<void> setWaterSettings(
      {required bool enabled, required int goal}) async {
    await _storage.setWaterSettings(enabled, goal);
    notifyListeners();
  }

  // --- Copy yesterday ---
  Future<int> copyYesterdayEntries() async {
    final yesterday =
        DateTime.now().subtract(const Duration(days: 1));
    final src = entriesForDay(yesterday);
    if (src.isEmpty) return 0;

    final now = DateTime.now();
    final newEntries = src.map((e) => FoodEntry(
          id: _uuid.v4(),
          foodItemId: e.foodItemId,
          foodName: e.foodName,
          foodBrand: e.foodBrand,
          servingGrams: e.servingGrams,
          caloriesPer100: e.caloriesPer100,
          proteinPer100: e.proteinPer100,
          carbsPer100: e.carbsPer100,
          fatPer100: e.fatPer100,
          meal: e.meal,
          loggedAt: DateTime(
              now.year, now.month, now.day,
              e.loggedAt.hour, e.loggedAt.minute),
        )).toList();

    _allEntries = [..._allEntries, ...newEntries];
    await _storage.saveEntries(_allEntries);
    await _updateStreak();
    notifyListeners();
    return newEntries.length;
  }

  Future<void> saveGoals(NutritionGoals goals) async {
    _goals = goals;
    await _storage.saveGoals(goals);
    notifyListeners();
  }

  Future<void> setReminder(
      {required bool enabled,
      required int hour,
      required int minute}) async {
    await _storage.setReminder(enabled, hour, minute);
    notifyListeners();
  }

  bool get onboardingDone => _storage.onboardingDone;
  Future<void> markOnboardingDone() => _storage.setOnboardingDone(true);

  // --- Internal ---
  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> _updateStreak() async {
    final todayKey = _dayKey(DateTime.now());
    if (_lastLoggedDate == todayKey) return; // Already counted today.

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yKey = _dayKey(yesterday);

    if (_lastLoggedDate == yKey) {
      _streak += 1;
    } else if (_lastLoggedDate == null ||
        _lastLoggedDate != yKey) {
      _streak = 1; // Reset — missed a day.
    }

    _lastLoggedDate = todayKey;
    await _storage.setStreak(_streak);
    await _storage.setLastLoggedDate(todayKey);
  }
}
