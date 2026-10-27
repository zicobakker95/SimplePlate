// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get delete => 'Usuń';

  @override
  String get update => 'Aktualizuj';

  @override
  String get reset => 'Resetuj';

  @override
  String get remove => 'Usuń';

  @override
  String get edit => 'Edytuj';

  @override
  String get add => 'Dodaj';

  @override
  String get logAction => 'Dodaj';

  @override
  String get getStarted => 'Zaczynamy';

  @override
  String get continueLabel => 'Dalej';

  @override
  String get letsGo => 'Zaczynajmy!';

  @override
  String get skipForNow => 'Pomiń na razie';

  @override
  String get openSettings => 'Otwórz Ustawienia';

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get navToday => 'Dziś';

  @override
  String get navHistory => 'Historia';

  @override
  String get navGoals => 'Cele';

  @override
  String get macroCalories => 'Kalorie';

  @override
  String get macroProtein => 'Białko';

  @override
  String get macroCarbs => 'Węglow.';

  @override
  String get macroFat => 'Tłuszcz';

  @override
  String get fieldCalories => 'Kalorie';

  @override
  String get fieldProtein => 'Białko';

  @override
  String get fieldCarbohydrates => 'Węglowodany';

  @override
  String get fieldFat => 'Tłuszcz';

  @override
  String get fieldDailyCalories => 'Dzienne kalorie';

  @override
  String get fieldProteinPct => 'Białko %';

  @override
  String get fieldCarbsPct => 'Węglowodany %';

  @override
  String get fieldFatPct => 'Tłuszcz %';

  @override
  String get calculatedCalories => 'Obliczone kalorie';

  @override
  String get goalModeManual => 'Ręcznie';

  @override
  String get goalModePercent => '% → Makro';

  @override
  String get goalModeMacros => 'Makro → kcal';

  @override
  String get goalModeManualDesc =>
      'Wpisz bezpośrednio kalorie i gramy makroskładników.';

  @override
  String get goalModePercentDesc =>
      'Wpisz łączną liczbę kalorii i podział w % — gramy są liczone na bieżąco.';

  @override
  String get goalModeMacrosDesc =>
      'Wpisz gramy makroskładników — łączna liczba kalorii jest liczona na bieżąco.';

  @override
  String get pctTotalOk => 'Suma procentów wynosi 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return 'Suma procentów wynosi $sum% (powinno być 100%)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g białka';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g węglowodanów';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g tłuszczu';
  }

  @override
  String get welcomeTitle => 'Witaj w PlateSimple';

  @override
  String get welcomeSubtitle =>
      'Szybkie, przejrzyste liczenie kalorii.\nBezpłatne skanowanie kodów kreskowych. Bez bałaganu.';

  @override
  String get onbSetGoalsTitle => 'Ustaw dzienne cele';

  @override
  String get onbSetGoalsSubtitle =>
      'Możesz je zmienić w każdej chwili w Celach.';

  @override
  String get onbStayOnTrackTitle => 'Trzymaj kurs';

  @override
  String get onbStayOnTrackBody =>
      'Zezwól na powiadomienia, abyśmy mogli przypominać o zapisywaniu posiłków i podtrzymywaniu serii.';

  @override
  String get goalsDailyTargets => 'Dzienne cele żywieniowe';

  @override
  String get goalsChooseHow => 'Wybierz, jak chcesz ustawić cele.';

  @override
  String get goalsCalcTdee => 'Oblicz z TDEE / BMI';

  @override
  String get goalsSaveBtn => 'Zapisz cele';

  @override
  String get goalsSavedSnack => 'Cele zapisane!';

  @override
  String get waterTrackingTitle => 'Śledzenie wody';

  @override
  String get waterTrackingSubtitle =>
      'Śledź dzienne spożycie wody na ekranie głównym.';

  @override
  String get waterShowTracker => 'Pokaż licznik wody';

  @override
  String get waterShowTrackerSub => 'Wyświetla kartę wody na ekranie Dziś';

  @override
  String get waterDailyGoal => 'Dzienny cel';

  @override
  String get waterGlassesUnit => 'szklanek';

  @override
  String get water => 'Woda';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal szklanek';
  }

  @override
  String get resetWaterTitle => 'Zresetować wodę?';

  @override
  String get resetWaterBody => 'Ustawić dzisiejszą ilość wody z powrotem na 0?';

  @override
  String get reminderTitle => 'Codzienne przypomnienie';

  @override
  String get reminderSubtitle =>
      'Codzienne przypomnienie o zapisaniu posiłków.';

  @override
  String get reminderEnable => 'Włącz przypomnienie';

  @override
  String get reminderEnableSub => 'Wysyła codzienne powiadomienie';

  @override
  String get reminderTimeLabel => 'Godzina przypomnienia';

  @override
  String get feedbackTitle => 'Opinia';

  @override
  String get feedbackBody =>
      'PlateSimple tworzy jedna osoba, a Twoja opinia pomaga ulepszać aplikację. To zajmie mniej niż minutę!';

  @override
  String get feedbackShare => 'Podziel się opinią';

  @override
  String get rateApp => 'Oceń PlateSimple';

  @override
  String get rateAppSub => 'Recenzja pomaga innym znaleźć PlateSimple';

  @override
  String get dataExportTitle => 'Eksport danych';

  @override
  String get dataExportSubtitle =>
      'Wyeksportuj dziennik żywieniowy, wagę i aktywność.';

  @override
  String get exportCsv => 'Eksportuj jako CSV';

  @override
  String get exportCsvSub => 'Format zgodny z arkuszami kalkulacyjnymi';

  @override
  String get exportJson => 'Eksportuj jako JSON';

  @override
  String get exportJsonSub => 'Pełna kopia zapasowa danych';

  @override
  String get aboutTitle => 'O PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => 'Przejdź na Premium';

  @override
  String get premiumBannerMemberTitle => 'Masz Premium';

  @override
  String get premiumBannerUpgradeSub =>
      'Tygodniowe podsumowania · Trend wagi · Synchronizacja zdrowia · Bez reklam';

  @override
  String get premiumBannerMemberSub =>
      'Tygodniowe podsumowania · Trend wagi · Synchronizacja zdrowia · Bez reklam';

  @override
  String get tdeeTitle => 'Kalkulator TDEE';

  @override
  String get tdeeSubtitle =>
      'Wpisz swoje dane, aby obliczyć całkowity dzienny wydatek energetyczny (TDEE) i automatycznie ustawić cel kalorii.';

  @override
  String get sexMale => 'Mężczyzna';

  @override
  String get sexFemale => 'Kobieta';

  @override
  String get fieldAge => 'Wiek';

  @override
  String get fieldHeight => 'Wzrost';

  @override
  String get fieldWeight => 'Waga';

  @override
  String get unitYears => 'lat';

  @override
  String get activityLevelLabel => 'Poziom aktywności';

  @override
  String get goalLabel => 'Cel';

  @override
  String get calculate => 'Oblicz';

  @override
  String get tdeeInvalid => 'Wpisz poprawne wartości we wszystkich polach.';

  @override
  String get yourResults => 'Twoje wyniki';

  @override
  String get bmrLabel => 'BMR (podstawowa przemiana materii)';

  @override
  String get tdeeMaintenance => 'TDEE (utrzymanie wagi)';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get suggestedGoals => 'Sugerowane cele';

  @override
  String get applyGoals => 'Zastosuj te cele';

  @override
  String get tdeeAppliedSnack => 'Cele zaktualizowane z kalkulatora TDEE!';

  @override
  String get activitySedentary => 'Siedzący tryb życia (mało lub brak ćwiczeń)';

  @override
  String get activityLight => 'Niska aktywność (1–3 dni w tygodniu)';

  @override
  String get activityModerate => 'Umiarkowana aktywność (3–5 dni w tygodniu)';

  @override
  String get activityVery => 'Wysoka aktywność (6–7 dni w tygodniu)';

  @override
  String get activityExtra =>
      'Bardzo wysoka aktywność (praca fizyczna + treningi)';

  @override
  String get goalLose => 'Schudnąć';

  @override
  String get goalMaintain => 'Utrzymać wagę';

  @override
  String get goalGain => 'Przybrać na wadze';

  @override
  String get bmiUnderweight => 'Niedowaga';

  @override
  String get bmiNormal => 'Prawidłowa waga';

  @override
  String get bmiOverweight => 'Nadwaga';

  @override
  String get bmiObese => 'Otyłość';

  @override
  String get todayShareTooltip => 'Udostępnij swój dzień';

  @override
  String get todayCopyTooltip => 'Skopiuj wczorajsze posiłki';

  @override
  String get logFood => 'Dodaj jedzenie';

  @override
  String get emptyTodayTitle => 'Dziś jeszcze nic nie zapisano';

  @override
  String get emptyTodayBody =>
      'Zapisz pierwszy posiłek, aby zacząć śledzić kalorie i makroskładniki.';

  @override
  String get copyYesterdayTitle => 'Skopiować wczoraj?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skopiować $count pozycji z wczoraj na dziś?',
      many: 'Skopiować $count pozycji z wczoraj na dziś?',
      few: 'Skopiować $count pozycje z wczoraj na dziś?',
      one: 'Skopiować 1 pozycję z wczoraj na dziś?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'Wczoraj nie zapisano żadnych wpisów.';

  @override
  String get copyAction => 'Skopiuj';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skopiowano $count pozycji z wczoraj.',
      many: 'Skopiowano $count pozycji z wczoraj.',
      few: 'Skopiowano $count pozycje z wczoraj.',
      one: 'Skopiowano 1 pozycję z wczoraj.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal zjedzone';

  @override
  String get netKcal => 'kcal netto';

  @override
  String kcalLeft(int n) {
    return 'zostało $n';
  }

  @override
  String kcalOver(int n) {
    return '$n ponad cel';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n spalone';
  }

  @override
  String get bodyWeight => 'Masa ciała';

  @override
  String get notLoggedToday => 'Nie zapisano dziś';

  @override
  String get logWeight => 'Zapisz wagę';

  @override
  String get weightInvalid => 'Wpisz poprawną wagę.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg  ·  zapisano dziś';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg  ·  zapisano $date';
  }

  @override
  String get healthSync => 'Synchronizacja zdrowia';

  @override
  String get healthConnectApple =>
      'Połącz z Apple Health, aby importować spalone kalorie i synchronizować dane o odżywianiu.';

  @override
  String get healthConnectGoogle =>
      'Połącz z Google Health Connect, aby importować spalone kalorie i synchronizować dane o odżywianiu.';

  @override
  String get connectHealth => 'Połącz Health';

  @override
  String get healthDeniedIos =>
      'Otwórz Ustawienia → Prywatność i bezpieczeństwo → Zdrowie → PlateSimple, aby przyznać dostęp.';

  @override
  String get healthDeniedAndroid =>
      'Otwórz Health Connect i przyznaj uprawnienia aplikacji PlateSimple.';

  @override
  String get statSteps => 'Kroki';

  @override
  String get statBurned => 'Spalone';

  @override
  String get syncNutrition => 'Wyślij dane o odżywianiu do Health';

  @override
  String get healthSynced => 'Dane o odżywianiu zsynchronizowane!';

  @override
  String get healthWriteFailed => 'Nie udało się zapisać w Health.';

  @override
  String get healthNotGranted => 'Brak dostępu do Health. Sprawdź uprawnienia.';

  @override
  String get activity => 'Aktywność';

  @override
  String get noActivityToday => 'Brak aktywności zapisanej na dziś.';

  @override
  String get addActivity => 'Dodaj aktywność';

  @override
  String get logActivityTitle => 'Zapisz aktywność';

  @override
  String get presets => 'Gotowe';

  @override
  String get manual => 'Ręcznie';

  @override
  String get activityNameLabel => 'Nazwa aktywności';

  @override
  String get activityNameHint => 'np. piłka nożna, taniec…';

  @override
  String get caloriesBurnedLabel => 'Spalone kalorie';

  @override
  String get durationLabel => 'Czas trwania';

  @override
  String estimatedBurned(int n) {
    return 'Szacunkowo: ok. $n kcal spalonych';
  }

  @override
  String get enterValidDuration => 'Wpisz poprawny czas trwania.';

  @override
  String get enterCaloriesBurned => 'Wpisz spalone kalorie.';

  @override
  String get selectActivityFirst => 'Najpierw wybierz aktywność.';

  @override
  String get customActivity => 'Własna aktywność';

  @override
  String get actWalking => 'Spacer';

  @override
  String get actRunning => 'Bieganie';

  @override
  String get actCycling => 'Jazda na rowerze';

  @override
  String get actSwimming => 'Pływanie';

  @override
  String get actWeightTraining => 'Trening siłowy';

  @override
  String get actYoga => 'Joga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Wędrówka';

  @override
  String get mealBreakfast => 'Śniadanie';

  @override
  String get mealLunch => 'Obiad';

  @override
  String get mealDinner => 'Kolacja';

  @override
  String get mealSnack => 'Przekąska';

  @override
  String get deleteEntryTitle => 'Usunąć wpis?';

  @override
  String deleteEntryBody(String name, String meal) {
    return 'Usunąć \"$name\" z: $meal?';
  }

  @override
  String get tapToEdit => 'dotknij, aby edytować';

  @override
  String get servingSizeLabel => 'Wielkość porcji';

  @override
  String get addFoodTitle => 'Dodaj jedzenie';

  @override
  String get pickIngredientTitle => 'Wybierz składnik';

  @override
  String get tabSearch => 'Szukaj';

  @override
  String get tabRecentFav => 'Ostatnie i ulubione';

  @override
  String get tabRecipes => 'Przepisy';

  @override
  String get tabMyFoods => 'Moje produkty';

  @override
  String get searchHint => 'Szukaj produktów…';

  @override
  String get scanTooltip => 'Skanuj kod kreskowy';

  @override
  String get createCustomFood => 'Utwórz własny produkt';

  @override
  String get sectionFavourites => 'Ulubione ⭐';

  @override
  String get sectionRecent => 'Ostatnie';

  @override
  String get noFoodsYet => 'Brak produktów.';

  @override
  String get unlockScannerTitle => 'Odblokuj skaner kodów kreskowych';

  @override
  String get unlockScannerBody =>
      'Obejrzyj krótką reklamę, aby odblokować skaner kodów kreskowych do końca dnia.';

  @override
  String get watchAd => 'Obejrzyj reklamę';

  @override
  String get adUnavailable =>
      'Reklama jest teraz niedostępna. Spróbuj za chwilę.';

  @override
  String get productNotFound => 'Nie znaleziono produktu w bazie danych.';

  @override
  String get createNewRecipe => 'Utwórz nowy przepis';

  @override
  String get noRecipesYet =>
      'Brak przepisów.\nDotknij „Utwórz nowy przepis”, aby zacząć.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porcji',
      many: '$count porcji',
      few: '$count porcje',
      one: '1 porcja',
    );
    return '$kcal kcal/porcja  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '$kcal kcal na porcję';
  }

  @override
  String get servingsToLog => 'Liczba porcji do zapisania';

  @override
  String get createRecipeTitle => 'Utwórz przepis';

  @override
  String get editRecipeTitle => 'Edytuj przepis';

  @override
  String get recipeNameLabel => 'Nazwa przepisu';

  @override
  String get recipeNameRequired => 'Nazwa przepisu jest wymagana.';

  @override
  String get recipeDescLabel => 'Opis (opcjonalnie)';

  @override
  String get servingsLabel => 'Porcje';

  @override
  String get ingredients => 'Składniki';

  @override
  String get addAtLeastOne => 'Dodaj co najmniej jeden składnik.';

  @override
  String get noIngredientsYet => 'Brak składników.';

  @override
  String get nutritionSummary => 'Podsumowanie wartości odżywczych';

  @override
  String get total => 'Razem';

  @override
  String get perServing => 'Na porcję';

  @override
  String perServingCount(int count) {
    return 'Na porcję (liczba porcji: $count)';
  }

  @override
  String get createCustomFoodTitle => 'Utwórz własny produkt';

  @override
  String get foodDetailsSection => 'Dane produktu';

  @override
  String get valuesPer100 => 'Wartości na 100 g / 100 ml.';

  @override
  String get foodNameLabel => 'Nazwa produktu';

  @override
  String get brandOptional => 'Marka (opcjonalnie)';

  @override
  String get nutritionPer100 => 'Wartości odżywcze na 100 g';

  @override
  String get fieldRequired => 'Wymagane';

  @override
  String get enterValidNumber => 'Wpisz poprawną liczbę';

  @override
  String get saveAndLog => 'Zapisz i dodaj porcję';

  @override
  String get removeFavourite => 'Usuń z ulubionych';

  @override
  String get addToFavourites => 'Dodaj do ulubionych';

  @override
  String get servingSizeG => 'Wielkość porcji (g)';

  @override
  String get unitGram => 'Gram';

  @override
  String get unitTablespoon => 'Łyżka';

  @override
  String get unitTeaspoon => 'Łyżeczka';

  @override
  String get unitCup => 'Szklanka';

  @override
  String get unitPiece => 'Sztuka';

  @override
  String approxGrams(int grams) {
    return '≈ $grams g';
  }

  @override
  String get addToLabel => 'Dodaj do';

  @override
  String addToMeal(String meal) {
    return 'Dodaj do: $meal';
  }

  @override
  String get scanBarcodeTitle => 'Skanuj kod kreskowy';

  @override
  String get historyTitle => 'Historia';

  @override
  String get noLoggedDays => 'Brak zapisanych dni.';

  @override
  String get noEntriesThatDay => 'Brak produktów zapisanych tego dnia.';

  @override
  String get today => 'Dziś';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozycji',
      many: '$count pozycji',
      few: '$count pozycje',
      one: '1 pozycja',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => 'Tygodniowe podsumowania';

  @override
  String get premiumFeature => 'Funkcja Premium';

  @override
  String get upgradeToPremium => 'Przejdź na Premium';

  @override
  String get sevenDayAverage => 'Średnia z 7 dni';

  @override
  String kcalAvg(int n) {
    return 'średnio $n kcal';
  }

  @override
  String get kcalAvgEmpty => 'średnio — kcal';

  @override
  String get weightTrend => 'Trend wagi';

  @override
  String get prevMonth => 'Poprzedni miesiąc';

  @override
  String get nextMonth => 'Następny miesiąc';

  @override
  String get shareDayTitle => 'Udostępnij swój dzień';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni',
      many: '$count dni',
      few: '$count dni',
      one: '1 dzień',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => 'Cel osiągnięty!';

  @override
  String ofGoal(int n) {
    return 'z celu: $n';
  }

  @override
  String get trackedWith => 'śledzone w PlateSimple';

  @override
  String get preparing => 'Przygotowywanie…';

  @override
  String get share => 'Udostępnij';

  @override
  String shareText(String url) {
    return 'Moje dzisiejsze odżywianie — śledzone w PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle =>
      'Tygodniowe podsumowania · Trend wagi · Synchronizacja zdrowia · Bez reklam';

  @override
  String get featInsightsTitle => 'Tygodniowe podsumowania (7 dni)';

  @override
  String get featInsightsSub =>
      'Zobacz wykres kalorii i średnią z 7 dni na pierwszy rzut oka.';

  @override
  String get featAdFreeTitle => 'Bez reklam';

  @override
  String get featAdFreeSub =>
      'Bez reklam pełnoekranowych i nagradzanych. Nigdy.';

  @override
  String get featSupportTitle => 'Wesprzyj niezależnego twórcę';

  @override
  String get featSupportSub =>
      'PlateSimple tworzy i rozwija jedna osoba. Twoja subskrypcja pozwala to kontynuować.';

  @override
  String get loadPricingError =>
      'Nie udało się wczytać cen.\nSprawdź połączenie i spróbuj ponownie.';

  @override
  String get choosePlan => 'Wybierz plan';

  @override
  String get alreadyPremium => 'Masz już Premium ✓';

  @override
  String get subscribe => 'Subskrybuj';

  @override
  String get restorePurchases => 'Przywróć zakupy';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get termsOfUse => 'Warunki korzystania';

  @override
  String get subsRenew =>
      'Subskrypcje odnawiają się automatycznie. Możesz anulować w dowolnym momencie w ustawieniach urządzenia.';

  @override
  String get premiumRestored => 'Premium zostało przywrócone!';

  @override
  String get noSubFound => 'Nie znaleziono aktywnej subskrypcji.';

  @override
  String get paymentPending =>
      'Płatność oczekuje na realizację. Premium odblokuje się automatycznie po jej opłaceniu.';

  @override
  String get planYearly => 'Rocznie';

  @override
  String get planMonthly => 'Miesięcznie';

  @override
  String get bestValue => 'NAJLEPSZA CENA';

  @override
  String get billedYearly => 'Płatność raz w roku';

  @override
  String get billedMonthly => 'Płatność co miesiąc';

  @override
  String get freeTrial => 'Bezpłatny okres próbny';

  @override
  String get legendUnder => 'Poniżej';

  @override
  String get legendOnTarget => 'W celu';

  @override
  String get legendOver => 'Powyżej';

  @override
  String get notifTitle => 'Czas zapisać posiłki 🥗';

  @override
  String get notifBody => 'Podtrzymaj serię — dodaj dzisiejsze posiłki!';

  @override
  String get notifChannelName => 'Codzienne przypomnienia';

  @override
  String get notifChannelDesc => 'Przypomina o codziennym zapisywaniu posiłków';

  @override
  String get servingOne => '1 porcja';

  @override
  String servingMany(String count) {
    return 'Porcje: $count';
  }

  @override
  String get gramsPerServingLabel => 'Wielkość porcji (g)';

  @override
  String get gramsPerServingHint =>
      'Opcjonalnie. Pozwala pokazywać ilości jako porcje, np. 100 g (2 porcje).';

  @override
  String get unlockWithAdToday => 'Obejrzyj reklamę, aby zobaczyć dziś';

  @override
  String get unlockedForToday => 'Odblokowano na dziś';

  @override
  String get unlockAdUnavailable => 'Brak dostępnego wideo. Spróbuj za chwilę.';

  @override
  String get retry => 'Ponów';

  @override
  String get sectionYourFoods => 'Twoje produkty';

  @override
  String get sectionOpenFoodFacts => 'Open Food Facts';

  @override
  String get searchCachedLabel => 'Zapisane wyniki';

  @override
  String get searchOfflineCached => 'Offline · zapisane wyniki';

  @override
  String get searchTypeMore =>
      'Wyszukiwanie w Open Food Facts w trakcie pisania…';

  @override
  String get searchEmptyPrompt =>
      'Szukaj w Open Food Facts lub zeskanuj kod kreskowy.\nTutaj pojawią się zapisane produkty.';

  @override
  String noMatchFor(String query) {
    return 'Brak wyników dla „$query”';
  }

  @override
  String get noMatchHint =>
      'Dodaj produkt ręcznie — to kilka sekund, a potem możesz go używać ponownie.';

  @override
  String get addAsCustomFood => 'Dodaj jako własny produkt';

  @override
  String get quickAddCalories => 'Szybko dodaj kalorie';

  @override
  String get quickAddTitle => 'Szybkie dodawanie';

  @override
  String get quickAddNameLabel => 'Nazwa (opcjonalnie)';

  @override
  String get optionalMacros => 'Makroskładniki (opcjonalnie)';

  @override
  String get weightUnitTitle => 'Jednostka wagi';

  @override
  String get weightUnitSub => 'Do zapisów i wykresu trendu.';

  @override
  String get goalsWeightSubtitle =>
      'Zapisz pomiar wagi tutaj lub na ekranie Dziś. Wykres trendu znajdziesz w Historii.';

  @override
  String weightTrendDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dni',
      many: '$n dni',
      few: '$n dni',
      one: '1 dzień',
    );
    return '$_temp0';
  }

  @override
  String weightTrendChange(String delta, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dni',
      many: '$days dni',
      few: '$days dni',
      one: '1 dnia',
    );
    return '$delta w ciągu $_temp0';
  }

  @override
  String get weightTrendNoChange =>
      'Zapisz wagę ponownie za kilka dni, aby zobaczyć zmianę.';

  @override
  String get weightTrendNeedMore =>
      'Zapisz wagę jeszcze kilka razy, a trend pojawi się tutaj.';

  @override
  String get weightTrendTeaserSub =>
      'Wykres z 30 i 90 dni oraz średnia z 7 dni, która wygładza dzienne wahania.';

  @override
  String get weightTrendLoggedLegend => 'Zapisane';

  @override
  String get weightTrendAverageLegend => 'Średnia z 7 dni';

  @override
  String get healthSyncSettingApple => 'Synchronizuj z Apple Health';

  @override
  String get healthSyncSettingGoogle => 'Synchronizuj z Health Connect';

  @override
  String get healthSyncSettingSubtitle =>
      'Synchronizuj aplikację zdrowotną z tym, co tu zapisujesz.';

  @override
  String get healthSyncExplainApple =>
      'Po włączeniu PlateSimple zapisuje w Apple Health kalorie, makroskładniki i wagę, które dodajesz, oraz odczytuje z niego kroki, aktywne kalorie i wagę. W oknie Health dokładnie wybierasz, na co zezwalasz. Nic nie jest wysyłane nigdzie indziej.';

  @override
  String get healthSyncExplainGoogle =>
      'Po włączeniu PlateSimple zapisuje w Health Connect kalorie, makroskładniki i wagę, które dodajesz, oraz odczytuje z niego aktywne kalorie i wagę. W oknie Health Connect dokładnie wybierasz, na co zezwalasz. Nic nie jest wysyłane nigdzie indziej.';

  @override
  String get healthSyncPremiumOnly =>
      'Synchronizacja zdrowia jest częścią Premium.';

  @override
  String get healthSyncTeaserSub =>
      'Wysyłaj zapisane dane do Apple Health lub Health Connect i pobieraj z nich kroki oraz wagę.';

  @override
  String get statWeight => 'Waga';

  @override
  String get healthWeightImported => 'Waga z Health dodana do dziennika.';

  @override
  String healthAddWeightToLog(String weight) {
    return 'Dodaj $weight do dziennika';
  }

  @override
  String get featWeightTrendTitle => 'Trend wagi';

  @override
  String get featWeightTrendSub =>
      'Wykres z 30 i 90 dni, średnia z 7 dni i zmiana w danym okresie.';

  @override
  String get featHealthSyncTitle => 'Synchronizacja zdrowia';

  @override
  String get featHealthSyncSub =>
      'Zapisane kalorie i waga trafiają do Apple Health lub Health Connect; kroki i waga wracają do aplikacji.';

  @override
  String get privacyOptions => 'Opcje prywatności';

  @override
  String get privacyOptionsSubtitle =>
      'Zmień zgodę na spersonalizowane reklamy';

  @override
  String get appearanceTitle => 'Wygląd';

  @override
  String get appearanceSubtitle =>
      'Zgodnie z ustawieniem telefonu lub wybierz motyw.';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get goalReachedToast => 'Dziś dokładnie w celu. Świetnie!';

  @override
  String get waterGoalToast => 'Cel wody osiągnięty. Na zdrowie!';

  @override
  String foodLoggedToast(String food, String meal) {
    return 'Dodano: $food · $meal';
  }

  @override
  String get greetingMorning => 'Dzień dobry';

  @override
  String get greetingAfternoon => 'Miłego popołudnia';

  @override
  String get greetingEvening => 'Dobry wieczór';

  @override
  String get searchStartTitle => 'Co masz na talerzu?';

  @override
  String get mealEmptyHint => 'Jeszcze nic';

  @override
  String get scanHint => 'Ustaw kod kreskowy w ramce';

  @override
  String get torchTooltip => 'Latarka';

  @override
  String get waterAddGlass => 'Dodaj szklankę';

  @override
  String get waterRemoveGlass => 'Usuń szklankę';

  @override
  String get premiumTag => 'Premium';

  @override
  String get adNotReadyTitle => 'Brak wideo';

  @override
  String get adNotReadyPremiumHint =>
      'Premium odblokowuje to na stałe, bez reklam.';

  @override
  String get shareFailed => 'Nie udało się teraz udostępnić. Spróbuj ponownie.';

  @override
  String get reminderPermissionDenied =>
      'Powiadomienia dla PlateSimple są wyłączone. Włącz je w Ustawieniach, aby otrzymywać przypomnienia.';

  @override
  String get privacyPolicySubtitle => 'Jak PlateSimple traktuje Twoje dane';
}
