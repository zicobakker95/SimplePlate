// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Opslaan';

  @override
  String get delete => 'Verwijderen';

  @override
  String get update => 'Bijwerken';

  @override
  String get reset => 'Resetten';

  @override
  String get remove => 'Verwijderen';

  @override
  String get edit => 'Bewerken';

  @override
  String get add => 'Toevoegen';

  @override
  String get logAction => 'Loggen';

  @override
  String get getStarted => 'Aan de slag';

  @override
  String get continueLabel => 'Doorgaan';

  @override
  String get letsGo => 'Aan de slag!';

  @override
  String get skipForNow => 'Nu overslaan';

  @override
  String get openSettings => 'Instellingen openen';

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String get navToday => 'Vandaag';

  @override
  String get navHistory => 'Geschiedenis';

  @override
  String get navGoals => 'Doelen';

  @override
  String get macroCalories => 'Calorieën';

  @override
  String get macroProtein => 'Eiwit';

  @override
  String get macroCarbs => 'Koolh.';

  @override
  String get macroFat => 'Vet';

  @override
  String get fieldCalories => 'Calorieën';

  @override
  String get fieldProtein => 'Eiwit';

  @override
  String get fieldCarbohydrates => 'Koolhydraten';

  @override
  String get fieldFat => 'Vet';

  @override
  String get fieldDailyCalories => 'Dagelijkse calorieën';

  @override
  String get fieldProteinPct => 'Eiwit %';

  @override
  String get fieldCarbsPct => 'Koolhydraten %';

  @override
  String get fieldFatPct => 'Vet %';

  @override
  String get calculatedCalories => 'Berekende calorieën';

  @override
  String get goalModeManual => 'Handmatig';

  @override
  String get goalModePercent => '% → Macro\'s';

  @override
  String get goalModeMacros => 'Macro\'s → kcal';

  @override
  String get goalModeManualDesc =>
      'Voer je calorieën en macrogrammen direct in.';

  @override
  String get goalModePercentDesc =>
      'Voer totale calorieën en de %-verdeling in — grammen worden live berekend.';

  @override
  String get goalModeMacrosDesc =>
      'Voer je macrogrammen in — totale calorieën worden live berekend.';

  @override
  String get pctTotalOk => 'Percentages tellen op tot 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return 'Percentages tellen op tot $sum% (moet 100% zijn)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g eiwit';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g koolhydraten';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g vet';
  }

  @override
  String get welcomeTitle => 'Welkom bij PlateSimple';

  @override
  String get welcomeSubtitle =>
      'Snel, overzichtelijk calorieën tellen.\nGratis barcodes scannen. Geen rommel.';

  @override
  String get onbSetGoalsTitle => 'Stel je dagelijkse doelen in';

  @override
  String get onbSetGoalsSubtitle => 'Je kunt deze altijd wijzigen bij Doelen.';

  @override
  String get onbStayOnTrackTitle => 'Blijf op koers';

  @override
  String get onbStayOnTrackBody =>
      'Sta meldingen toe zodat we je kunnen herinneren om maaltijden te loggen en je reeks levend te houden.';

  @override
  String get goalsDailyTargets => 'Dagelijkse voedingsdoelen';

  @override
  String get goalsChooseHow => 'Kies hoe je je doelen wilt instellen.';

  @override
  String get goalsCalcTdee => 'Bereken met TDEE / BMI';

  @override
  String get goalsSaveBtn => 'Doelen opslaan';

  @override
  String get goalsSavedSnack => 'Doelen opgeslagen!';

  @override
  String get waterTrackingTitle => 'Waterregistratie';

  @override
  String get waterTrackingSubtitle =>
      'Houd je dagelijkse waterinname bij op het beginscherm.';

  @override
  String get waterShowTracker => 'Watertracker tonen';

  @override
  String get waterShowTrackerSub => 'Toont de waterkaart op het Vandaag-scherm';

  @override
  String get waterDailyGoal => 'Dagdoel';

  @override
  String get waterGlassesUnit => 'glazen';

  @override
  String get water => 'Water';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal glazen';
  }

  @override
  String get resetWaterTitle => 'Water resetten?';

  @override
  String get resetWaterBody => 'De waterstand van vandaag terugzetten naar 0?';

  @override
  String get reminderTitle => 'Dagelijkse herinnering';

  @override
  String get reminderSubtitle =>
      'Krijg een dagelijks zetje om je maaltijden te loggen.';

  @override
  String get reminderEnable => 'Herinnering inschakelen';

  @override
  String get reminderEnableSub => 'Stuurt een dagelijkse melding';

  @override
  String get reminderTimeLabel => 'Herinneringstijd';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackBody =>
      'Ik ben een soloontwikkelaar en jouw feedback helpt PlateSimple beter te maken. Kost minder dan een minuut!';

  @override
  String get feedbackShare => 'Feedback delen';

  @override
  String get dataExportTitle => 'Gegevens exporteren';

  @override
  String get dataExportSubtitle =>
      'Exporteer je voedingslog, gewicht en activiteiten.';

  @override
  String get exportCsv => 'Exporteren als CSV';

  @override
  String get exportCsvSub => 'Compatibel met spreadsheets';

  @override
  String get exportJson => 'Exporteren als JSON';

  @override
  String get exportJsonSub => 'Volledige back-up';

  @override
  String get aboutTitle => 'Over PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => 'Upgraden naar Premium';

  @override
  String get premiumBannerMemberTitle => 'Je bent een Premium-lid';

  @override
  String get premiumBannerUpgradeSub =>
      'Wekelijkse inzichten · Geen advertenties · Steun de dev';

  @override
  String get premiumBannerMemberSub =>
      'Wekelijkse inzichten ontgrendeld · Geen advertenties';

  @override
  String get tdeeTitle => 'TDEE-calculator';

  @override
  String get tdeeSubtitle =>
      'Voer je gegevens in om je totale dagelijkse energieverbruik te berekenen en je caloriedoel automatisch in te stellen.';

  @override
  String get sexMale => 'Man';

  @override
  String get sexFemale => 'Vrouw';

  @override
  String get fieldAge => 'Leeftijd';

  @override
  String get fieldHeight => 'Lengte';

  @override
  String get fieldWeight => 'Gewicht';

  @override
  String get unitYears => 'jaar';

  @override
  String get activityLevelLabel => 'Activiteitsniveau';

  @override
  String get goalLabel => 'Doel';

  @override
  String get calculate => 'Berekenen';

  @override
  String get tdeeInvalid => 'Voer geldige waarden in voor alle velden.';

  @override
  String get yourResults => 'Je resultaten';

  @override
  String get bmrLabel => 'BMR (basaal metabolisme)';

  @override
  String get tdeeMaintenance => 'TDEE (onderhoud)';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get suggestedGoals => 'Voorgestelde doelen';

  @override
  String get applyGoals => 'Deze doelen toepassen';

  @override
  String get tdeeAppliedSnack => 'Doelen bijgewerkt via de TDEE-calculator!';

  @override
  String get activitySedentary => 'Zittend (weinig of geen beweging)';

  @override
  String get activityLight => 'Licht actief (1–3 dagen/week)';

  @override
  String get activityModerate => 'Matig actief (3–5 dagen/week)';

  @override
  String get activityVery => 'Zeer actief (6–7 dagen/week)';

  @override
  String get activityExtra => 'Extra actief (fysiek werk + training)';

  @override
  String get goalLose => 'Afvallen';

  @override
  String get goalMaintain => 'Gewicht behouden';

  @override
  String get goalGain => 'Aankomen';

  @override
  String get bmiUnderweight => 'Ondergewicht';

  @override
  String get bmiNormal => 'Normaal gewicht';

  @override
  String get bmiOverweight => 'Overgewicht';

  @override
  String get bmiObese => 'Obesitas';

  @override
  String get todayShareTooltip => 'Deel je dag';

  @override
  String get todayCopyTooltip => 'Maaltijden van gisteren kopiëren';

  @override
  String get logFood => 'Eten loggen';

  @override
  String get emptyTodayTitle => 'Nog niets gelogd vandaag';

  @override
  String get emptyTodayBody =>
      'Log je eerste maaltijd om calorieën en macro\'s bij te houden.';

  @override
  String get copyYesterdayTitle => 'Gisteren kopiëren?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items van gisteren naar vandaag kopiëren?',
      one: '1 item van gisteren naar vandaag kopiëren?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'Gisteren niets gelogd.';

  @override
  String get copyAction => 'Kopiëren';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items van gisteren gekopieerd.',
      one: '1 item van gisteren gekopieerd.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal gegeten';

  @override
  String get netKcal => 'netto kcal';

  @override
  String kcalLeft(int n) {
    return '$n over';
  }

  @override
  String kcalOver(int n) {
    return '$n te veel';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n verbrand';
  }

  @override
  String get bodyWeight => 'Lichaamsgewicht';

  @override
  String get notLoggedToday => 'Vandaag niet gelogd';

  @override
  String get logWeight => 'Gewicht loggen';

  @override
  String get weightInvalid => 'Voer een geldig gewicht in.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg kg  ·  gelogd vandaag';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg kg  ·  gelogd $date';
  }

  @override
  String get healthSync => 'Health-synchronisatie';

  @override
  String get healthConnectApple =>
      'Verbind Apple Health om verbrande calorieën te importeren en je voeding te synchroniseren.';

  @override
  String get healthConnectGoogle =>
      'Verbind Google Health Connect om verbrande calorieën te importeren en je voeding te synchroniseren.';

  @override
  String get connectHealth => 'Health verbinden';

  @override
  String get healthDeniedIos =>
      'Ga naar Instellingen → Privacy en beveiliging → Gezondheid → PlateSimple om toegang te verlenen.';

  @override
  String get healthDeniedAndroid =>
      'Open Health Connect en verleen PlateSimple toestemming.';

  @override
  String get statSteps => 'Stappen';

  @override
  String get statBurned => 'Verbrand';

  @override
  String get syncNutrition => 'Voeding synchroniseren met Health';

  @override
  String get healthSynced => 'Voeding gesynchroniseerd met Health!';

  @override
  String get healthWriteFailed => 'Kon niet naar Health schrijven.';

  @override
  String get healthNotGranted =>
      'Geen Health-toegang verleend. Controleer de rechten.';

  @override
  String get activity => 'Activiteit';

  @override
  String get noActivityToday => 'Vandaag geen activiteit gelogd.';

  @override
  String get addActivity => 'Activiteit toevoegen';

  @override
  String get logActivityTitle => 'Activiteit loggen';

  @override
  String get presets => 'Presets';

  @override
  String get manual => 'Handmatig';

  @override
  String get activityNameLabel => 'Naam activiteit';

  @override
  String get activityNameHint => 'bijv. Voetbal, Dansen…';

  @override
  String get caloriesBurnedLabel => 'Verbrande calorieën';

  @override
  String get durationLabel => 'Duur';

  @override
  String estimatedBurned(int n) {
    return 'Geschat: ~$n kcal verbrand';
  }

  @override
  String get enterValidDuration => 'Voer een geldige duur in.';

  @override
  String get enterCaloriesBurned => 'Voer verbrande calorieën in.';

  @override
  String get selectActivityFirst => 'Selecteer eerst een activiteit.';

  @override
  String get customActivity => 'Eigen activiteit';

  @override
  String get actWalking => 'Wandelen';

  @override
  String get actRunning => 'Hardlopen';

  @override
  String get actCycling => 'Fietsen';

  @override
  String get actSwimming => 'Zwemmen';

  @override
  String get actWeightTraining => 'Krachttraining';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Wandeltocht';

  @override
  String get mealBreakfast => 'Ontbijt';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Diner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get deleteEntryTitle => 'Item verwijderen?';

  @override
  String deleteEntryBody(String name, String meal) {
    return '\"$name\" verwijderen uit $meal?';
  }

  @override
  String get holdToEdit => 'houd vast om te bewerken';

  @override
  String get servingSizeLabel => 'Portiegrootte';

  @override
  String get addFoodTitle => 'Eten toevoegen';

  @override
  String get pickIngredientTitle => 'Ingrediënt kiezen';

  @override
  String get tabSearch => 'Zoeken';

  @override
  String get tabRecentFav => 'Recent & favorieten';

  @override
  String get tabRecipes => 'Recepten';

  @override
  String get tabMyFoods => 'Mijn voedsel';

  @override
  String get searchHint => 'Zoek voedsel…';

  @override
  String get scanTooltip => 'Barcode scannen';

  @override
  String noResults(String query) {
    return 'Geen resultaten voor \"$query\".\nProbeer een specifiekere term of scan de barcode.';
  }

  @override
  String searchErrorRetry(String error) {
    return '$error\nTrek omlaag om opnieuw te proberen.';
  }

  @override
  String get createCustomFood => 'Eigen voedsel maken';

  @override
  String get sectionFavourites => 'Favorieten ⭐';

  @override
  String get sectionRecent => 'Recent';

  @override
  String get noFoodsYet => 'Nog geen voedsel.';

  @override
  String get unlockScannerTitle => 'Barcodescanner ontgrendelen';

  @override
  String get unlockScannerBody =>
      'Bekijk een korte advertentie om de barcodescanner de rest van de dag te ontgrendelen.';

  @override
  String get watchAd => 'Advertentie bekijken';

  @override
  String get adUnavailable =>
      'Advertentie nu niet beschikbaar. Probeer het zo opnieuw.';

  @override
  String get productNotFound => 'Product niet gevonden in de database.';

  @override
  String get createNewRecipe => 'Nieuw recept maken';

  @override
  String get noRecipesYet =>
      'Nog geen recepten.\nTik op \"Nieuw recept maken\" om te beginnen.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porties',
      one: '1 portie',
    );
    return '$kcal kcal/portie  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '$kcal kcal per portie';
  }

  @override
  String get servingsToLog => 'Aantal porties om te loggen';

  @override
  String get createRecipeTitle => 'Recept maken';

  @override
  String get editRecipeTitle => 'Recept bewerken';

  @override
  String get recipeNameLabel => 'Receptnaam';

  @override
  String get recipeNameRequired => 'Receptnaam is verplicht.';

  @override
  String get recipeDescLabel => 'Beschrijving (optioneel)';

  @override
  String get servingsLabel => 'Porties';

  @override
  String get ingredients => 'Ingrediënten';

  @override
  String get addAtLeastOne => 'Voeg minstens één ingrediënt toe.';

  @override
  String get noIngredientsYet => 'Nog geen ingrediënten.';

  @override
  String get nutritionSummary => 'Voedingsoverzicht';

  @override
  String get total => 'Totaal';

  @override
  String get perServing => 'Per portie';

  @override
  String perServingCount(int count) {
    return 'Per portie ($count porties)';
  }

  @override
  String get createCustomFoodTitle => 'Eigen voedsel maken';

  @override
  String get foodDetailsSection => 'Voedseldetails';

  @override
  String get valuesPer100 => 'Waarden zijn per 100 g / 100 ml.';

  @override
  String get foodNameLabel => 'Naam voedsel';

  @override
  String get brandOptional => 'Merk (optioneel)';

  @override
  String get nutritionPer100 => 'Voeding per 100 g';

  @override
  String get fieldRequired => 'Verplicht';

  @override
  String get enterValidNumber => 'Voer een geldig getal in';

  @override
  String get saveAndLog => 'Opslaan & portie loggen';

  @override
  String get removeFavourite => 'Favoriet verwijderen';

  @override
  String get addToFavourites => 'Aan favorieten toevoegen';

  @override
  String get servingSizeG => 'Portiegrootte (g)';

  @override
  String get addToLabel => 'Toevoegen aan';

  @override
  String addToMeal(String meal) {
    return 'Toevoegen aan $meal';
  }

  @override
  String get scanBarcodeTitle => 'Barcode scannen';

  @override
  String get historyTitle => 'Geschiedenis';

  @override
  String get noLoggedDays => 'Nog geen gelogde dagen.';

  @override
  String get today => 'Vandaag';

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
  String get weeklyInsights => 'Wekelijkse inzichten';

  @override
  String get premiumFeature => 'Premiumfunctie';

  @override
  String get upgradeToPremium => 'Upgraden naar Premium';

  @override
  String get sevenDayAverage => 'Gemiddelde van 7 dagen';

  @override
  String kcalAvg(int n) {
    return '$n kcal gem.';
  }

  @override
  String get kcalAvgEmpty => '— kcal gem.';

  @override
  String get weightTrend => 'Gewichtstrend';

  @override
  String get prevMonth => 'Vorige maand';

  @override
  String get nextMonth => 'Volgende maand';

  @override
  String get shareDayTitle => 'Deel je dag';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => 'Doel gehaald!';

  @override
  String ofGoal(int n) {
    return 'van $n doel';
  }

  @override
  String get trackedWith => 'bijgehouden met PlateSimple';

  @override
  String get preparing => 'Voorbereiden…';

  @override
  String get share => 'Delen';

  @override
  String shareText(String url) {
    return 'Mijn voeding vandaag — bijgehouden met PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle => 'Ontgrendel de volledige ervaring';

  @override
  String get featInsightsTitle => 'Wekelijkse inzichten (7 dagen)';

  @override
  String get featInsightsSub =>
      'Zie je caloriegrafiek en 7-daags gemiddelde in één oogopslag.';

  @override
  String get featAdFreeTitle => 'Advertentievrij';

  @override
  String get featAdFreeSub =>
      'Geen interstitial- of beloningsadvertenties. Nooit.';

  @override
  String get featSupportTitle => 'Steun een soloontwikkelaar';

  @override
  String get featSupportSub =>
      'PlateSimple wordt door één persoon gebouwd en onderhouden. Jouw abonnement houdt het draaiende.';

  @override
  String get loadPricingError =>
      'Kon prijzen niet laden.\nControleer je verbinding en probeer opnieuw.';

  @override
  String get choosePlan => 'Kies een abonnement';

  @override
  String get alreadyPremium => 'Je bent al Premium ✓';

  @override
  String get subscribe => 'Abonneren';

  @override
  String get restorePurchases => 'Aankopen herstellen';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get termsOfUse => 'Gebruiksvoorwaarden';

  @override
  String get subsRenew =>
      'Abonnementen worden automatisch verlengd. Annuleer altijd via je apparaatinstellingen.';

  @override
  String get premiumRestored => 'Premium succesvol hersteld!';

  @override
  String get noSubFound => 'Geen actief abonnement gevonden.';

  @override
  String get planYearly => 'Jaarlijks';

  @override
  String get planMonthly => 'Maandelijks';

  @override
  String get bestValue => 'BESTE KEUS';

  @override
  String get billedYearly => 'Eén keer per jaar in rekening gebracht';

  @override
  String get billedMonthly => 'Maandelijks in rekening gebracht';

  @override
  String get freeTrial => 'Gratis proefperiode';

  @override
  String get legendUnder => 'Onder';

  @override
  String get legendOnTarget => 'Op doel';

  @override
  String get legendOver => 'Boven';

  @override
  String get notifTitle => 'Tijd om je maaltijden te loggen 🥗';

  @override
  String get notifBody =>
      'Houd je reeks gaande — log wat je vandaag hebt gegeten!';

  @override
  String get notifChannelName => 'Dagelijkse herinneringen';

  @override
  String get notifChannelDesc =>
      'Herinnert je er elke dag aan om je maaltijden te loggen';
}
