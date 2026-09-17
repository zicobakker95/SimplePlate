import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// A body-weight sample read from Apple Health / Health Connect.
class HealthWeight {
  const HealthWeight({required this.kg, required this.at});
  final double kg;
  final DateTime at;
}

/// Wraps the `health` package: reads calories burned, body weight (+ steps
/// on iOS) and writes logged nutrition and weight to Apple Health / Health
/// Connect.
///
/// Android reads NO step data: Google Play's Health Connect review
/// flagged Steps as beyond the minimum scope for a calorie counter,
/// so the steps stat is an Apple Health nicety only. Weight is in scope
/// on both platforms — the app keeps a weight log of its own, and a
/// scale that writes to Health should not have to be copied by hand.
///
/// Calories burned is read from ACTIVE energy only. Total calories =
/// active + basal, and basal is just the body ticking over — it is not
/// something a food log can act on, and mixing the two under one
/// "Calories burned" label made the number mean different things
/// depending on which app had written to Health that day.
class HealthService {
  HealthService._();
  static final instance = HealthService._();

  final _health = Health();

  static final _readTypes = [
    if (Platform.isIOS) HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
  ];

  static final _writeTypes = [
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.DIETARY_CARBS_CONSUMED,
    HealthDataType.DIETARY_FATS_CONSUMED,
    HealthDataType.WEIGHT,
  ];

  bool _authorised = false;

  bool get isAuthorised => _authorised;

  /// Re-checks a grant from an earlier launch without showing a prompt.
  /// Called at startup when the user has sync switched on, so writes resume
  /// silently. Returns the new [isAuthorised].
  Future<bool> restoreAuthorisation() async {
    try {
      await _health.configure();
      final has = await _health.hasPermissions(
        _readTypes,
        permissions: _readTypes.map((_) => HealthDataAccess.READ).toList(),
      );
      // iOS never confirms a READ grant (Apple hides it), so `null` there
      // means "unknown, go ahead"; only an explicit false is a denial.
      _authorised = has != false;
    } catch (e) {
      debugPrint('HealthService.restoreAuthorisation: $e');
      _authorised = false;
    }
    return _authorised;
  }

  Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      final granted = await _health.requestAuthorization(
        _readTypes,
        permissions: _readTypes.map((_) => HealthDataAccess.READ).toList(),
      );
      // Write permissions may partially succeed; ignore result.
      await _health.requestAuthorization(
        _writeTypes,
        permissions: _writeTypes.map((_) => HealthDataAccess.READ_WRITE).toList(),
      );
      _authorised = granted;
      return granted;
    } catch (e) {
      debugPrint('HealthService.requestPermissions: $e');
      return false;
    }
  }

  /// Returns calories burned from active energy for today.
  Future<double> fetchCaloriesBurnedToday() async {
    if (!_authorised) return 0;
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: now,
      );
      return data.fold<double>(
          0,
          (s, d) =>
              s + (d.value as NumericHealthValue).numericValue.toDouble());
    } catch (e) {
      debugPrint('HealthService.fetchCaloriesBurnedToday: $e');
      return 0;
    }
  }

  /// The most recent body-weight sample in the last [lookback], or null.
  /// This includes samples the app wrote itself; the caller dedupes by day
  /// against its own log, so a write never comes back as a new entry.
  Future<HealthWeight?> fetchLatestWeight(
      {Duration lookback = const Duration(days: 90)}) async {
    if (!_authorised) return null;
    try {
      final now = DateTime.now();
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: now.subtract(lookback),
        endTime: now,
      );
      HealthDataPoint? latest;
      for (final d in data) {
        if (latest == null || d.dateFrom.isAfter(latest.dateFrom)) latest = d;
      }
      if (latest == null) return null;
      final kg = (latest.value as NumericHealthValue).numericValue.toDouble();
      if (kg < 20 || kg > 500) return null;
      return HealthWeight(kg: kg, at: latest.dateFrom);
    } catch (e) {
      debugPrint('HealthService.fetchLatestWeight: $e');
      return null;
    }
  }

  /// Writes one body-weight sample. Health stores kilograms natively.
  Future<bool> writeWeight(double kg, {required DateTime at}) async {
    if (!_authorised) return false;
    try {
      return await _health.writeHealthData(
        value: kg,
        type: HealthDataType.WEIGHT,
        startTime: at,
        endTime: at,
      );
    } catch (e) {
      debugPrint('HealthService.writeWeight: $e');
      return false;
    }
  }

  /// Returns step count for today (iOS only — no Android permission).
  Future<int> fetchStepsToday() async {
    if (!_authorised || !Platform.isIOS) return 0;
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(start, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('HealthService.fetchStepsToday: $e');
      return 0;
    }
  }

  /// Replaces the day's nutrition in Health with [entries], one sample per
  /// logged food at the time it was logged.
  ///
  /// Health apps sum samples, so writing a running day total on every change
  /// would double-count. Instead the app's own samples for [day] are removed
  /// and the day is written again from the log — which also makes an edit
  /// or a deletion in the diary show up in Health. Only this app's samples
  /// are touched; anything another app wrote stays.
  Future<bool> writeDayNutrition(DateTime day, List<NutritionSample> entries) async {
    if (!_authorised) return false;
    try {
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      for (final type in _nutritionTypes) {
        await _health.delete(type: type, startTime: start, endTime: end);
      }
      var ok = true;
      for (final e in entries) {
        // A zero sample is noise in Health; skip it rather than write it.
        final values = {
          HealthDataType.DIETARY_ENERGY_CONSUMED: e.calories,
          HealthDataType.DIETARY_PROTEIN_CONSUMED: e.protein,
          HealthDataType.DIETARY_CARBS_CONSUMED: e.carbs,
          HealthDataType.DIETARY_FATS_CONSUMED: e.fat,
        };
        for (final entry in values.entries) {
          if (entry.value <= 0) continue;
          final written = await _health.writeHealthData(
            value: entry.value,
            type: entry.key,
            startTime: e.at,
            endTime: e.at,
          );
          ok = ok && written;
        }
      }
      return ok;
    } catch (e) {
      debugPrint('HealthService.writeDayNutrition: $e');
      return false;
    }
  }

  static const _nutritionTypes = [
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.DIETARY_CARBS_CONSUMED,
    HealthDataType.DIETARY_FATS_CONSUMED,
  ];
}

/// One logged food as Health sees it: the four values and when it was eaten.
class NutritionSample {
  const NutritionSample({
    required this.at,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final DateTime at;
  final double calories, protein, carbs, fat;
}
