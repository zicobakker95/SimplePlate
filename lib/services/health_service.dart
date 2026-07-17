import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// Wraps the `health` package for reading calories burned (+ steps on
/// iOS) and writing food nutrition to Apple Health / Health Connect.
///
/// Android reads NO step data: Google Play's Health Connect review
/// flagged Steps as beyond the minimum scope for a calorie counter,
/// so the steps stat is an Apple Health nicety only.
class HealthService {
  HealthService._();
  static final instance = HealthService._();

  final _health = Health();

  static final _readTypes = [
    if (Platform.isIOS) HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  static final _writeTypes = [
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.DIETARY_CARBS_CONSUMED,
    HealthDataType.DIETARY_FATS_CONSUMED,
  ];

  bool _authorised = false;

  bool get isAuthorised => _authorised;

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
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED,
        ],
        startTime: start,
        endTime: now,
      );
      if (data.isEmpty) return 0;
      final active = data
          .where((d) => d.type == HealthDataType.ACTIVE_ENERGY_BURNED)
          .toList();
      final points = active.isNotEmpty ? active : data;
      return points.fold<double>(
          0,
          (s, d) =>
              s + (d.value as NumericHealthValue).numericValue.toDouble());
    } catch (e) {
      debugPrint('HealthService.fetchCaloriesBurnedToday: $e');
      return 0;
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

  /// Writes today's logged food macros to Health.
  Future<bool> writeNutrition({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    if (!_authorised) return false;
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      final results = await Future.wait([
        _health.writeHealthData(
            value: calories,
            type: HealthDataType.DIETARY_ENERGY_CONSUMED,
            startTime: start,
            endTime: now),
        _health.writeHealthData(
            value: protein,
            type: HealthDataType.DIETARY_PROTEIN_CONSUMED,
            startTime: start,
            endTime: now),
        _health.writeHealthData(
            value: carbs,
            type: HealthDataType.DIETARY_CARBS_CONSUMED,
            startTime: start,
            endTime: now),
        _health.writeHealthData(
            value: fat,
            type: HealthDataType.DIETARY_FATS_CONSUMED,
            startTime: start,
            endTime: now),
      ]);
      return results.every((r) => r);
    } catch (e) {
      debugPrint('HealthService.writeNutrition: $e');
      return false;
    }
  }
}
