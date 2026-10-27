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

/// App locales whose resolution needs more than the language code: Chinese
/// maps to Traditional (`zh_Hant`) for zh_TW/HK/MO or script Hant; Simplified
/// (zh_CN/SG, script Hans) is not shipped and falls back to English.
Locale? resolveAppLocale(Locale? device, Iterable<Locale> supported) {
  if (device == null) return const Locale('en');
  if (device.languageCode == 'zh') {
    final script = device.scriptCode;
    final country = device.countryCode?.toUpperCase();
    final traditional = script == 'Hant' ||
        (script == null && const {'TW', 'HK', 'MO'}.contains(country));
    return traditional
        ? Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
        : const Locale('en');
  }
  for (final l in supported) {
    if (l.languageCode == device.languageCode) return l;
  }
  return const Locale('en');
}

/// Locale name for `intl` date formatting: package:intl has no `zh_Hant`,
/// so Traditional Chinese formats as `zh_TW`.
String dateLocaleOf(BuildContext context) {
  final l = Localizations.localeOf(context);
  if (l.languageCode == 'zh' && l.scriptCode == 'Hant') return 'zh_TW';
  return l.toString();
}

extension LocaleUpperX on String {
  /// Upper-case for display in the active locale: Turkish maps i -> İ and
  /// ı -> I (Dart's toUpperCase is locale-blind). Not for ids or enum names.
  String upperFor(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'tr' || lang == 'az') {
      return replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
    }
    return toUpperCase();
  }
}
