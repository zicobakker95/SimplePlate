// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get remove => 'Entfernen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get logAction => 'Erfassen';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get letsGo => 'Los geht\'s!';

  @override
  String get skipForNow => 'Vorerst überspringen';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get navToday => 'Heute';

  @override
  String get navHistory => 'Verlauf';

  @override
  String get navGoals => 'Ziele';

  @override
  String get macroCalories => 'Kalorien';

  @override
  String get macroProtein => 'Eiweiß';

  @override
  String get macroCarbs => 'Kohlenh.';

  @override
  String get macroFat => 'Fett';

  @override
  String get fieldCalories => 'Kalorien';

  @override
  String get fieldProtein => 'Eiweiß';

  @override
  String get fieldCarbohydrates => 'Kohlenhydrate';

  @override
  String get fieldFat => 'Fett';

  @override
  String get fieldDailyCalories => 'Tägliche Kalorien';

  @override
  String get fieldProteinPct => 'Eiweiß %';

  @override
  String get fieldCarbsPct => 'Kohlenhydrate %';

  @override
  String get fieldFatPct => 'Fett %';

  @override
  String get calculatedCalories => 'Berechnete Kalorien';

  @override
  String get goalModeManual => 'Manuell';

  @override
  String get goalModePercent => '% → Makros';

  @override
  String get goalModeMacros => 'Makros → kcal';

  @override
  String get goalModeManualDesc =>
      'Gib deine Kalorien und Makro-Gramm direkt ein.';

  @override
  String get goalModePercentDesc =>
      'Gib die Gesamtkalorien und die %-Aufteilung ein — Gramm werden live berechnet.';

  @override
  String get goalModeMacrosDesc =>
      'Gib deine Makro-Gramm ein — Gesamtkalorien werden live berechnet.';

  @override
  String get pctTotalOk => 'Prozente ergeben 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return 'Prozente ergeben $sum% (sollten 100% sein)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g Eiweiß';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g Kohlenhydrate';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g Fett';
  }

  @override
  String get welcomeTitle => 'Willkommen bei PlateSimple';

  @override
  String get welcomeSubtitle =>
      'Schnelles, klares Kalorienzählen.\nKostenloses Barcode-Scannen. Kein Ballast.';

  @override
  String get onbSetGoalsTitle => 'Lege deine Tagesziele fest';

  @override
  String get onbSetGoalsSubtitle =>
      'Du kannst sie jederzeit unter Ziele ändern.';

  @override
  String get onbStayOnTrackTitle => 'Bleib am Ball';

  @override
  String get onbStayOnTrackBody =>
      'Erlaube Benachrichtigungen, damit wir dich ans Erfassen erinnern und deine Serie am Leben halten können.';

  @override
  String get goalsDailyTargets => 'Tägliche Nährwertziele';

  @override
  String get goalsChooseHow => 'Wähle, wie du deine Ziele festlegen möchtest.';

  @override
  String get goalsCalcTdee => 'Mit TDEE / BMI berechnen';

  @override
  String get goalsSaveBtn => 'Ziele speichern';

  @override
  String get goalsSavedSnack => 'Ziele gespeichert!';

  @override
  String get waterTrackingTitle => 'Wasser-Tracking';

  @override
  String get waterTrackingSubtitle =>
      'Verfolge deine tägliche Wasseraufnahme auf dem Startbildschirm.';

  @override
  String get waterShowTracker => 'Wasser-Tracker anzeigen';

  @override
  String get waterShowTrackerSub => 'Zeigt die Wasserkarte im Heute-Bildschirm';

  @override
  String get waterDailyGoal => 'Tagesziel';

  @override
  String get waterGlassesUnit => 'Gläser';

  @override
  String get water => 'Wasser';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal Gläser';
  }

  @override
  String get resetWaterTitle => 'Wasser zurücksetzen?';

  @override
  String get resetWaterBody => 'Den heutigen Wasserstand auf 0 zurücksetzen?';

  @override
  String get reminderTitle => 'Tägliche Erinnerung';

  @override
  String get reminderSubtitle =>
      'Erhalte täglich einen Anstoß, deine Mahlzeiten zu erfassen.';

  @override
  String get reminderEnable => 'Erinnerung aktivieren';

  @override
  String get reminderEnableSub => 'Sendet eine tägliche Benachrichtigung';

  @override
  String get reminderTimeLabel => 'Erinnerungszeit';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackBody =>
      'Ich bin Einzelentwickler und dein Feedback hilft, PlateSimple besser zu machen. Dauert weniger als eine Minute!';

  @override
  String get feedbackShare => 'Feedback teilen';

  @override
  String get dataExportTitle => 'Datenexport';

  @override
  String get dataExportSubtitle =>
      'Exportiere dein Ernährungsprotokoll, Gewicht und deine Aktivitäten.';

  @override
  String get exportCsv => 'Als CSV exportieren';

  @override
  String get exportCsvSub => 'Tabellenkalkulations-kompatibel';

  @override
  String get exportJson => 'Als JSON exportieren';

  @override
  String get exportJsonSub => 'Vollständige Sicherung';

  @override
  String get aboutTitle => 'Über PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => 'Auf Premium upgraden';

  @override
  String get premiumBannerMemberTitle => 'Du bist Premium-Mitglied';

  @override
  String get premiumBannerUpgradeSub =>
      'Wöchentliche Einblicke · Keine Werbung · Dev unterstützen';

  @override
  String get premiumBannerMemberSub =>
      'Wöchentliche Einblicke freigeschaltet · Keine Werbung';

  @override
  String get tdeeTitle => 'TDEE-Rechner';

  @override
  String get tdeeSubtitle =>
      'Gib deine Daten ein, um deinen Gesamtumsatz zu berechnen und dein Kalorienziel automatisch festzulegen.';

  @override
  String get sexMale => 'Männlich';

  @override
  String get sexFemale => 'Weiblich';

  @override
  String get fieldAge => 'Alter';

  @override
  String get fieldHeight => 'Größe';

  @override
  String get fieldWeight => 'Gewicht';

  @override
  String get unitYears => 'Jahre';

  @override
  String get activityLevelLabel => 'Aktivitätsniveau';

  @override
  String get goalLabel => 'Ziel';

  @override
  String get calculate => 'Berechnen';

  @override
  String get tdeeInvalid => 'Bitte gib für alle Felder gültige Werte ein.';

  @override
  String get yourResults => 'Deine Ergebnisse';

  @override
  String get bmrLabel => 'Grundumsatz (BMR)';

  @override
  String get tdeeMaintenance => 'TDEE (Erhaltung)';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get suggestedGoals => 'Vorgeschlagene Ziele';

  @override
  String get applyGoals => 'Diese Ziele übernehmen';

  @override
  String get tdeeAppliedSnack => 'Ziele über den TDEE-Rechner aktualisiert!';

  @override
  String get activitySedentary => 'Sitzend (wenig oder keine Bewegung)';

  @override
  String get activityLight => 'Leicht aktiv (1–3 Tage/Woche)';

  @override
  String get activityModerate => 'Mäßig aktiv (3–5 Tage/Woche)';

  @override
  String get activityVery => 'Sehr aktiv (6–7 Tage/Woche)';

  @override
  String get activityExtra => 'Extrem aktiv (körperliche Arbeit + Training)';

  @override
  String get goalLose => 'Abnehmen';

  @override
  String get goalMaintain => 'Gewicht halten';

  @override
  String get goalGain => 'Zunehmen';

  @override
  String get bmiUnderweight => 'Untergewicht';

  @override
  String get bmiNormal => 'Normalgewicht';

  @override
  String get bmiOverweight => 'Übergewicht';

  @override
  String get bmiObese => 'Adipositas';

  @override
  String get todayShareTooltip => 'Teile deinen Tag';

  @override
  String get todayCopyTooltip => 'Gestrige Mahlzeiten kopieren';

  @override
  String get logFood => 'Essen erfassen';

  @override
  String get emptyTodayTitle => 'Heute noch nichts erfasst';

  @override
  String get emptyTodayBody =>
      'Erfasse deine erste Mahlzeit, um Kalorien und Makros zu verfolgen.';

  @override
  String get copyYesterdayTitle => 'Gestern kopieren?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge von gestern auf heute kopieren?',
      one: '1 Eintrag von gestern auf heute kopieren?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'Gestern nichts erfasst.';

  @override
  String get copyAction => 'Kopieren';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge von gestern kopiert.',
      one: '1 Eintrag von gestern kopiert.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal gegessen';

  @override
  String get netKcal => 'netto kcal';

  @override
  String kcalLeft(int n) {
    return '$n übrig';
  }

  @override
  String kcalOver(int n) {
    return '$n drüber';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n verbrannt';
  }

  @override
  String get bodyWeight => 'Körpergewicht';

  @override
  String get notLoggedToday => 'Heute nicht erfasst';

  @override
  String get logWeight => 'Gewicht erfassen';

  @override
  String get weightInvalid => 'Gib ein gültiges Gewicht ein.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg kg  ·  heute erfasst';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg kg  ·  erfasst am $date';
  }

  @override
  String get healthSync => 'Health-Sync';

  @override
  String get healthConnectApple =>
      'Verbinde Apple Health, um verbrannte Kalorien zu importieren und deine Ernährung zu synchronisieren.';

  @override
  String get healthConnectGoogle =>
      'Verbinde Google Health Connect, um verbrannte Kalorien zu importieren und deine Ernährung zu synchronisieren.';

  @override
  String get connectHealth => 'Health verbinden';

  @override
  String get healthDeniedIos =>
      'Öffne Einstellungen → Datenschutz & Sicherheit → Health → PlateSimple, um Zugriff zu gewähren.';

  @override
  String get healthDeniedAndroid =>
      'Öffne Health Connect und gewähre PlateSimple die Berechtigungen.';

  @override
  String get statSteps => 'Schritte';

  @override
  String get statBurned => 'Verbrannt';

  @override
  String get syncNutrition => 'Ernährung mit Health synchronisieren';

  @override
  String get healthSynced => 'Ernährung mit Health synchronisiert!';

  @override
  String get healthWriteFailed => 'Konnte nicht in Health schreiben.';

  @override
  String get healthNotGranted =>
      'Kein Health-Zugriff gewährt. Berechtigungen prüfen.';

  @override
  String get activity => 'Aktivität';

  @override
  String get noActivityToday => 'Heute keine Aktivität erfasst.';

  @override
  String get addActivity => 'Aktivität hinzufügen';

  @override
  String get logActivityTitle => 'Aktivität erfassen';

  @override
  String get presets => 'Vorlagen';

  @override
  String get manual => 'Manuell';

  @override
  String get activityNameLabel => 'Name der Aktivität';

  @override
  String get activityNameHint => 'z. B. Fußball, Tanzen…';

  @override
  String get caloriesBurnedLabel => 'Verbrannte Kalorien';

  @override
  String get durationLabel => 'Dauer';

  @override
  String estimatedBurned(int n) {
    return 'Geschätzt: ~$n kcal verbrannt';
  }

  @override
  String get enterValidDuration => 'Gib eine gültige Dauer ein.';

  @override
  String get enterCaloriesBurned => 'Gib die verbrannten Kalorien ein.';

  @override
  String get selectActivityFirst => 'Wähle zuerst eine Aktivität.';

  @override
  String get customActivity => 'Eigene Aktivität';

  @override
  String get actWalking => 'Gehen';

  @override
  String get actRunning => 'Laufen';

  @override
  String get actCycling => 'Radfahren';

  @override
  String get actSwimming => 'Schwimmen';

  @override
  String get actWeightTraining => 'Krafttraining';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Wandern';

  @override
  String get mealBreakfast => 'Frühstück';

  @override
  String get mealLunch => 'Mittagessen';

  @override
  String get mealDinner => 'Abendessen';

  @override
  String get mealSnack => 'Snack';

  @override
  String get deleteEntryTitle => 'Eintrag löschen?';

  @override
  String deleteEntryBody(String name, String meal) {
    return '\"$name\" aus $meal entfernen?';
  }

  @override
  String get holdToEdit => 'halten zum Bearbeiten';

  @override
  String get servingSizeLabel => 'Portionsgröße';

  @override
  String get addFoodTitle => 'Essen hinzufügen';

  @override
  String get pickIngredientTitle => 'Zutat wählen';

  @override
  String get tabSearch => 'Suche';

  @override
  String get tabRecentFav => 'Zuletzt & Favoriten';

  @override
  String get tabRecipes => 'Rezepte';

  @override
  String get tabMyFoods => 'Meine Lebensmittel';

  @override
  String get searchHint => 'Lebensmittel suchen…';

  @override
  String get scanTooltip => 'Barcode scannen';

  @override
  String noResults(String query) {
    return 'Keine Ergebnisse für \"$query\".\nVersuche einen genaueren Begriff oder scanne den Barcode.';
  }

  @override
  String searchErrorRetry(String error) {
    return '$error\nZum Wiederholen nach unten ziehen.';
  }

  @override
  String get createCustomFood => 'Eigenes Lebensmittel erstellen';

  @override
  String get sectionFavourites => 'Favoriten ⭐';

  @override
  String get sectionRecent => 'Zuletzt';

  @override
  String get noFoodsYet => 'Noch keine Lebensmittel.';

  @override
  String get unlockScannerTitle => 'Barcode-Scanner freischalten';

  @override
  String get unlockScannerBody =>
      'Sieh dir eine kurze Werbung an, um den Barcode-Scanner für den Rest des Tages freizuschalten.';

  @override
  String get watchAd => 'Werbung ansehen';

  @override
  String get adUnavailable =>
      'Werbung gerade nicht verfügbar. Versuche es gleich erneut.';

  @override
  String get productNotFound => 'Produkt nicht in der Datenbank gefunden.';

  @override
  String get createNewRecipe => 'Neues Rezept erstellen';

  @override
  String get noRecipesYet =>
      'Noch keine Rezepte.\nTippe auf \"Neues Rezept erstellen\", um zu starten.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Portionen',
      one: '1 Portion',
    );
    return '$kcal kcal/Portion  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '$kcal kcal pro Portion';
  }

  @override
  String get servingsToLog => 'Zu erfassende Portionen';

  @override
  String get createRecipeTitle => 'Rezept erstellen';

  @override
  String get editRecipeTitle => 'Rezept bearbeiten';

  @override
  String get recipeNameLabel => 'Rezeptname';

  @override
  String get recipeNameRequired => 'Rezeptname ist erforderlich.';

  @override
  String get recipeDescLabel => 'Beschreibung (optional)';

  @override
  String get servingsLabel => 'Portionen';

  @override
  String get ingredients => 'Zutaten';

  @override
  String get addAtLeastOne => 'Füge mindestens eine Zutat hinzu.';

  @override
  String get noIngredientsYet => 'Noch keine Zutaten.';

  @override
  String get nutritionSummary => 'Nährwertübersicht';

  @override
  String get total => 'Gesamt';

  @override
  String get perServing => 'Pro Portion';

  @override
  String perServingCount(int count) {
    return 'Pro Portion ($count Portionen)';
  }

  @override
  String get createCustomFoodTitle => 'Eigenes Lebensmittel erstellen';

  @override
  String get foodDetailsSection => 'Lebensmitteldetails';

  @override
  String get valuesPer100 => 'Werte sind pro 100 g / 100 ml.';

  @override
  String get foodNameLabel => 'Name des Lebensmittels';

  @override
  String get brandOptional => 'Marke (optional)';

  @override
  String get nutritionPer100 => 'Nährwerte pro 100 g';

  @override
  String get fieldRequired => 'Erforderlich';

  @override
  String get enterValidNumber => 'Gib eine gültige Zahl ein';

  @override
  String get saveAndLog => 'Speichern & Portion erfassen';

  @override
  String get removeFavourite => 'Favorit entfernen';

  @override
  String get addToFavourites => 'Zu Favoriten hinzufügen';

  @override
  String get servingSizeG => 'Portionsgröße (g)';

  @override
  String get unitGram => 'Gramm';

  @override
  String get unitTablespoon => 'Esslöffel';

  @override
  String get unitTeaspoon => 'Teelöffel';

  @override
  String get unitCup => 'Tasse';

  @override
  String get unitPiece => 'Stück';

  @override
  String approxGrams(int grams) {
    return '≈ $grams g';
  }

  @override
  String get addToLabel => 'Hinzufügen zu';

  @override
  String addToMeal(String meal) {
    return 'Zu $meal hinzufügen';
  }

  @override
  String get scanBarcodeTitle => 'Barcode scannen';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get noLoggedDays => 'Noch keine erfassten Tage.';

  @override
  String get today => 'Heute';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => 'Wöchentliche Einblicke';

  @override
  String get premiumFeature => 'Premium-Funktion';

  @override
  String get upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get sevenDayAverage => '7-Tage-Durchschnitt';

  @override
  String kcalAvg(int n) {
    return '$n kcal Ø';
  }

  @override
  String get kcalAvgEmpty => '— kcal Ø';

  @override
  String get weightTrend => 'Gewichtstrend';

  @override
  String get prevMonth => 'Vorheriger Monat';

  @override
  String get nextMonth => 'Nächster Monat';

  @override
  String get shareDayTitle => 'Teile deinen Tag';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => 'Ziel erreicht!';

  @override
  String ofGoal(int n) {
    return 'von $n Ziel';
  }

  @override
  String get trackedWith => 'erfasst mit PlateSimple';

  @override
  String get preparing => 'Wird vorbereitet…';

  @override
  String get share => 'Teilen';

  @override
  String shareText(String url) {
    return 'Meine Ernährung heute — erfasst mit PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle => 'Schalte das volle Erlebnis frei';

  @override
  String get featInsightsTitle => 'Wöchentliche Einblicke (7 Tage)';

  @override
  String get featInsightsSub =>
      'Sieh deine Kalorien-Sparkline und den 7-Tage-Durchschnitt auf einen Blick.';

  @override
  String get featAdFreeTitle => 'Werbefrei';

  @override
  String get featAdFreeSub =>
      'Keine Interstitial- oder Rewarded-Werbung. Niemals.';

  @override
  String get featSupportTitle => 'Unterstütze einen Einzelentwickler';

  @override
  String get featSupportSub =>
      'PlateSimple wird von einer Person entwickelt und gepflegt. Dein Abo hält es am Laufen.';

  @override
  String get loadPricingError =>
      'Preise konnten nicht geladen werden.\nPrüfe deine Verbindung und versuche es erneut.';

  @override
  String get choosePlan => 'Wähle einen Tarif';

  @override
  String get alreadyPremium => 'Du bist bereits Premium ✓';

  @override
  String get subscribe => 'Abonnieren';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get privacyPolicy => 'Datenschutz';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get subsRenew =>
      'Abos verlängern sich automatisch. Jederzeit in den Geräteeinstellungen kündbar.';

  @override
  String get premiumRestored => 'Premium erfolgreich wiederhergestellt!';

  @override
  String get noSubFound => 'Kein aktives Abo gefunden.';

  @override
  String get planYearly => 'Jährlich';

  @override
  String get planMonthly => 'Monatlich';

  @override
  String get bestValue => 'BESTER WERT';

  @override
  String get billedYearly => 'Einmal pro Jahr abgerechnet';

  @override
  String get billedMonthly => 'Monatlich abgerechnet';

  @override
  String get freeTrial => 'Kostenlose Testphase';

  @override
  String get legendUnder => 'Unter';

  @override
  String get legendOnTarget => 'Im Ziel';

  @override
  String get legendOver => 'Über';

  @override
  String get notifTitle => 'Zeit, deine Mahlzeiten zu erfassen 🥗';

  @override
  String get notifBody =>
      'Halte deine Serie am Laufen — erfasse, was du heute gegessen hast!';

  @override
  String get notifChannelName => 'Tägliche Erinnerungen';

  @override
  String get notifChannelDesc =>
      'Erinnert dich täglich daran, deine Mahlzeiten zu erfassen';
}
