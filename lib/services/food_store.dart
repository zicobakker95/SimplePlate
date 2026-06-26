import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_entry.dart';
import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../models/nutrition_goals.dart';
import '../models/recipe.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import 'storage_service.dart';
import 'widget_service.dart';

/// Central app state. Exposes today's entries, macros, streak, and goals.
/// ChangeNotifier so it works with [Provider].
class FoodStore extends ChangeNotifier {
  FoodStore(this._storage) {
    _goals = _storage.loadGoals();
    _allEntries = _storage.loadEntries();
    _favourites = _storage.loadFavourites();
    _recents = _storage.loadRecents();
    _customFoods = _storage.loadCustomFoods();
    _weightLog = _storage.loadWeightLog();
    _activities = _storage.loadActivities();
    _recipes = _storage.loadRecipes();
    _userProfile = _storage.loadUserProfile();
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
  late List<FoodItem> _customFoods;
  late List<WeightEntry> _weightLog;
  late List<ActivityEntry> _activities;
  late List<Recipe> _recipes;
  UserProfile? _userProfile;
  late int _streak;
  String? _lastLoggedDate;
  int _waterGlasses = 0;

  // --- Public getters ---
  NutritionGoals get goals => _goals;
  List<FoodEntry> get allEntries => List.unmodifiable(_allEntries);
  List<FoodItem> get favourites => List.unmodifiable(_favourites);
  List<FoodItem> get recents => List.unmodifiable(_recents);
  List<FoodItem> get customFoods => List.unmodifiable(_customFoods);
  List<WeightEntry> get weightLog => List.unmodifiable(_weightLog);
  List<ActivityEntry> get activities => List.unmodifiable(_activities);
  List<Recipe> get recipes => List.unmodifiable(_recipes);
  UserProfile? get userProfile => _userProfile;
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

  // --- Activity ---
  List<ActivityEntry> activitiesForDay(DateTime date) {
    final key = _dayKey(date);
    return _activities.where((a) => _dayKey(a.loggedAt) == key).toList();
  }

  List<ActivityEntry> get todayActivities => activitiesForDay(DateTime.now());

  double todayBurned() =>
      todayActivities.fold(0, (s, a) => s + a.caloriesBurned);

  double todayNet() => todayCalories() - todayBurned();

  // --- Weight log ---
  List<WeightEntry> get _sortedWeightLog =>
      ([..._weightLog]..sort((a, b) => a.loggedAt.compareTo(b.loggedAt)));

  WeightEntry? get latestWeight =>
      _weightLog.isEmpty ? null : _sortedWeightLog.last;

  List<WeightEntry> get recentWeightEntries {
    final sorted = _sortedWeightLog;
    return sorted.length > 30 ? sorted.sublist(sorted.length - 30) : sorted;
  }

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

    // Prompt for a review after 3+ day streak, at most once every 60 days.
    await _maybeRequestReview();

    // Push updated totals to home screen widget.
    unawaited(WidgetService.instance.updateCalories(
      calories: todayCalories(),
      goalCalories: _goals.dailyCalories,
      protein: todayProtein(),
      carbs: todayCarbs(),
      fat: todayFat(),
    ));

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

  // --- Activity logging ---
  Future<void> logActivity(ActivityEntry entry) async {
    _activities = [..._activities, entry];
    await _storage.saveActivities(_activities);
    notifyListeners();
  }

  Future<void> deleteActivity(String id) async {
    _activities = _activities.where((a) => a.id != id).toList();
    await _storage.saveActivities(_activities);
    notifyListeners();
  }

  // --- Weight logging ---
  Future<void> logWeight(double kg) async {
    final entry = WeightEntry(
      id: _uuid.v4(),
      kg: kg,
      loggedAt: DateTime.now(),
    );
    _weightLog = [..._weightLog, entry];
    await _storage.saveWeightLog(_weightLog);
    notifyListeners();
  }

  // --- Custom foods ---
  Future<void> addCustomFood(FoodItem item) async {
    _customFoods = [item, ..._customFoods];
    await _storage.saveCustomFoods(_customFoods);
    notifyListeners();
  }

  Future<void> deleteCustomFood(String id) async {
    _customFoods = _customFoods.where((f) => f.id != id).toList();
    await _storage.saveCustomFoods(_customFoods);
    notifyListeners();
  }

  // --- Recipes ---
  Future<void> saveRecipe(Recipe recipe) async {
    final idx = _recipes.indexWhere((r) => r.id == recipe.id);
    if (idx >= 0) {
      _recipes = [..._recipes.sublist(0, idx), recipe, ..._recipes.sublist(idx + 1)];
    } else {
      _recipes = [recipe, ..._recipes];
    }
    await _storage.saveRecipes(_recipes);
    notifyListeners();
  }

  Future<void> deleteRecipe(String id) async {
    _recipes = _recipes.where((r) => r.id != id).toList();
    await _storage.saveRecipes(_recipes);
    notifyListeners();
  }

  Future<int> logRecipe(Recipe recipe, int servingCount, MealType meal) async {
    final item = recipe.toFoodItem();
    final grams = recipe.gramsPerServing * servingCount;
    await logFood(item, grams, meal);
    return servingCount;
  }

  // --- User profile ---
  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await _storage.saveUserProfile(profile);
    notifyListeners();
  }

  bool get onboardingDone => _storage.onboardingDone;
  Future<void> markOnboardingDone() => _storage.setOnboardingDone(true);

  // --- Review prompt ---
  Future<void> _maybeRequestReview() async {
    if (_streak < 3) return;

    final lastRaw = _storage.lastReviewDate;
    if (lastRaw != null) {
      final last = DateTime.tryParse(lastRaw);
      if (last != null &&
          DateTime.now().difference(last).inDays < 60) return;
    }

    final review = InAppReview.instance;
    if (!await review.isAvailable()) return;

    await review.requestReview();
    // Record the date only after a successful call so a platform failure
    // doesn't silently burn the 60-day cooldown.
    await _storage.setLastReviewDate(DateTime.now().toIso8601String());
  }

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
