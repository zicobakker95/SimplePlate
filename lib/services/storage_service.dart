import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../models/nutrition_goals.dart';

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
    return NutritionGoals.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveGoals(NutritionGoals goals) =>
      _prefs.setString(_kGoals, jsonEncode(goals.toJson()));

  // --- Food entries ---
  List<FoodEntry> loadEntries() {
    final raw = _prefs.getStringList(_kEntries) ?? const [];
    return raw
        .map((s) => FoodEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEntries(List<FoodEntry> entries) =>
      _prefs.setStringList(
          _kEntries, entries.map((e) => jsonEncode(e.toJson())).toList());

  // --- Favourite foods ---
  List<FoodItem> loadFavourites() {
    final raw = _prefs.getStringList(_kFavourites) ?? const [];
    return raw
        .map((s) => FoodItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavourites(List<FoodItem> items) =>
      _prefs.setStringList(
          _kFavourites, items.map((i) => jsonEncode(i.toJson())).toList());

  // --- Recent foods (last 20 unique) ---
  List<FoodItem> loadRecents() {
    final raw = _prefs.getStringList(_kRecents) ?? const [];
    return raw
        .map((s) => FoodItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRecents(List<FoodItem> items) =>
      _prefs.setStringList(
          _kRecents, items.map((i) => jsonEncode(i.toJson())).toList());

  // --- Streak ---
  int get streak => _prefs.getInt(_kStreak) ?? 0;
  Future<void> setStreak(int v) => _prefs.setInt(_kStreak, v);

  String? get lastLoggedDate => _prefs.getString(_kLastLogged);
  Future<void> setLastLoggedDate(String v) =>
      _prefs.setString(_kLastLogged, v);
}
