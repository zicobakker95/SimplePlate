// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

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
  String get rateApp => 'Rate PlateSimple';

  @override
  String get rateAppSub => 'A review helps others find PlateSimple';

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
      'Weekly insights · Weight trend · Health sync · No ads';

  @override
  String get premiumBannerMemberSub =>
      'Weekly insights · Weight trend · Health sync · No ads';

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
    return '$kg  ·  logged today';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg  ·  logged $date';
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
  String get tapToEdit => 'tap to edit';

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
  String get unitGram => 'Gram';

  @override
  String get unitTablespoon => 'Tablespoon';

  @override
  String get unitTeaspoon => 'Teaspoon';

  @override
  String get unitCup => 'Cup';

  @override
  String get unitPiece => 'Piece';

  @override
  String approxGrams(int grams) {
    return '≈ $grams g';
  }

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
  String get noEntriesThatDay => 'No foods logged on this day.';

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
  String get premiumSubtitle =>
      'Weekly insights · Weight trend · Health sync · No ads';

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
  String get paymentPending =>
      'Payment pending. Premium unlocks automatically once it\'s paid.';

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

  @override
  String get servingOne => '1 serving';

  @override
  String servingMany(String count) {
    return '$count servings';
  }

  @override
  String get gramsPerServingLabel => 'Serving size (g)';

  @override
  String get gramsPerServingHint =>
      'Optional. Lets amounts show as servings, e.g. 100 g (2 servings).';

  @override
  String get unlockWithAdToday => 'Watch an ad to see it today';

  @override
  String get unlockedForToday => 'Unlocked for today';

  @override
  String get unlockAdUnavailable =>
      'No video available right now. Try again in a moment.';

  @override
  String get retry => 'Retry';

  @override
  String get sectionYourFoods => 'Your foods';

  @override
  String get sectionOpenFoodFacts => 'Open Food Facts';

  @override
  String get searchCachedLabel => 'Saved results';

  @override
  String get searchOfflineCached => 'Offline · saved results';

  @override
  String get searchTypeMore => 'Searching Open Food Facts as you type…';

  @override
  String get searchEmptyPrompt =>
      'Search Open Food Facts or scan a barcode.\nFoods you log will show up here.';

  @override
  String noMatchFor(String query) {
    return 'No match for \"$query\"';
  }

  @override
  String get noMatchHint =>
      'Add it yourself — it takes a few seconds and it\'s yours to reuse.';

  @override
  String get addAsCustomFood => 'Add as custom food';

  @override
  String get quickAddCalories => 'Quick add calories';

  @override
  String get quickAddTitle => 'Quick add';

  @override
  String get quickAddNameLabel => 'Name (optional)';

  @override
  String get optionalMacros => 'Macros (optional)';

  @override
  String get weightUnitTitle => 'Weight unit';

  @override
  String get weightUnitSub => 'For logging and the trend chart.';

  @override
  String get goalsWeightSubtitle =>
      'Log a weigh-in here or from Today. The trend chart is under History.';

  @override
  String weightTrendDays(int n) {
    return '$n days';
  }

  @override
  String weightTrendChange(String delta, int days) {
    return '$delta over $days days';
  }

  @override
  String get weightTrendNoChange =>
      'Log again in a few days to see the change.';

  @override
  String get weightTrendNeedMore =>
      'Log your weight a couple more times and the trend will show here.';

  @override
  String get weightTrendTeaserSub =>
      '30- and 90-day chart with a 7-day average that smooths out daily swings.';

  @override
  String get weightTrendLoggedLegend => 'Logged';

  @override
  String get weightTrendAverageLegend => '7-day average';

  @override
  String get healthSyncSettingApple => 'Sync with Apple Health';

  @override
  String get healthSyncSettingGoogle => 'Sync with Health Connect';

  @override
  String get healthSyncSettingSubtitle =>
      'Keep your health app in step with what you log here.';

  @override
  String get healthSyncExplainApple =>
      'When on, PlateSimple writes the calories, macros and weight you log to Apple Health, and reads your steps, active calories and weight from it. You choose exactly what to allow in the Health prompt. Nothing is sent anywhere else.';

  @override
  String get healthSyncExplainGoogle =>
      'When on, PlateSimple writes the calories, macros and weight you log to Health Connect, and reads your active calories and weight from it. You choose exactly what to allow in the Health Connect prompt. Nothing is sent anywhere else.';

  @override
  String get healthSyncPremiumOnly => 'Health sync is part of Premium.';

  @override
  String get healthSyncTeaserSub =>
      'Send what you log to Apple Health or Health Connect, and bring steps and weight back.';

  @override
  String get statWeight => 'Weight';

  @override
  String get healthWeightImported => 'Weight from Health added to your log.';

  @override
  String healthAddWeightToLog(String weight) {
    return 'Add $weight to log';
  }

  @override
  String get featWeightTrendTitle => 'Weight trend';

  @override
  String get featWeightTrendSub =>
      '30- and 90-day chart with a 7-day average and your change over the period.';

  @override
  String get featHealthSyncTitle => 'Health sync';

  @override
  String get featHealthSyncSub =>
      'Logged calories and weight go to Apple Health or Health Connect; steps and weight come back.';

  @override
  String get privacyOptions => 'Privacy options';

  @override
  String get privacyOptionsSubtitle =>
      'Change your consent for personalised ads';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceSubtitle =>
      'Follow your phone\'s setting or pick a look.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get goalReachedToast => 'Right on target today. Nicely done!';

  @override
  String get waterGoalToast => 'Water goal reached. Cheers!';

  @override
  String foodLoggedToast(String food, String meal) {
    return '$food added to $meal';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get searchStartTitle => 'What\'s on your plate?';

  @override
  String get mealEmptyHint => 'Nothing yet';

  @override
  String get scanHint => 'Line up the barcode inside the frame';

  @override
  String get torchTooltip => 'Flashlight';

  @override
  String get waterAddGlass => 'Add a glass';

  @override
  String get waterRemoveGlass => 'Remove a glass';

  @override
  String get premiumTag => 'Premium';

  @override
  String get adNotReadyTitle => 'No video right now';

  @override
  String get adNotReadyPremiumHint =>
      'Premium unlocks this for good, with no ads.';

  @override
  String get shareFailed => 'Couldn\'t share right now. Please try again.';

  @override
  String get reminderPermissionDenied =>
      'Notifications are off for PlateSimple. Turn them on in Settings to get reminders.';

  @override
  String get privacyPolicySubtitle => 'How PlateSimple handles your data';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get delete => '刪除';

  @override
  String get update => '更新';

  @override
  String get reset => '重設';

  @override
  String get remove => '移除';

  @override
  String get edit => '編輯';

  @override
  String get add => '新增';

  @override
  String get logAction => '記錄';

  @override
  String get getStarted => '開始使用';

  @override
  String get continueLabel => '繼續';

  @override
  String get letsGo => '出發吧！';

  @override
  String get skipForNow => '先跳過';

  @override
  String get openSettings => '開啟設定';

  @override
  String get tryAgain => '再試一次';

  @override
  String get navToday => '今天';

  @override
  String get navHistory => '紀錄';

  @override
  String get navGoals => '目標';

  @override
  String get macroCalories => '卡路里';

  @override
  String get macroProtein => '蛋白質';

  @override
  String get macroCarbs => '碳水';

  @override
  String get macroFat => '脂肪';

  @override
  String get fieldCalories => '卡路里';

  @override
  String get fieldProtein => '蛋白質';

  @override
  String get fieldCarbohydrates => '碳水化合物';

  @override
  String get fieldFat => '脂肪';

  @override
  String get fieldDailyCalories => '每日卡路里';

  @override
  String get fieldProteinPct => '蛋白質 %';

  @override
  String get fieldCarbsPct => '碳水化合物 %';

  @override
  String get fieldFatPct => '脂肪 %';

  @override
  String get calculatedCalories => '計算後的卡路里';

  @override
  String get goalModeManual => '手動';

  @override
  String get goalModePercent => '% → 營養素';

  @override
  String get goalModeMacros => '營養素 → kcal';

  @override
  String get goalModeManualDesc => '直接輸入卡路里與各營養素的公克數。';

  @override
  String get goalModePercentDesc => '輸入總卡路里與百分比分配，公克數會即時計算。';

  @override
  String get goalModeMacrosDesc => '輸入各營養素的公克數，總卡路里會即時計算。';

  @override
  String get pctTotalOk => '百分比總和為 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return '百分比總和為 $sum%（應為 100%）';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g 蛋白質';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g 碳水化合物';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g 脂肪';
  }

  @override
  String get welcomeTitle => '歡迎使用 PlateSimple';

  @override
  String get welcomeSubtitle => '快速、簡潔的卡路里記錄。\n免費掃描條碼，介面清爽不雜亂。';

  @override
  String get onbSetGoalsTitle => '設定每日目標';

  @override
  String get onbSetGoalsSubtitle => '之後隨時都可以在「目標」中修改。';

  @override
  String get onbStayOnTrackTitle => '保持節奏';

  @override
  String get onbStayOnTrackBody => '開啟通知，我們就能提醒你記錄餐點，讓連續天數不中斷。';

  @override
  String get goalsDailyTargets => '每日營養目標';

  @override
  String get goalsChooseHow => '選擇你想設定目標的方式。';

  @override
  String get goalsCalcTdee => '用 TDEE / BMI 計算';

  @override
  String get goalsSaveBtn => '儲存目標';

  @override
  String get goalsSavedSnack => '目標已儲存！';

  @override
  String get waterTrackingTitle => '飲水紀錄';

  @override
  String get waterTrackingSubtitle => '在主畫面記錄你每天的飲水量。';

  @override
  String get waterShowTracker => '顯示飲水紀錄';

  @override
  String get waterShowTrackerSub => '在「今天」畫面顯示飲水卡片';

  @override
  String get waterDailyGoal => '每日目標';

  @override
  String get waterGlassesUnit => '杯';

  @override
  String get water => '飲水';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal 杯';
  }

  @override
  String get resetWaterTitle => '重設飲水量？';

  @override
  String get resetWaterBody => '要將今天的飲水量重設為 0 嗎？';

  @override
  String get reminderTitle => '每日提醒';

  @override
  String get reminderSubtitle => '每天提醒你記錄餐點。';

  @override
  String get reminderEnable => '開啟提醒';

  @override
  String get reminderEnableSub => '每天發送一則通知';

  @override
  String get reminderTimeLabel => '提醒時間';

  @override
  String get feedbackTitle => '意見回饋';

  @override
  String get feedbackBody => '我是獨立開發者，你的意見能讓 PlateSimple 變得更好。只需不到一分鐘！';

  @override
  String get feedbackShare => '分享意見';

  @override
  String get rateApp => '為 PlateSimple 評分';

  @override
  String get rateAppSub => '一則評價能幫助更多人找到 PlateSimple';

  @override
  String get dataExportTitle => '匯出資料';

  @override
  String get dataExportSubtitle => '匯出你的飲食紀錄、體重與運動資料。';

  @override
  String get exportCsv => '匯出為 CSV';

  @override
  String get exportCsvSub => '可用試算表開啟的格式';

  @override
  String get exportJson => '匯出為 JSON';

  @override
  String get exportJsonSub => '完整資料備份';

  @override
  String get aboutTitle => '關於 PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => '升級至 Premium';

  @override
  String get premiumBannerMemberTitle => '你是 Premium 會員';

  @override
  String get premiumBannerUpgradeSub => '每週分析 · 體重趨勢 · 健康資料同步 · 無廣告';

  @override
  String get premiumBannerMemberSub => '每週分析 · 體重趨勢 · 健康資料同步 · 無廣告';

  @override
  String get tdeeTitle => 'TDEE 計算機';

  @override
  String get tdeeSubtitle => '輸入你的身體資料，計算每日總能量消耗 (TDEE)，並自動設定卡路里目標。';

  @override
  String get sexMale => '男';

  @override
  String get sexFemale => '女';

  @override
  String get fieldAge => '年齡';

  @override
  String get fieldHeight => '身高';

  @override
  String get fieldWeight => '體重';

  @override
  String get unitYears => '歲';

  @override
  String get activityLevelLabel => '活動量';

  @override
  String get goalLabel => '目標';

  @override
  String get calculate => '計算';

  @override
  String get tdeeInvalid => '請在所有欄位輸入有效的數值。';

  @override
  String get yourResults => '你的結果';

  @override
  String get bmrLabel => 'BMR（基礎代謝率）';

  @override
  String get tdeeMaintenance => 'TDEE（維持體重）';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get suggestedGoals => '建議目標';

  @override
  String get applyGoals => '套用這些目標';

  @override
  String get tdeeAppliedSnack => '已根據 TDEE 計算機更新目標！';

  @override
  String get activitySedentary => '久坐（幾乎不運動）';

  @override
  String get activityLight => '輕度活動（每週 1–3 天）';

  @override
  String get activityModerate => '中度活動（每週 3–5 天）';

  @override
  String get activityVery => '高度活動（每週 6–7 天）';

  @override
  String get activityExtra => '極高活動（體力工作＋訓練）';

  @override
  String get goalLose => '減重';

  @override
  String get goalMaintain => '維持體重';

  @override
  String get goalGain => '增重';

  @override
  String get bmiUnderweight => '體重過輕';

  @override
  String get bmiNormal => '正常體重';

  @override
  String get bmiOverweight => '體重過重';

  @override
  String get bmiObese => '肥胖';

  @override
  String get todayShareTooltip => '分享你的一天';

  @override
  String get todayCopyTooltip => '複製昨天的餐點';

  @override
  String get logFood => '記錄食物';

  @override
  String get emptyTodayTitle => '今天還沒有任何紀錄';

  @override
  String get emptyTodayBody => '記錄第一餐，開始追蹤卡路里與營養素。';

  @override
  String get copyYesterdayTitle => '複製昨天的紀錄？';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '要將昨天的 $count 個項目複製到今天嗎？',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => '昨天沒有任何紀錄。';

  @override
  String get copyAction => '複製';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已複製昨天的 $count 個項目。',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal 已攝取';

  @override
  String get netKcal => '淨 kcal';

  @override
  String kcalLeft(int n) {
    return '還剩 $n';
  }

  @override
  String kcalOver(int n) {
    return '超過 $n';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n 已消耗';
  }

  @override
  String get bodyWeight => '體重';

  @override
  String get notLoggedToday => '今天尚未記錄';

  @override
  String get logWeight => '記錄體重';

  @override
  String get weightInvalid => '請輸入有效的體重。';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg  ·  今天已記錄';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg  ·  記錄於 $date';
  }

  @override
  String get healthSync => '健康資料同步';

  @override
  String get healthConnectApple => '連結 Apple 健康，即可匯入消耗的卡路里並同步你的營養資料。';

  @override
  String get healthConnectGoogle =>
      '連結 Google Health Connect，即可匯入消耗的卡路里並同步你的營養資料。';

  @override
  String get connectHealth => '連結健康資料';

  @override
  String get healthDeniedIos => '請前往「設定」→「隱私權與安全性」→「健康」→ PlateSimple 授予存取權限。';

  @override
  String get healthDeniedAndroid => '請開啟 Health Connect 並授予 PlateSimple 權限。';

  @override
  String get statSteps => '步數';

  @override
  String get statBurned => '已消耗';

  @override
  String get syncNutrition => '將營養資料同步至健康';

  @override
  String get healthSynced => '營養資料已同步至健康！';

  @override
  String get healthWriteFailed => '無法寫入健康資料。';

  @override
  String get healthNotGranted => '尚未授予健康資料存取權限，請檢查權限設定。';

  @override
  String get activity => '運動';

  @override
  String get noActivityToday => '今天沒有運動紀錄。';

  @override
  String get addActivity => '新增運動';

  @override
  String get logActivityTitle => '記錄運動';

  @override
  String get presets => '預設項目';

  @override
  String get manual => '手動';

  @override
  String get activityNameLabel => '運動名稱';

  @override
  String get activityNameHint => '例如：足球、跳舞…';

  @override
  String get caloriesBurnedLabel => '消耗的卡路里';

  @override
  String get durationLabel => '時間長度';

  @override
  String estimatedBurned(int n) {
    return '預估：約消耗 $n kcal';
  }

  @override
  String get enterValidDuration => '請輸入有效的時間長度。';

  @override
  String get enterCaloriesBurned => '請輸入消耗的卡路里。';

  @override
  String get selectActivityFirst => '請先選擇一項運動。';

  @override
  String get customActivity => '自訂運動';

  @override
  String get actWalking => '步行';

  @override
  String get actRunning => '跑步';

  @override
  String get actCycling => '騎腳踏車';

  @override
  String get actSwimming => '游泳';

  @override
  String get actWeightTraining => '重量訓練';

  @override
  String get actYoga => '瑜伽';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => '健行';

  @override
  String get mealBreakfast => '早餐';

  @override
  String get mealLunch => '午餐';

  @override
  String get mealDinner => '晚餐';

  @override
  String get mealSnack => '點心';

  @override
  String get deleteEntryTitle => '刪除這筆紀錄？';

  @override
  String deleteEntryBody(String name, String meal) {
    return '要將「$name」從$meal中移除嗎？';
  }

  @override
  String get tapToEdit => '點一下編輯';

  @override
  String get servingSizeLabel => '份量';

  @override
  String get addFoodTitle => '新增食物';

  @override
  String get pickIngredientTitle => '選擇食材';

  @override
  String get tabSearch => '搜尋';

  @override
  String get tabRecentFav => '最近與我的最愛';

  @override
  String get tabRecipes => '食譜';

  @override
  String get tabMyFoods => '我的食物';

  @override
  String get searchHint => '搜尋食物…';

  @override
  String get scanTooltip => '掃描條碼';

  @override
  String get createCustomFood => '建立自訂食物';

  @override
  String get sectionFavourites => '我的最愛 ⭐';

  @override
  String get sectionRecent => '最近';

  @override
  String get noFoodsYet => '還沒有任何食物。';

  @override
  String get unlockScannerTitle => '解鎖條碼掃描';

  @override
  String get unlockScannerBody => '觀看一則短廣告，即可解鎖條碼掃描功能直到今天結束。';

  @override
  String get watchAd => '觀看廣告';

  @override
  String get adUnavailable => '目前沒有可用的廣告，請稍後再試。';

  @override
  String get productNotFound => '資料庫中找不到此商品。';

  @override
  String get createNewRecipe => '建立新食譜';

  @override
  String get noRecipesYet => '還沒有任何食譜。\n點一下「建立新食譜」即可開始。';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 份',
    );
    return '$kcal kcal/份  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '每份 $kcal kcal';
  }

  @override
  String get servingsToLog => '要記錄的份數';

  @override
  String get createRecipeTitle => '建立食譜';

  @override
  String get editRecipeTitle => '編輯食譜';

  @override
  String get recipeNameLabel => '食譜名稱';

  @override
  String get recipeNameRequired => '請輸入食譜名稱。';

  @override
  String get recipeDescLabel => '說明（選填）';

  @override
  String get servingsLabel => '份數';

  @override
  String get ingredients => '食材';

  @override
  String get addAtLeastOne => '請至少新增一項食材。';

  @override
  String get noIngredientsYet => '還沒有任何食材。';

  @override
  String get nutritionSummary => '營養摘要';

  @override
  String get total => '總計';

  @override
  String get perServing => '每份';

  @override
  String perServingCount(int count) {
    return '每份（共 $count 份）';
  }

  @override
  String get createCustomFoodTitle => '建立自訂食物';

  @override
  String get foodDetailsSection => '食物資訊';

  @override
  String get valuesPer100 => '數值以每 100 g / 100 ml 計算。';

  @override
  String get foodNameLabel => '食物名稱';

  @override
  String get brandOptional => '品牌（選填）';

  @override
  String get nutritionPer100 => '每 100 g 營養成分';

  @override
  String get fieldRequired => '必填';

  @override
  String get enterValidNumber => '請輸入有效的數字';

  @override
  String get saveAndLog => '儲存並記錄此份量';

  @override
  String get removeFavourite => '從我的最愛移除';

  @override
  String get addToFavourites => '加入我的最愛';

  @override
  String get servingSizeG => '份量 (g)';

  @override
  String get unitGram => '公克';

  @override
  String get unitTablespoon => '湯匙';

  @override
  String get unitTeaspoon => '茶匙';

  @override
  String get unitCup => '杯';

  @override
  String get unitPiece => '個';

  @override
  String approxGrams(int grams) {
    return '≈ $grams g';
  }

  @override
  String get addToLabel => '加入至';

  @override
  String addToMeal(String meal) {
    return '加入$meal';
  }

  @override
  String get scanBarcodeTitle => '掃描條碼';

  @override
  String get historyTitle => '紀錄';

  @override
  String get noLoggedDays => '還沒有任何紀錄的日子。';

  @override
  String get noEntriesThatDay => '這一天沒有記錄任何食物。';

  @override
  String get today => '今天';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個項目',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => '每週分析';

  @override
  String get premiumFeature => 'Premium 功能';

  @override
  String get upgradeToPremium => '升級至 Premium';

  @override
  String get sevenDayAverage => '7 天平均';

  @override
  String kcalAvg(int n) {
    return '平均 $n kcal';
  }

  @override
  String get kcalAvgEmpty => '平均 — kcal';

  @override
  String get weightTrend => '體重趨勢';

  @override
  String get prevMonth => '上個月';

  @override
  String get nextMonth => '下個月';

  @override
  String get shareDayTitle => '分享你的一天';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => '達成目標！';

  @override
  String ofGoal(int n) {
    return '目標 $n';
  }

  @override
  String get trackedWith => '使用 PlateSimple 記錄';

  @override
  String get preparing => '準備中…';

  @override
  String get share => '分享';

  @override
  String shareText(String url) {
    return '我今天的飲食紀錄，使用 PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle => '每週分析 · 體重趨勢 · 健康資料同步 · 無廣告';

  @override
  String get featInsightsTitle => '7 天每週分析';

  @override
  String get featInsightsSub => '卡路里走勢圖與 7 天平均，一眼就看懂。';

  @override
  String get featAdFreeTitle => '無廣告體驗';

  @override
  String get featAdFreeSub => '沒有插頁廣告，也沒有獎勵廣告。一律沒有。';

  @override
  String get featSupportTitle => '支持獨立開發者';

  @override
  String get featSupportSub => 'PlateSimple 由一個人開發與維護，你的訂閱讓它得以持續下去。';

  @override
  String get loadPricingError => '無法載入價格。\n請檢查網路連線後再試一次。';

  @override
  String get choosePlan => '選擇方案';

  @override
  String get alreadyPremium => '你已經是 Premium 會員 ✓';

  @override
  String get subscribe => '訂閱';

  @override
  String get restorePurchases => '還原購買項目';

  @override
  String get privacyPolicy => '隱私權政策';

  @override
  String get termsOfUse => '使用條款';

  @override
  String get subsRenew => '訂閱會自動續訂，你可以隨時在裝置設定中取消。';

  @override
  String get premiumRestored => 'Premium 已成功還原！';

  @override
  String get noSubFound => '找不到有效的訂閱。';

  @override
  String get paymentPending => '付款處理中。付款完成後，Premium 會自動解鎖。';

  @override
  String get planYearly => '年繳';

  @override
  String get planMonthly => '月繳';

  @override
  String get bestValue => '最划算';

  @override
  String get billedYearly => '每年收費一次';

  @override
  String get billedMonthly => '每月收費';

  @override
  String get freeTrial => '免費試用';

  @override
  String get legendUnder => '不足';

  @override
  String get legendOnTarget => '達標';

  @override
  String get legendOver => '超過';

  @override
  String get notifTitle => '該記錄餐點囉 🥗';

  @override
  String get notifBody => '保持連續記錄，記下今天吃了什麼吧！';

  @override
  String get notifChannelName => '每日提醒';

  @override
  String get notifChannelDesc => '每天提醒你記錄餐點';

  @override
  String get servingOne => '1 份';

  @override
  String servingMany(String count) {
    return '$count 份';
  }

  @override
  String get gramsPerServingLabel => '份量 (g)';

  @override
  String get gramsPerServingHint => '選填。可讓數量以份數顯示，例如 100 g（2 份）。';

  @override
  String get unlockWithAdToday => '觀看廣告，今天即可使用';

  @override
  String get unlockedForToday => '今天已解鎖';

  @override
  String get unlockAdUnavailable => '目前沒有可用的影片，請稍後再試。';

  @override
  String get retry => '重試';

  @override
  String get sectionYourFoods => '你的食物';

  @override
  String get sectionOpenFoodFacts => 'Open Food Facts';

  @override
  String get searchCachedLabel => '已儲存的結果';

  @override
  String get searchOfflineCached => '離線 · 已儲存的結果';

  @override
  String get searchTypeMore => '輸入時同步搜尋 Open Food Facts…';

  @override
  String get searchEmptyPrompt => '搜尋 Open Food Facts 或掃描條碼。\n你記錄過的食物會顯示在這裡。';

  @override
  String noMatchFor(String query) {
    return '找不到「$query」的相符結果';
  }

  @override
  String get noMatchHint => '自己新增吧，只要幾秒鐘，而且之後都能重複使用。';

  @override
  String get addAsCustomFood => '新增為自訂食物';

  @override
  String get quickAddCalories => '快速新增卡路里';

  @override
  String get quickAddTitle => '快速新增';

  @override
  String get quickAddNameLabel => '名稱（選填）';

  @override
  String get optionalMacros => '營養素（選填）';

  @override
  String get weightUnitTitle => '體重單位';

  @override
  String get weightUnitSub => '用於記錄與趨勢圖。';

  @override
  String get goalsWeightSubtitle => '在這裡或「今天」記錄體重。趨勢圖在「紀錄」中。';

  @override
  String weightTrendDays(int n) {
    return '$n 天';
  }

  @override
  String weightTrendChange(String delta, int days) {
    return '$days 天內 $delta';
  }

  @override
  String get weightTrendNoChange => '過幾天再記錄一次，就能看到變化。';

  @override
  String get weightTrendNeedMore => '再多記錄幾次體重，趨勢就會顯示在這裡。';

  @override
  String get weightTrendTeaserSub => '30 天與 90 天圖表，搭配 7 天平均，抹平每日的起伏。';

  @override
  String get weightTrendLoggedLegend => '已記錄';

  @override
  String get weightTrendAverageLegend => '7 天平均';

  @override
  String get healthSyncSettingApple => '與 Apple 健康同步';

  @override
  String get healthSyncSettingGoogle => '與 Health Connect 同步';

  @override
  String get healthSyncSettingSubtitle => '讓你的健康 App 與這裡的紀錄保持一致。';

  @override
  String get healthSyncExplainApple =>
      '開啟後，PlateSimple 會將你記錄的卡路里、營養素與體重寫入 Apple 健康，並從中讀取你的步數、活動消耗的卡路里與體重。你可以在「健康」的授權畫面中自行決定允許哪些項目。資料不會傳送到其他地方。';

  @override
  String get healthSyncExplainGoogle =>
      '開啟後，PlateSimple 會將你記錄的卡路里、營養素與體重寫入 Health Connect，並從中讀取你的活動消耗卡路里與體重。你可以在 Health Connect 的授權畫面中自行決定允許哪些項目。資料不會傳送到其他地方。';

  @override
  String get healthSyncPremiumOnly => '健康資料同步為 Premium 功能。';

  @override
  String get healthSyncTeaserSub =>
      '將你的紀錄傳送到 Apple 健康或 Health Connect，並匯入步數與體重。';

  @override
  String get statWeight => '體重';

  @override
  String get healthWeightImported => '已將健康中的體重加入你的紀錄。';

  @override
  String healthAddWeightToLog(String weight) {
    return '將 $weight 加入紀錄';
  }

  @override
  String get featWeightTrendTitle => '體重趨勢';

  @override
  String get featWeightTrendSub => '30 天與 90 天圖表，搭配 7 天平均，並顯示期間內的變化。';

  @override
  String get featHealthSyncTitle => '健康資料同步';

  @override
  String get featHealthSyncSub =>
      '記錄的卡路里與體重會傳送到 Apple 健康或 Health Connect，步數與體重則會匯入回來。';

  @override
  String get privacyOptions => '隱私權選項';

  @override
  String get privacyOptionsSubtitle => '變更你對個人化廣告的同意設定';

  @override
  String get appearanceTitle => '外觀';

  @override
  String get appearanceSubtitle => '跟隨手機設定，或自行選擇外觀。';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get goalReachedToast => '今天剛好達標，做得好！';

  @override
  String get waterGoalToast => '已達成飲水目標，乾杯！';

  @override
  String foodLoggedToast(String food, String meal) {
    return '已將 $food 加入$meal';
  }

  @override
  String get greetingMorning => '早安';

  @override
  String get greetingAfternoon => '午安';

  @override
  String get greetingEvening => '晚上好';

  @override
  String get searchStartTitle => '今天盤子裡有什麼？';

  @override
  String get mealEmptyHint => '還沒有內容';

  @override
  String get scanHint => '將條碼對準框內';

  @override
  String get torchTooltip => '手電筒';

  @override
  String get waterAddGlass => '加一杯';

  @override
  String get waterRemoveGlass => '減一杯';

  @override
  String get premiumTag => 'Premium';

  @override
  String get adNotReadyTitle => '目前沒有影片';

  @override
  String get adNotReadyPremiumHint => '升級 Premium 即可永久解鎖，而且沒有廣告。';

  @override
  String get shareFailed => '目前無法分享，請再試一次。';

  @override
  String get reminderPermissionDenied => 'PlateSimple 的通知已關閉。請在設定中開啟，才能收到提醒。';

  @override
  String get privacyPolicySubtitle => 'PlateSimple 如何處理你的資料';
}
