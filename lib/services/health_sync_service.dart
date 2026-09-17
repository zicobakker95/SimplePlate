import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/food_entry.dart';
import '../models/weight_entry.dart';
import 'health_service.dart';
import 'subscription_service.dart';

/// Keeps Apple Health / Health Connect in step with the log — a Premium
/// feature, switched on in Goals.
///
/// The store calls in after every change to today's totals and after every
/// weight entry; nothing here blocks or throws back into the log. Three
/// things have to be true for a write to happen: the user turned sync on
/// (the store checks that, it owns the setting), they are Premium, and
/// Health granted access. The last two are checked here, at write time,
/// so a lapsed subscription stops the writes without anyone flipping a
/// switch.
class HealthSyncService {
  HealthSyncService._();
  static final instance = HealthSyncService._();

  /// Overridable so tests can flip Premium without a store.
  @visibleForTesting
  bool Function() isPremium = () => SubscriptionService.instance.isPremium;

  HealthService get _health => HealthService.instance;

  bool get _canWrite => isPremium() && _health.isAuthorised;

  /// At startup, when the setting is on: re-establish the grant silently so
  /// the first log of the day is written without a prompt.
  Future<void> restore() async {
    await _health.restoreAuthorisation();
  }

  /// Asks Health for access. Returns whether it was granted.
  Future<bool> connect() => _health.requestPermissions();

  /// The diary for [day] changed; Health gets the whole day again. Writes
  /// are serialised so two quick edits cannot interleave their delete and
  /// rewrite steps.
  void onDayChanged(DateTime day, List<FoodEntry> entries) {
    if (!_canWrite) return;
    unawaited(syncDay(day, entries).then((ok) {
      if (!ok) debugPrint('HealthSyncService: nutrition write refused');
    }));
  }

  Future<bool> _queue = Future.value(true);

  /// Writes [entries] as [day]'s nutrition and reports whether Health took
  /// them. Also behind the manual "Sync nutrition" button.
  Future<bool> syncDay(DateTime day, List<FoodEntry> entries) {
    final samples = [
      for (final e in entries)
        NutritionSample(
          at: e.loggedAt,
          calories: e.calories,
          protein: e.protein,
          carbs: e.carbs,
          fat: e.fat,
        ),
    ];
    return _queue = _queue
        .catchError((_) => false)
        .then((_) => _health.writeDayNutrition(day, samples));
  }

  void onWeightLogged(WeightEntry entry) {
    if (!_canWrite) return;
    unawaited(_health.writeWeight(entry.kg, at: entry.loggedAt).then((ok) {
      if (!ok) debugPrint('HealthSyncService: weight write refused');
    }));
  }

  /// The newest weight Health knows about, for the card to offer into the
  /// log. Null when there is none, or when reading is not allowed.
  Future<HealthWeight?> latestWeight() async {
    if (!_canWrite) return null;
    return _health.fetchLatestWeight();
  }
}
