import 'package:flutter/widgets.dart';

import '../models/food_entry.dart';
import '../models/serving_unit.dart';
import '../models/user_profile.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Concise access: `context.l10n.someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension MealTypeL10n on MealType {
  String localizedLabel(AppLocalizations l) => switch (this) {
        MealType.breakfast => l.mealBreakfast,
        MealType.lunch => l.mealLunch,
        MealType.dinner => l.mealDinner,
        MealType.snack => l.mealSnack,
      };
}

extension ServingUnitL10n on ServingUnit {
  String localizedLabel(AppLocalizations l) => switch (this) {
        ServingUnit.grams => l.unitGram,
        ServingUnit.tablespoon => l.unitTablespoon,
        ServingUnit.teaspoon => l.unitTeaspoon,
        ServingUnit.cup => l.unitCup,
        ServingUnit.piece => l.unitPiece,
      };
}

extension ActivityLevelL10n on ActivityLevel {
  String localizedLabel(AppLocalizations l) => switch (this) {
        ActivityLevel.sedentary => l.activitySedentary,
        ActivityLevel.light => l.activityLight,
        ActivityLevel.moderate => l.activityModerate,
        ActivityLevel.active => l.activityVery,
        ActivityLevel.veryActive => l.activityExtra,
      };
}

extension WeightGoalL10n on WeightGoal {
  String localizedLabel(AppLocalizations l) => switch (this) {
        WeightGoal.lose => l.goalLose,
        WeightGoal.maintain => l.goalMaintain,
        WeightGoal.gain => l.goalGain,
      };
}

/// Localized BMI category from a BMI value.
String localizedBmiCategory(AppLocalizations l, double bmi) {
  if (bmi < 18.5) return l.bmiUnderweight;
  if (bmi < 25.0) return l.bmiNormal;
  if (bmi < 30.0) return l.bmiOverweight;
  return l.bmiObese;
}
