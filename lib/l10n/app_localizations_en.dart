// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get update => 'Update';

  @override
  String get reset => 'Reset';

  @override
  String get remove => 'Remove';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get logAction => 'Log';

  @override
  String get getStarted => 'Get started';

  @override
  String get continueLabel => 'Continue';

  @override
  String get letsGo => 'Let\'s go!';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get tryAgain => 'Try again';

  @override
  String get navToday => 'Today';

  @override
  String get navHistory => 'History';

  @override
  String get navGoals => 'Goals';

  @override
  String get macroCalories => 'Calories';

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroFat => 'Fat';

  @override
  String get fieldCalories => 'Calories';

  @override
  String get fieldProtein => 'Protein';

  @override
  String get fieldCarbohydrates => 'Carbohydrates';

  @override
  String get fieldFat => 'Fat';

  @override
  String get fieldDailyCalories => 'Daily calories';

  @override
  String get fieldProteinPct => 'Protein %';

  @override
  String get fieldCarbsPct => 'Carbohydrates %';

  @override
  String get fieldFatPct => 'Fat %';

  @override
  String get calculatedCalories => 'Calculated calories';

  @override
  String get goalModeManual => 'Manual';

  @override
  String get goalModePercent => '% → Macros';

  @override
  String get goalModeMacros => 'Macros → kcal';

  @override
  String get goalModeManualDesc =>
      'Enter your calories and macro grams directly.';

  @override
  String get goalModePercentDesc =>
      'Enter total calories and the % split — grams are calculated live.';

  @override
  String get goalModeMacrosDesc =>
      'Enter your macro grams — total calories are calculated live.';

  @override
  String get pctTotalOk => 'Percentages add up to 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return 'Percentages add up to $sum% (should be 100%)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g protein';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g carbs';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g fat';
  }

  @override
  String get welcomeTitle => 'Welcome to PlateSimple';

  @override
  String get welcomeSubtitle =>
      'Fast, clean calorie tracking.\nFree barcode scanning. No clutter.';

  @override
  String get onbSetGoalsTitle => 'Set your daily goals';

  @override
  String get onbSetGoalsSubtitle => 'You can change these anytime in Goals.';

  @override
  String get onbStayOnTrackTitle => 'Stay on track';

  @override
  String get onbStayOnTrackBody =>
      'Allow notifications so we can remind you to log meals and keep your streak alive.';

  @override
  String get goalsDailyTargets => 'Daily nutrition targets';

  @override
  String get goalsChooseHow => 'Choose how you want to set your goals.';

  @override
  String get goalsCalcTdee => 'Calculate with TDEE / BMI';

  @override
  String get goalsSaveBtn => 'Save goals';

  @override
  String get goalsSavedSnack => 'Goals saved!';

  @override
  String get waterTrackingTitle => 'Water tracking';

  @override
  String get waterTrackingSubtitle =>
      'Track your daily water intake on the home screen.';

  @override
  String get waterShowTracker => 'Show water tracker';

  @override
  String get waterShowTrackerSub => 'Displays water card on Today screen';

  @override
  String get waterDailyGoal => 'Daily goal';

  @override
  String get waterGlassesUnit => 'glasses';

  @override
  String get water => 'Water';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal glasses';
  }

  @override
  String get resetWaterTitle => 'Reset water?';

  @override
  String get resetWaterBody => 'Set today\'s water count back to 0?';

  @override
  String get reminderTitle => 'Daily reminder';

  @override
  String get reminderSubtitle => 'Get a daily nudge to log your meals.';

  @override
  String get reminderEnable => 'Enable reminder';

  @override
  String get reminderEnableSub => 'Sends a daily notification';

  @override
  String get reminderTimeLabel => 'Reminder time';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackBody =>
      'I\'m a solo developer and your feedback helps make PlateSimple better. Takes less than a minute!';

  @override
  String get feedbackShare => 'Share feedback';

  @override
  String get dataExportTitle => 'Data export';

  @override
  String get dataExportSubtitle =>
      'Export your food log, weight, and activity data.';

  @override
  String get exportCsv => 'Export as CSV';

  @override
  String get exportCsvSub => 'Spreadsheet-compatible format';

  @override
  String get exportJson => 'Export as JSON';

  @override
  String get exportJsonSub => 'Full data backup';

  @override
  String get aboutTitle => 'About PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => 'Upgrade to Premium';

  @override
  String get premiumBannerMemberTitle => 'You\'re a Premium member';

  @override
  String get premiumBannerUpgradeSub =>
      'Weekly insights · No ads · Support dev';

  @override
  String get premiumBannerMemberSub => 'Weekly insights unlocked · No ads';

  @override
  String get tdeeTitle => 'TDEE Calculator';

  @override
  String get tdeeSubtitle =>
      'Enter your stats to calculate Total Daily Energy Expenditure and auto-set your calorie goal.';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get fieldAge => 'Age';

  @override
  String get fieldHeight => 'Height';

  @override
  String get fieldWeight => 'Weight';

  @override
  String get unitYears => 'years';

  @override
  String get activityLevelLabel => 'Activity level';

  @override
  String get goalLabel => 'Goal';

  @override
  String get calculate => 'Calculate';

  @override
  String get tdeeInvalid => 'Please enter valid values for all fields.';

  @override
  String get yourResults => 'Your Results';

  @override
  String get bmrLabel => 'BMR (base metabolic rate)';

  @override
  String get tdeeMaintenance => 'TDEE (maintenance)';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get suggestedGoals => 'Suggested goals';

  @override
  String get applyGoals => 'Apply these goals';

  @override
  String get tdeeAppliedSnack => 'Goals updated from TDEE calculator!';

  @override
  String get activitySedentary => 'Sedentary (little or no exercise)';

  @override
  String get activityLight => 'Lightly active (1–3 days/week)';

  @override
  String get activityModerate => 'Moderately active (3–5 days/week)';

  @override
  String get activityVery => 'Very active (6–7 days/week)';

  @override
  String get activityExtra => 'Extra active (physical job + training)';

  @override
  String get goalLose => 'Lose weight';

  @override
  String get goalMaintain => 'Maintain weight';

  @override
  String get goalGain => 'Gain weight';

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiNormal => 'Normal weight';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObese => 'Obese';

  @override
  String get todayShareTooltip => 'Share your day';

  @override
  String get todayCopyTooltip => 'Copy yesterday\'s meals';

  @override
  String get logFood => 'Log food';

  @override
  String get emptyTodayTitle => 'Nothing logged yet today';

  @override
  String get emptyTodayBody =>
      'Log your first meal to start tracking calories and macros.';

  @override
  String get copyYesterdayTitle => 'Copy yesterday?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copy $count items from yesterday to today?',
      one: 'Copy 1 item from yesterday to today?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'No entries logged yesterday.';

  @override
  String get copyAction => 'Copy';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copied $count items from yesterday.',
      one: 'Copied 1 item from yesterday.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal eaten';

  @override
  String get netKcal => 'net kcal';

  @override
  String kcalLeft(int n) {
    return '$n left';
  }

  @override
  String kcalOver(int n) {
    return '$n over';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n burned';
  }

  @override
  String get bodyWeight => 'Body weight';

  @override
  String get notLoggedToday => 'Not logged today';

  @override
  String get logWeight => 'Log weight';

  @override
  String get weightInvalid => 'Enter a valid weight.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg kg  ·  logged today';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg kg  ·  logged $date';
  }

  @override
  String get healthSync => 'Health sync';

  @override
  String get healthConnectApple =>
      'Connect Apple Health to import calories burned and sync your nutrition.';

  @override
  String get healthConnectGoogle =>
      'Connect Google Health Connect to import calories burned and sync your nutrition.';

  @override
  String get connectHealth => 'Connect Health';

  @override
  String get healthDeniedIos =>
      'Open Settings → Privacy & Security → Health → PlateSimple to grant access.';

  @override
  String get healthDeniedAndroid =>
      'Open Health Connect and grant PlateSimple permissions.';

  @override
  String get statSteps => 'Steps';

  @override
  String get statBurned => 'Burned';

  @override
  String get syncNutrition => 'Sync nutrition to Health';

  @override
  String get healthSynced => 'Nutrition synced to Health!';

  @override
  String get healthWriteFailed => 'Could not write to Health.';

  @override
  String get healthNotGranted =>
      'Health access not granted. Check permissions.';

  @override
  String get activity => 'Activity';

  @override
  String get noActivityToday => 'No activity logged today.';

  @override
  String get addActivity => 'Add activity';

  @override
  String get logActivityTitle => 'Log activity';

  @override
  String get presets => 'Presets';

  @override
  String get manual => 'Manual';

  @override
  String get activityNameLabel => 'Activity name';

  @override
  String get activityNameHint => 'e.g. Soccer, Dancing…';

  @override
  String get caloriesBurnedLabel => 'Calories burned';

  @override
  String get durationLabel => 'Duration';

  @override
  String estimatedBurned(int n) {
    return 'Estimated: ~$n kcal burned';
  }

  @override
  String get enterValidDuration => 'Enter a valid duration.';

  @override
  String get enterCaloriesBurned => 'Enter calories burned.';

  @override
  String get selectActivityFirst => 'Select an activity first.';

  @override
  String get customActivity => 'Custom activity';

  @override
  String get actWalking => 'Walking';

  @override
  String get actRunning => 'Running';

  @override
  String get actCycling => 'Cycling';

  @override
  String get actSwimming => 'Swimming';

  @override
  String get actWeightTraining => 'Weight training';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Hiking';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get deleteEntryTitle => 'Delete entry?';

  @override
  String deleteEntryBody(String name, String meal) {
    return 'Remove \"$name\" from $meal?';
  }

  @override
  String get holdToEdit => 'hold to edit';

  @override
  String get servingSizeLabel => 'Serving size';

  @override
  String get addFoodTitle => 'Add food';

  @override
  String get pickIngredientTitle => 'Pick ingredient';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabRecentFav => 'Recent & Favourites';

  @override
  String get tabRecipes => 'Recipes';

  @override
  String get tabMyFoods => 'My Foods';

  @override
  String get searchHint => 'Search foods…';

  @override
  String get scanTooltip => 'Scan barcode';

  @override
  String noResults(String query) {
    return 'No results found for \"$query\".\nTry a more specific term or scan the barcode.';
  }

  @override
  String searchErrorRetry(String error) {
    return '$error\nPull down to retry.';
  }

  @override
  String get createCustomFood => 'Create custom food';

  @override
  String get sectionFavourites => 'Favourites ⭐';

  @override
  String get sectionRecent => 'Recent';

  @override
  String get noFoodsYet => 'No foods yet.';

  @override
  String get unlockScannerTitle => 'Unlock barcode scanner';

  @override
  String get unlockScannerBody =>
      'Watch a short ad to unlock the barcode scanner for the rest of the day.';

  @override
  String get watchAd => 'Watch ad';

  @override
  String get adUnavailable =>
      'Ad unavailable right now. Try again in a moment.';

  @override
  String get productNotFound => 'Product not found in database.';

  @override
  String get createNewRecipe => 'Create new recipe';

  @override
  String get noRecipesYet =>
      'No recipes yet.\nTap \"Create new recipe\" to start.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '1 serving',
    );
    return '$kcal kcal/serving  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '$kcal kcal per serving';
  }

  @override
  String get servingsToLog => 'Servings to log';

  @override
  String get createRecipeTitle => 'Create recipe';

  @override
  String get editRecipeTitle => 'Edit recipe';

  @override
  String get recipeNameLabel => 'Recipe name';

  @override
  String get recipeNameRequired => 'Recipe name is required.';

  @override
  String get recipeDescLabel => 'Description (optional)';

  @override
  String get servingsLabel => 'Servings';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get addAtLeastOne => 'Add at least one ingredient.';

  @override
  String get noIngredientsYet => 'No ingredients yet.';

  @override
  String get nutritionSummary => 'Nutrition summary';

  @override
  String get total => 'Total';

  @override
  String get perServing => 'Per serving';

  @override
  String perServingCount(int count) {
    return 'Per serving ($count servings)';
  }

  @override
  String get createCustomFoodTitle => 'Create custom food';

  @override
  String get foodDetailsSection => 'Food details';

  @override
  String get valuesPer100 => 'Values are per 100 g / 100 ml.';

  @override
  String get foodNameLabel => 'Food name';

  @override
  String get brandOptional => 'Brand (optional)';

  @override
  String get nutritionPer100 => 'Nutrition per 100 g';

  @override
  String get fieldRequired => 'Required';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get saveAndLog => 'Save & log serving';

  @override
  String get removeFavourite => 'Remove favourite';

  @override
  String get addToFavourites => 'Add to favourites';

  @override
  String get servingSizeG => 'Serving size (g)';

  @override
  String get addToLabel => 'Add to';

  @override
  String addToMeal(String meal) {
    return 'Add to $meal';
  }

  @override
  String get scanBarcodeTitle => 'Scan barcode';

  @override
  String get historyTitle => 'History';

  @override
  String get noLoggedDays => 'No logged days yet.';

  @override
  String get today => 'Today';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => 'Weekly Insights';

  @override
  String get premiumFeature => 'Premium feature';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get sevenDayAverage => '7-Day Average';

  @override
  String kcalAvg(int n) {
    return '$n kcal avg';
  }

  @override
  String get kcalAvgEmpty => '— kcal avg';

  @override
  String get weightTrend => 'Weight trend';

  @override
  String get prevMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get shareDayTitle => 'Share your day';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => 'Goal hit!';

  @override
  String ofGoal(int n) {
    return 'of $n goal';
  }

  @override
  String get trackedWith => 'tracked with PlateSimple';

  @override
  String get preparing => 'Preparing…';

  @override
  String get share => 'Share';

  @override
  String shareText(String url) {
    return 'My nutrition today — tracked with PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle => 'Unlock the full experience';

  @override
  String get featInsightsTitle => '7-day weekly insights';

  @override
  String get featInsightsSub =>
      'See your calorie sparkline and 7-day average at a glance.';

  @override
  String get featAdFreeTitle => 'Ad-free experience';

  @override
  String get featAdFreeSub => 'No interstitial ads, no rewarded ads. Ever.';

  @override
  String get featSupportTitle => 'Support a solo developer';

  @override
  String get featSupportSub =>
      'PlateSimple is built and maintained by one person. Your subscription keeps it going.';

  @override
  String get loadPricingError =>
      'Could not load pricing.\nCheck your connection and try again.';

  @override
  String get choosePlan => 'Choose a plan';

  @override
  String get alreadyPremium => 'You\'re already Premium ✓';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get subsRenew =>
      'Subscriptions renew automatically. Cancel anytime in your device settings.';

  @override
  String get premiumRestored => 'Premium restored successfully!';

  @override
  String get noSubFound => 'No active subscription found.';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get billedYearly => 'Billed once per year';

  @override
  String get billedMonthly => 'Billed monthly';

  @override
  String get freeTrial => 'Free trial';

  @override
  String get legendUnder => 'Under';

  @override
  String get legendOnTarget => 'On target';

  @override
  String get legendOver => 'Over';

  @override
  String get notifTitle => 'Time to log your meals 🥗';

  @override
  String get notifBody => 'Keep your streak going — log what you ate today!';

  @override
  String get notifChannelName => 'Daily Reminders';

  @override
  String get notifChannelDesc => 'Reminds you to log your meals each day';
}
