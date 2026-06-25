import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity_entry.dart';
import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../models/nutrition_goals.dart';
import '../models/recipe.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';

/// Local persistence using SharedPreferences (JSON-encoded).
/// All keys are namespaced under `sp.` to avoid collisions.
class StorageService {
  StorageService._(this._prefs);

  static const _kOnboarding = 'sp.onboarding.v1';
  static const _kGoals = 'sp.goals.v1';
  static const _kEntries = 'sp.entries.v1';
  static const _kFavourites = 'sp.favourites.v1';
  static const _kRecents = 'sp.recents.v1';
  static const _kStreak = 'sp.streak.v1';
  static const _kLastLogged = 'sp.lastLogged.v1';
  static const _kWaterDate = 'sp.water.date.v1';
  static const _kWaterGlasses = 'sp.water.glasses.v1';
  static const _kWaterEnabled = 'sp.water.enabled.v1';
  static const _kWaterGoal = 'sp.water.goal.v1';
  static const _kReminderEnabled = 'sp.reminder.enabled.v1';
  static const _kReminderHour = 'sp.reminder.hour.v1';
  static const _kReminderMinute = 'sp.reminder.minute.v1';
  static const _kUserProfile = 'sp.userProfile.v1';
  static const _kWeightLog = 'sp.weightLog.v1';
  static const _kActivities = 'sp.activities.v1';
  static const _kCustomFoods = 'sp.customFoods.v1';
  static const _kLastReviewDate = 'sp.lastReviewDate.v1';
  static const _kRecipes = 'sp.recipes.v1';

  final SharedPreferences _prefs;

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // --- Onboarding ---
  bool get onboardingDone => _prefs.getBool(_kOnboarding) ?? false;
  Future<void> setOnboardingDone(bool v) => _prefs.setBool(_kOnboarding, v);

  // --- Goals ---
  NutritionGoals loadGoals() {
    final raw = _prefs.getString(_kGoals);
    if (raw == null) return const NutritionGoals.defaults();
    try {
      return NutritionGoals.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('StorageService.loadGoals: corrupted data, using defaults ($e)');
      return const NutritionGoals.defaults();
    }
  }

  Future<void> saveGoals(NutritionGoals goals) =>
      _prefs.setString(_kGoals, jsonEncode(goals.toJson()));

  // --- Food entries ---
  List<FoodEntry> loadEntries() => _loadJsonList(_kEntries, FoodEntry.fromJson);

  Future<void> saveEntries(List<FoodEntry> entries) =>
      _prefs.setStringList(
          _kEntries, entries.map((e) => jsonEncode(e.toJson())).toList());

  // --- Favourite foods ---
  List<FoodItem> loadFavourites() => _loadJsonList(_kFavourites, FoodItem.fromJson);

  Future<void> saveFavourites(List<FoodItem> items) =>
      _prefs.setStringList(
          _kFavourites, items.map((i) => jsonEncode(i.toJson())).toList());

  // --- Recent foods (last 20 unique) ---
  List<FoodItem> loadRecents() => _loadJsonList(_kRecents, FoodItem.fromJson);

  Future<void> saveRecents(List<FoodItem> items) =>
      _prefs.setStringList(
          _kRecents, items.map((i) => jsonEncode(i.toJson())).toList());

  // --- Streak ---
  int get streak => _prefs.getInt(_kStreak) ?? 0;
  Future<void> setStreak(int v) => _prefs.setInt(_kStreak, v);

  String? get lastLoggedDate => _prefs.getString(_kLastLogged);
  Future<void> setLastLoggedDate(String v) =>
      _prefs.setString(_kLastLogged, v);

  // --- Water intake ---
  String? get waterDate => _prefs.getString(_kWaterDate);
  int get waterGlasses => _prefs.getInt(_kWaterGlasses) ?? 0;
  bool get waterEnabled => _prefs.getBool(_kWaterEnabled) ?? false;
  int get waterGoal => _prefs.getInt(_kWaterGoal) ?? 8;
  Future<void> setWater(String date, int glasses) async {
    await _prefs.setString(_kWaterDate, date);
    await _prefs.setInt(_kWaterGlasses, glasses);
  }
  Future<void> setWaterSettings(bool enabled, int goal) async {
    await _prefs.setBool(_kWaterEnabled, enabled);
    await _prefs.setInt(_kWaterGoal, goal);
  }

  // --- Reminder ---
  bool get reminderEnabled => _prefs.getBool(_kReminderEnabled) ?? false;
  int get reminderHour => _prefs.getInt(_kReminderHour) ?? 20;
  int get reminderMinute => _prefs.getInt(_kReminderMinute) ?? 0;
  Future<void> setReminder(bool enabled, int hour, int minute) async {
    await _prefs.setBool(_kReminderEnabled, enabled);
    await _prefs.setInt(_kReminderHour, hour);
    await _prefs.setInt(_kReminderMinute, minute);
  }

  // --- Review prompt ---
  String? get lastReviewDate => _prefs.getString(_kLastReviewDate);
  Future<void> setLastReviewDate(String date) =>
      _prefs.setString(_kLastReviewDate, date);

  // --- User profile (TDEE calculator) ---
  UserProfile? loadUserProfile() {
    final raw = _prefs.getString(_kUserProfile);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('StorageService.loadUserProfile: corrupted data ($e)');
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) =>
      _prefs.setString(_kUserProfile, jsonEncode(profile.toJson()));

  // --- Weight log ---
  List<WeightEntry> loadWeightLog() =>
      _loadJsonList(_kWeightLog, WeightEntry.fromJson);

  Future<void> saveWeightLog(List<WeightEntry> entries) =>
      _prefs.setStringList(
          _kWeightLog, entries.map((e) => jsonEncode(e.toJson())).toList());

  // --- Activity entries ---
  List<ActivityEntry> loadActivities() =>
      _loadJsonList(_kActivities, ActivityEntry.fromJson);

  Future<void> saveActivities(List<ActivityEntry> entries) =>
      _prefs.setStringList(
          _kActivities, entries.map((e) => jsonEncode(e.toJson())).toList());

  // --- Custom foods ---
  List<FoodItem> loadCustomFoods() =>
      _loadJsonList(_kCustomFoods, FoodItem.fromJson);

  Future<void> saveCustomFoods(List<FoodItem> items) =>
      _prefs.setStringList(
          _kCustomFoods, items.map((i) => jsonEncode(i.toJson())).toList());

  // --- Recipes ---
  List<Recipe> loadRecipes() => _loadJsonList(_kRecipes, Recipe.fromJson);

  Future<void> saveRecipes(List<Recipe> recipes) =>
      _prefs.setStringList(
          _kRecipes, recipes.map((r) => jsonEncode(r.toJson())).toList());

  /// Decodes a stored JSON string list, skipping any entries that fail to
  /// parse (e.g. corrupted or malformed data) instead of losing the whole list.
  List<T> _loadJsonList<T>(
      String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getStringList(key) ?? const [];
    final result = <T>[];
    for (final s in raw) {
      try {
        result.add(fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (e) {
        debugPrint('StorageService: skipping corrupted entry for "$key" ($e)');
      }
    }
    return result;
  }
}
