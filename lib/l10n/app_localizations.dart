import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('nl'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PlateSimple'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @logAction.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get logAction;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get letsGo;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @macroCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get macroCalories;

  /// No description provided for @macroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// No description provided for @macroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get macroCarbs;

  /// No description provided for @macroFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get macroFat;

  /// No description provided for @fieldCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get fieldCalories;

  /// No description provided for @fieldProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get fieldProtein;

  /// No description provided for @fieldCarbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get fieldCarbohydrates;

  /// No description provided for @fieldFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fieldFat;

  /// No description provided for @fieldDailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily calories'**
  String get fieldDailyCalories;

  /// No description provided for @fieldProteinPct.
  ///
  /// In en, this message translates to:
  /// **'Protein %'**
  String get fieldProteinPct;

  /// No description provided for @fieldCarbsPct.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates %'**
  String get fieldCarbsPct;

  /// No description provided for @fieldFatPct.
  ///
  /// In en, this message translates to:
  /// **'Fat %'**
  String get fieldFatPct;

  /// No description provided for @calculatedCalories.
  ///
  /// In en, this message translates to:
  /// **'Calculated calories'**
  String get calculatedCalories;

  /// No description provided for @goalModeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get goalModeManual;

  /// No description provided for @goalModePercent.
  ///
  /// In en, this message translates to:
  /// **'% → Macros'**
  String get goalModePercent;

  /// No description provided for @goalModeMacros.
  ///
  /// In en, this message translates to:
  /// **'Macros → kcal'**
  String get goalModeMacros;

  /// No description provided for @goalModeManualDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your calories and macro grams directly.'**
  String get goalModeManualDesc;

  /// No description provided for @goalModePercentDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter total calories and the % split — grams are calculated live.'**
  String get goalModePercentDesc;

  /// No description provided for @goalModeMacrosDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your macro grams — total calories are calculated live.'**
  String get goalModeMacrosDesc;

  /// No description provided for @pctTotalOk.
  ///
  /// In en, this message translates to:
  /// **'Percentages add up to 100% ✓'**
  String get pctTotalOk;

  /// No description provided for @pctTotalOff.
  ///
  /// In en, this message translates to:
  /// **'Percentages add up to {sum}% (should be 100%)'**
  String pctTotalOff(int sum);

  /// No description provided for @pctHintProtein.
  ///
  /// In en, this message translates to:
  /// **'  → {grams} g protein'**
  String pctHintProtein(int grams);

  /// No description provided for @pctHintCarbs.
  ///
  /// In en, this message translates to:
  /// **'  → {grams} g carbs'**
  String pctHintCarbs(int grams);

  /// No description provided for @pctHintFat.
  ///
  /// In en, this message translates to:
  /// **'  → {grams} g fat'**
  String pctHintFat(int grams);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PlateSimple'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast, clean calorie tracking.\nFree barcode scanning. No clutter.'**
  String get welcomeSubtitle;

  /// No description provided for @onbSetGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your daily goals'**
  String get onbSetGoalsTitle;

  /// No description provided for @onbSetGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change these anytime in Goals.'**
  String get onbSetGoalsSubtitle;

  /// No description provided for @onbStayOnTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on track'**
  String get onbStayOnTrackTitle;

  /// No description provided for @onbStayOnTrackBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so we can remind you to log meals and keep your streak alive.'**
  String get onbStayOnTrackBody;

  /// No description provided for @goalsDailyTargets.
  ///
  /// In en, this message translates to:
  /// **'Daily nutrition targets'**
  String get goalsDailyTargets;

  /// No description provided for @goalsChooseHow.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to set your goals.'**
  String get goalsChooseHow;

  /// No description provided for @goalsCalcTdee.
  ///
  /// In en, this message translates to:
  /// **'Calculate with TDEE / BMI'**
  String get goalsCalcTdee;

  /// No description provided for @goalsSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save goals'**
  String get goalsSaveBtn;

  /// No description provided for @goalsSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Goals saved!'**
  String get goalsSavedSnack;

  /// No description provided for @waterTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Water tracking'**
  String get waterTrackingTitle;

  /// No description provided for @waterTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your daily water intake on the home screen.'**
  String get waterTrackingSubtitle;

  /// No description provided for @waterShowTracker.
  ///
  /// In en, this message translates to:
  /// **'Show water tracker'**
  String get waterShowTracker;

  /// No description provided for @waterShowTrackerSub.
  ///
  /// In en, this message translates to:
  /// **'Displays water card on Today screen'**
  String get waterShowTrackerSub;

  /// No description provided for @waterDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get waterDailyGoal;

  /// No description provided for @waterGlassesUnit.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get waterGlassesUnit;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @waterCount.
  ///
  /// In en, this message translates to:
  /// **'{glasses} / {goal} glasses'**
  String waterCount(int glasses, int goal);

  /// No description provided for @resetWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset water?'**
  String get resetWaterTitle;

  /// No description provided for @resetWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Set today\'s water count back to 0?'**
  String get resetWaterBody;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get reminderTitle;

  /// No description provided for @reminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a daily nudge to log your meals.'**
  String get reminderSubtitle;

  /// No description provided for @reminderEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder'**
  String get reminderEnable;

  /// No description provided for @reminderEnableSub.
  ///
  /// In en, this message translates to:
  /// **'Sends a daily notification'**
  String get reminderEnableSub;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTimeLabel;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackBody.
  ///
  /// In en, this message translates to:
  /// **'I\'m a solo developer and your feedback helps make PlateSimple better. Takes less than a minute!'**
  String get feedbackBody;

  /// No description provided for @feedbackShare.
  ///
  /// In en, this message translates to:
  /// **'Share feedback'**
  String get feedbackShare;

  /// No description provided for @dataExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Data export'**
  String get dataExportTitle;

  /// No description provided for @dataExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export your food log, weight, and activity data.'**
  String get dataExportSubtitle;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportCsv;

  /// No description provided for @exportCsvSub.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet-compatible format'**
  String get exportCsvSub;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get exportJson;

  /// No description provided for @exportJsonSub.
  ///
  /// In en, this message translates to:
  /// **'Full data backup'**
  String get exportJsonSub;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About PlateSimple'**
  String get aboutTitle;

  /// No description provided for @premiumBannerUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get premiumBannerUpgradeTitle;

  /// No description provided for @premiumBannerMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re a Premium member'**
  String get premiumBannerMemberTitle;

  /// No description provided for @premiumBannerUpgradeSub.
  ///
  /// In en, this message translates to:
  /// **'Weekly insights · No ads · Support dev'**
  String get premiumBannerUpgradeSub;

  /// No description provided for @premiumBannerMemberSub.
  ///
  /// In en, this message translates to:
  /// **'Weekly insights unlocked · No ads'**
  String get premiumBannerMemberSub;

  /// No description provided for @tdeeTitle.
  ///
  /// In en, this message translates to:
  /// **'TDEE Calculator'**
  String get tdeeTitle;

  /// No description provided for @tdeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your stats to calculate Total Daily Energy Expenditure and auto-set your calorie goal.'**
  String get tdeeSubtitle;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @fieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fieldAge;

  /// No description provided for @fieldHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get fieldHeight;

  /// No description provided for @fieldWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get fieldWeight;

  /// No description provided for @unitYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get unitYears;

  /// No description provided for @activityLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activityLevelLabel;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @tdeeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid values for all fields.'**
  String get tdeeInvalid;

  /// No description provided for @yourResults.
  ///
  /// In en, this message translates to:
  /// **'Your Results'**
  String get yourResults;

  /// No description provided for @bmrLabel.
  ///
  /// In en, this message translates to:
  /// **'BMR (base metabolic rate)'**
  String get bmrLabel;

  /// No description provided for @tdeeMaintenance.
  ///
  /// In en, this message translates to:
  /// **'TDEE (maintenance)'**
  String get tdeeMaintenance;

  /// No description provided for @bmiLabel.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmiLabel;

  /// No description provided for @suggestedGoals.
  ///
  /// In en, this message translates to:
  /// **'Suggested goals'**
  String get suggestedGoals;

  /// No description provided for @applyGoals.
  ///
  /// In en, this message translates to:
  /// **'Apply these goals'**
  String get applyGoals;

  /// No description provided for @tdeeAppliedSnack.
  ///
  /// In en, this message translates to:
  /// **'Goals updated from TDEE calculator!'**
  String get tdeeAppliedSnack;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary (little or no exercise)'**
  String get activitySedentary;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Lightly active (1–3 days/week)'**
  String get activityLight;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderately active (3–5 days/week)'**
  String get activityModerate;

  /// No description provided for @activityVery.
  ///
  /// In en, this message translates to:
  /// **'Very active (6–7 days/week)'**
  String get activityVery;

  /// No description provided for @activityExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra active (physical job + training)'**
  String get activityExtra;

  /// No description provided for @goalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get goalLose;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get goalMaintain;

  /// No description provided for @goalGain.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get goalGain;

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal weight'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// No description provided for @todayShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share your day'**
  String get todayShareTooltip;

  /// No description provided for @todayCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy yesterday\'s meals'**
  String get todayCopyTooltip;

  /// No description provided for @logFood.
  ///
  /// In en, this message translates to:
  /// **'Log food'**
  String get logFood;

  /// No description provided for @emptyTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet today'**
  String get emptyTodayTitle;

  /// No description provided for @emptyTodayBody.
  ///
  /// In en, this message translates to:
  /// **'Log your first meal to start tracking calories and macros.'**
  String get emptyTodayBody;

  /// No description provided for @copyYesterdayTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy yesterday?'**
  String get copyYesterdayTitle;

  /// No description provided for @copyYesterdayBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copy 1 item from yesterday to today?} other{Copy {count} items from yesterday to today?}}'**
  String copyYesterdayBody(int count);

  /// No description provided for @copyYesterdayNone.
  ///
  /// In en, this message translates to:
  /// **'No entries logged yesterday.'**
  String get copyYesterdayNone;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @copiedSnack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copied 1 item from yesterday.} other{Copied {count} items from yesterday.}}'**
  String copiedSnack(int count);

  /// No description provided for @kcalEaten.
  ///
  /// In en, this message translates to:
  /// **'kcal eaten'**
  String get kcalEaten;

  /// No description provided for @netKcal.
  ///
  /// In en, this message translates to:
  /// **'net kcal'**
  String get netKcal;

  /// No description provided for @kcalLeft.
  ///
  /// In en, this message translates to:
  /// **'{n} left'**
  String kcalLeft(int n);

  /// No description provided for @kcalOver.
  ///
  /// In en, this message translates to:
  /// **'{n} over'**
  String kcalOver(int n);

  /// No description provided for @kcalBurnedLine.
  ///
  /// In en, this message translates to:
  /// **'−{n} burned'**
  String kcalBurnedLine(int n);

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get bodyWeight;

  /// No description provided for @notLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'Not logged today'**
  String get notLoggedToday;

  /// No description provided for @logWeight.
  ///
  /// In en, this message translates to:
  /// **'Log weight'**
  String get logWeight;

  /// No description provided for @weightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight.'**
  String get weightInvalid;

  /// No description provided for @weightSubtitleToday.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg  ·  logged today'**
  String weightSubtitleToday(String kg);

  /// No description provided for @weightSubtitleDate.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg  ·  logged {date}'**
  String weightSubtitleDate(String kg, String date);

  /// No description provided for @healthSync.
  ///
  /// In en, this message translates to:
  /// **'Health sync'**
  String get healthSync;

  /// No description provided for @healthConnectApple.
  ///
  /// In en, this message translates to:
  /// **'Connect Apple Health to import calories burned and sync your nutrition.'**
  String get healthConnectApple;

  /// No description provided for @healthConnectGoogle.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Health Connect to import calories burned and sync your nutrition.'**
  String get healthConnectGoogle;

  /// No description provided for @connectHealth.
  ///
  /// In en, this message translates to:
  /// **'Connect Health'**
  String get connectHealth;

  /// No description provided for @healthDeniedIos.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Privacy & Security → Health → PlateSimple to grant access.'**
  String get healthDeniedIos;

  /// No description provided for @healthDeniedAndroid.
  ///
  /// In en, this message translates to:
  /// **'Open Health Connect and grant PlateSimple permissions.'**
  String get healthDeniedAndroid;

  /// No description provided for @statSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get statSteps;

  /// No description provided for @statBurned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get statBurned;

  /// No description provided for @syncNutrition.
  ///
  /// In en, this message translates to:
  /// **'Sync nutrition to Health'**
  String get syncNutrition;

  /// No description provided for @healthSynced.
  ///
  /// In en, this message translates to:
  /// **'Nutrition synced to Health!'**
  String get healthSynced;

  /// No description provided for @healthWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not write to Health.'**
  String get healthWriteFailed;

  /// No description provided for @healthNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Health access not granted. Check permissions.'**
  String get healthNotGranted;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @noActivityToday.
  ///
  /// In en, this message translates to:
  /// **'No activity logged today.'**
  String get noActivityToday;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add activity'**
  String get addActivity;

  /// No description provided for @logActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Log activity'**
  String get logActivityTitle;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @activityNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity name'**
  String get activityNameLabel;

  /// No description provided for @activityNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Soccer, Dancing…'**
  String get activityNameHint;

  /// No description provided for @caloriesBurnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get caloriesBurnedLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @estimatedBurned.
  ///
  /// In en, this message translates to:
  /// **'Estimated: ~{n} kcal burned'**
  String estimatedBurned(int n);

  /// No description provided for @enterValidDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid duration.'**
  String get enterValidDuration;

  /// No description provided for @enterCaloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Enter calories burned.'**
  String get enterCaloriesBurned;

  /// No description provided for @selectActivityFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an activity first.'**
  String get selectActivityFirst;

  /// No description provided for @customActivity.
  ///
  /// In en, this message translates to:
  /// **'Custom activity'**
  String get customActivity;

  /// No description provided for @actWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get actWalking;

  /// No description provided for @actRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get actRunning;

  /// No description provided for @actCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get actCycling;

  /// No description provided for @actSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get actSwimming;

  /// No description provided for @actWeightTraining.
  ///
  /// In en, this message translates to:
  /// **'Weight training'**
  String get actWeightTraining;

  /// No description provided for @actYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get actYoga;

  /// No description provided for @actHIIT.
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get actHIIT;

  /// No description provided for @actHiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get actHiking;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealSnack;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from {meal}?'**
  String deleteEntryBody(String name, String meal);

  /// No description provided for @holdToEdit.
  ///
  /// In en, this message translates to:
  /// **'hold to edit'**
  String get holdToEdit;

  /// No description provided for @servingSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get servingSizeLabel;

  /// No description provided for @addFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get addFoodTitle;

  /// No description provided for @pickIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick ingredient'**
  String get pickIngredientTitle;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabRecentFav.
  ///
  /// In en, this message translates to:
  /// **'Recent & Favourites'**
  String get tabRecentFav;

  /// No description provided for @tabRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get tabRecipes;

  /// No description provided for @tabMyFoods.
  ///
  /// In en, this message translates to:
  /// **'My Foods'**
  String get tabMyFoods;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods…'**
  String get searchHint;

  /// No description provided for @scanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanTooltip;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\".\nTry a more specific term or scan the barcode.'**
  String noResults(String query);

  /// No description provided for @searchErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'{error}\nPull down to retry.'**
  String searchErrorRetry(String error);

  /// No description provided for @createCustomFood.
  ///
  /// In en, this message translates to:
  /// **'Create custom food'**
  String get createCustomFood;

  /// No description provided for @sectionFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites ⭐'**
  String get sectionFavourites;

  /// No description provided for @sectionRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get sectionRecent;

  /// No description provided for @noFoodsYet.
  ///
  /// In en, this message translates to:
  /// **'No foods yet.'**
  String get noFoodsYet;

  /// No description provided for @unlockScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock barcode scanner'**
  String get unlockScannerTitle;

  /// No description provided for @unlockScannerBody.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to unlock the barcode scanner for the rest of the day.'**
  String get unlockScannerBody;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get watchAd;

  /// No description provided for @adUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ad unavailable right now. Try again in a moment.'**
  String get adUnavailable;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found in database.'**
  String get productNotFound;

  /// No description provided for @createNewRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create new recipe'**
  String get createNewRecipe;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet.\nTap \"Create new recipe\" to start.'**
  String get noRecipesYet;

  /// No description provided for @recipePerServing.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal/serving  ·  {count, plural, =1{1 serving} other{{count} servings}}'**
  String recipePerServing(int kcal, int count);

  /// No description provided for @recipeKcalPerServing.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal per serving'**
  String recipeKcalPerServing(int kcal);

  /// No description provided for @servingsToLog.
  ///
  /// In en, this message translates to:
  /// **'Servings to log'**
  String get servingsToLog;

  /// No description provided for @createRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create recipe'**
  String get createRecipeTitle;

  /// No description provided for @editRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipeTitle;

  /// No description provided for @recipeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get recipeNameLabel;

  /// No description provided for @recipeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Recipe name is required.'**
  String get recipeNameRequired;

  /// No description provided for @recipeDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get recipeDescLabel;

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servingsLabel;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @addAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient.'**
  String get addAtLeastOne;

  /// No description provided for @noIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet.'**
  String get noIngredientsYet;

  /// No description provided for @nutritionSummary.
  ///
  /// In en, this message translates to:
  /// **'Nutrition summary'**
  String get nutritionSummary;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @perServing.
  ///
  /// In en, this message translates to:
  /// **'Per serving'**
  String get perServing;

  /// No description provided for @perServingCount.
  ///
  /// In en, this message translates to:
  /// **'Per serving ({count} servings)'**
  String perServingCount(int count);

  /// No description provided for @createCustomFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Create custom food'**
  String get createCustomFoodTitle;

  /// No description provided for @foodDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Food details'**
  String get foodDetailsSection;

  /// No description provided for @valuesPer100.
  ///
  /// In en, this message translates to:
  /// **'Values are per 100 g / 100 ml.'**
  String get valuesPer100;

  /// No description provided for @foodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get foodNameLabel;

  /// No description provided for @brandOptional.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get brandOptional;

  /// No description provided for @nutritionPer100.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100 g'**
  String get nutritionPer100;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @saveAndLog.
  ///
  /// In en, this message translates to:
  /// **'Save & log serving'**
  String get saveAndLog;

  /// No description provided for @removeFavourite.
  ///
  /// In en, this message translates to:
  /// **'Remove favourite'**
  String get removeFavourite;

  /// No description provided for @addToFavourites.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get addToFavourites;

  /// No description provided for @servingSizeG.
  ///
  /// In en, this message translates to:
  /// **'Serving size (g)'**
  String get servingSizeG;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get unitGram;

  /// No description provided for @unitTablespoon.
  ///
  /// In en, this message translates to:
  /// **'Tablespoon'**
  String get unitTablespoon;

  /// No description provided for @unitTeaspoon.
  ///
  /// In en, this message translates to:
  /// **'Teaspoon'**
  String get unitTeaspoon;

  /// No description provided for @unitCup.
  ///
  /// In en, this message translates to:
  /// **'Cup'**
  String get unitCup;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitPiece;

  /// No description provided for @approxGrams.
  ///
  /// In en, this message translates to:
  /// **'≈ {grams} g'**
  String approxGrams(int grams);

  /// No description provided for @addToLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to'**
  String get addToLabel;

  /// No description provided for @addToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String addToMeal(String meal);

  /// No description provided for @scanBarcodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcodeTitle;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @noLoggedDays.
  ///
  /// In en, this message translates to:
  /// **'No logged days yet.'**
  String get noLoggedDays;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @weeklyInsights.
  ///
  /// In en, this message translates to:
  /// **'Weekly Insights'**
  String get weeklyInsights;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium feature'**
  String get premiumFeature;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @sevenDayAverage.
  ///
  /// In en, this message translates to:
  /// **'7-Day Average'**
  String get sevenDayAverage;

  /// No description provided for @kcalAvg.
  ///
  /// In en, this message translates to:
  /// **'{n} kcal avg'**
  String kcalAvg(int n);

  /// No description provided for @kcalAvgEmpty.
  ///
  /// In en, this message translates to:
  /// **'— kcal avg'**
  String get kcalAvgEmpty;

  /// No description provided for @weightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight trend'**
  String get weightTrend;

  /// No description provided for @prevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get prevMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @shareDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your day'**
  String get shareDayTitle;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dayStreak(int count);

  /// No description provided for @goalHit.
  ///
  /// In en, this message translates to:
  /// **'Goal hit!'**
  String get goalHit;

  /// No description provided for @ofGoal.
  ///
  /// In en, this message translates to:
  /// **'of {n} goal'**
  String ofGoal(int n);

  /// No description provided for @trackedWith.
  ///
  /// In en, this message translates to:
  /// **'tracked with PlateSimple'**
  String get trackedWith;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get preparing;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'My nutrition today — tracked with PlateSimple 🥗\n{url}'**
  String shareText(String url);

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'PlateSimple Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full experience'**
  String get premiumSubtitle;

  /// No description provided for @featInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'7-day weekly insights'**
  String get featInsightsTitle;

  /// No description provided for @featInsightsSub.
  ///
  /// In en, this message translates to:
  /// **'See your calorie sparkline and 7-day average at a glance.'**
  String get featInsightsSub;

  /// No description provided for @featAdFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get featAdFreeTitle;

  /// No description provided for @featAdFreeSub.
  ///
  /// In en, this message translates to:
  /// **'No interstitial ads, no rewarded ads. Ever.'**
  String get featAdFreeSub;

  /// No description provided for @featSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support a solo developer'**
  String get featSupportTitle;

  /// No description provided for @featSupportSub.
  ///
  /// In en, this message translates to:
  /// **'PlateSimple is built and maintained by one person. Your subscription keeps it going.'**
  String get featSupportSub;

  /// No description provided for @loadPricingError.
  ///
  /// In en, this message translates to:
  /// **'Could not load pricing.\nCheck your connection and try again.'**
  String get loadPricingError;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get choosePlan;

  /// No description provided for @alreadyPremium.
  ///
  /// In en, this message translates to:
  /// **'You\'re already Premium ✓'**
  String get alreadyPremium;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @subsRenew.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically. Cancel anytime in your device settings.'**
  String get subsRenew;

  /// No description provided for @premiumRestored.
  ///
  /// In en, this message translates to:
  /// **'Premium restored successfully!'**
  String get premiumRestored;

  /// No description provided for @noSubFound.
  ///
  /// In en, this message translates to:
  /// **'No active subscription found.'**
  String get noSubFound;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @billedYearly.
  ///
  /// In en, this message translates to:
  /// **'Billed once per year'**
  String get billedYearly;

  /// No description provided for @billedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billedMonthly;

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get freeTrial;

  /// No description provided for @legendUnder.
  ///
  /// In en, this message translates to:
  /// **'Under'**
  String get legendUnder;

  /// No description provided for @legendOnTarget.
  ///
  /// In en, this message translates to:
  /// **'On target'**
  String get legendOnTarget;

  /// No description provided for @legendOver.
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get legendOver;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to log your meals 🥗'**
  String get notifTitle;

  /// No description provided for @notifBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak going — log what you ate today!'**
  String get notifBody;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminds you to log your meals each day'**
  String get notifChannelDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'nl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
