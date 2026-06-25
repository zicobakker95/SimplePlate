import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Pushes calorie data to the home screen widget (Android + iOS).
class WidgetService {
  WidgetService._();
  static final instance = WidgetService._();

  static const _appGroupId = 'group.com.zibaentertainment.simplePlate';
  static const _iOSWidgetName = 'CalorieWidget';
  static const _androidWidgetName =
      'com.zibaentertainment.simple_plate.CalorieWidgetProvider';

  Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  Future<void> updateCalories({
    required double calories,
    required int goalCalories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<double>('calories', calories),
        HomeWidget.saveWidgetData<int>('goal_calories', goalCalories),
        HomeWidget.saveWidgetData<double>('protein', protein),
        HomeWidget.saveWidgetData<double>('carbs', carbs),
        HomeWidget.saveWidgetData<double>('fat', fat),
      ]);
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      debugPrint('WidgetService.updateCalories: $e');
    }
  }
}
