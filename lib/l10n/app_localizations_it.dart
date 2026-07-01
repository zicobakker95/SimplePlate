// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get update => 'Aggiorna';

  @override
  String get reset => 'Reimposta';

  @override
  String get remove => 'Rimuovi';

  @override
  String get edit => 'Modifica';

  @override
  String get add => 'Aggiungi';

  @override
  String get logAction => 'Registra';

  @override
  String get getStarted => 'Inizia';

  @override
  String get continueLabel => 'Continua';

  @override
  String get letsGo => 'Iniziamo!';

  @override
  String get skipForNow => 'Salta per ora';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get navToday => 'Oggi';

  @override
  String get navHistory => 'Cronologia';

  @override
  String get navGoals => 'Obiettivi';

  @override
  String get macroCalories => 'Calorie';

  @override
  String get macroProtein => 'Proteine';

  @override
  String get macroCarbs => 'Carb.';

  @override
  String get macroFat => 'Grassi';

  @override
  String get fieldCalories => 'Calorie';

  @override
  String get fieldProtein => 'Proteine';

  @override
  String get fieldCarbohydrates => 'Carboidrati';

  @override
  String get fieldFat => 'Grassi';

  @override
  String get fieldDailyCalories => 'Calorie giornaliere';

  @override
  String get fieldProteinPct => 'Proteine %';

  @override
  String get fieldCarbsPct => 'Carboidrati %';

  @override
  String get fieldFatPct => 'Grassi %';

  @override
  String get calculatedCalories => 'Calorie calcolate';

  @override
  String get goalModeManual => 'Manuale';

  @override
  String get goalModePercent => '% → Macro';

  @override
  String get goalModeMacros => 'Macro → kcal';

  @override
  String get goalModeManualDesc =>
      'Inserisci direttamente calorie e grammi dei macro.';

  @override
  String get goalModePercentDesc =>
      'Inserisci le calorie totali e la suddivisione in % — i grammi sono calcolati in tempo reale.';

  @override
  String get goalModeMacrosDesc =>
      'Inserisci i grammi dei macro — le calorie totali sono calcolate in tempo reale.';

  @override
  String get pctTotalOk => 'Le percentuali fanno 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return 'Le percentuali fanno $sum% (devono fare 100%)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g di proteine';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g di carboidrati';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g di grassi';
  }

  @override
  String get welcomeTitle => 'Benvenuto su PlateSimple';

  @override
  String get welcomeSubtitle =>
      'Conteggio calorie veloce e pulito.\nScansione codici a barre gratis. Senza fronzoli.';

  @override
  String get onbSetGoalsTitle => 'Imposta i tuoi obiettivi giornalieri';

  @override
  String get onbSetGoalsSubtitle =>
      'Puoi modificarli in qualsiasi momento in Obiettivi.';

  @override
  String get onbStayOnTrackTitle => 'Resta in carreggiata';

  @override
  String get onbStayOnTrackBody =>
      'Consenti le notifiche così possiamo ricordarti di registrare i pasti e mantenere viva la tua serie.';

  @override
  String get goalsDailyTargets => 'Obiettivi nutrizionali giornalieri';

  @override
  String get goalsChooseHow => 'Scegli come impostare i tuoi obiettivi.';

  @override
  String get goalsCalcTdee => 'Calcola con TDEE / BMI';

  @override
  String get goalsSaveBtn => 'Salva obiettivi';

  @override
  String get goalsSavedSnack => 'Obiettivi salvati!';

  @override
  String get waterTrackingTitle => 'Monitoraggio acqua';

  @override
  String get waterTrackingSubtitle =>
      'Monitora la tua assunzione giornaliera di acqua nella schermata Home.';

  @override
  String get waterShowTracker => 'Mostra monitoraggio acqua';

  @override
  String get waterShowTrackerSub =>
      'Mostra la scheda dell\'acqua nella schermata Oggi';

  @override
  String get waterDailyGoal => 'Obiettivo giornaliero';

  @override
  String get waterGlassesUnit => 'bicchieri';

  @override
  String get water => 'Acqua';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal bicchieri';
  }

  @override
  String get resetWaterTitle => 'Reimpostare l\'acqua?';

  @override
  String get resetWaterBody =>
      'Riportare a 0 il conteggio dell\'acqua di oggi?';

  @override
  String get reminderTitle => 'Promemoria giornaliero';

  @override
  String get reminderSubtitle =>
      'Ricevi un promemoria giornaliero per registrare i pasti.';

  @override
  String get reminderEnable => 'Attiva promemoria';

  @override
  String get reminderEnableSub => 'Invia una notifica giornaliera';

  @override
  String get reminderTimeLabel => 'Ora del promemoria';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackBody =>
      'Sono uno sviluppatore indipendente e il tuo feedback aiuta a migliorare PlateSimple. Meno di un minuto!';

  @override
  String get feedbackShare => 'Condividi feedback';

  @override
  String get dataExportTitle => 'Esporta dati';

  @override
  String get dataExportSubtitle =>
      'Esporta il tuo diario alimentare, il peso e le attività.';

  @override
  String get exportCsv => 'Esporta come CSV';

  @override
  String get exportCsvSub => 'Compatibile con i fogli di calcolo';

  @override
  String get exportJson => 'Esporta come JSON';

  @override
  String get exportJsonSub => 'Backup completo';

  @override
  String get aboutTitle => 'Informazioni su PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => 'Passa a Premium';

  @override
  String get premiumBannerMemberTitle => 'Sei un membro Premium';

  @override
  String get premiumBannerUpgradeSub =>
      'Analisi settimanali · Niente pubblicità · Sostieni il dev';

  @override
  String get premiumBannerMemberSub =>
      'Analisi settimanali sbloccate · Niente pubblicità';

  @override
  String get tdeeTitle => 'Calcolatore TDEE';

  @override
  String get tdeeSubtitle =>
      'Inserisci i tuoi dati per calcolare il dispendio energetico giornaliero totale e impostare automaticamente il tuo obiettivo calorico.';

  @override
  String get sexMale => 'Uomo';

  @override
  String get sexFemale => 'Donna';

  @override
  String get fieldAge => 'Età';

  @override
  String get fieldHeight => 'Altezza';

  @override
  String get fieldWeight => 'Peso';

  @override
  String get unitYears => 'anni';

  @override
  String get activityLevelLabel => 'Livello di attività';

  @override
  String get goalLabel => 'Obiettivo';

  @override
  String get calculate => 'Calcola';

  @override
  String get tdeeInvalid => 'Inserisci valori validi in tutti i campi.';

  @override
  String get yourResults => 'I tuoi risultati';

  @override
  String get bmrLabel => 'Metabolismo basale (BMR)';

  @override
  String get tdeeMaintenance => 'TDEE (mantenimento)';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get suggestedGoals => 'Obiettivi suggeriti';

  @override
  String get applyGoals => 'Applica questi obiettivi';

  @override
  String get tdeeAppliedSnack => 'Obiettivi aggiornati dal calcolatore TDEE!';

  @override
  String get activitySedentary => 'Sedentario (poco o nessun esercizio)';

  @override
  String get activityLight => 'Leggermente attivo (1–3 giorni/settimana)';

  @override
  String get activityModerate => 'Moderatamente attivo (3–5 giorni/settimana)';

  @override
  String get activityVery => 'Molto attivo (6–7 giorni/settimana)';

  @override
  String get activityExtra =>
      'Estremamente attivo (lavoro fisico + allenamento)';

  @override
  String get goalLose => 'Perdere peso';

  @override
  String get goalMaintain => 'Mantenere il peso';

  @override
  String get goalGain => 'Aumentare di peso';

  @override
  String get bmiUnderweight => 'Sottopeso';

  @override
  String get bmiNormal => 'Peso normale';

  @override
  String get bmiOverweight => 'Sovrappeso';

  @override
  String get bmiObese => 'Obeso';

  @override
  String get todayShareTooltip => 'Condividi la tua giornata';

  @override
  String get todayCopyTooltip => 'Copia i pasti di ieri';

  @override
  String get logFood => 'Registra cibo';

  @override
  String get emptyTodayTitle => 'Ancora niente registrato oggi';

  @override
  String get emptyTodayBody =>
      'Registra il tuo primo pasto per iniziare a monitorare calorie e macro.';

  @override
  String get copyYesterdayTitle => 'Copiare ieri?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copiare $count elementi da ieri a oggi?',
      one: 'Copiare 1 elemento da ieri a oggi?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'Ieri non è stato registrato nulla.';

  @override
  String get copyAction => 'Copia';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copiati $count elementi da ieri.',
      one: 'Copiato 1 elemento da ieri.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal assunte';

  @override
  String get netKcal => 'kcal nette';

  @override
  String kcalLeft(int n) {
    return '$n rimaste';
  }

  @override
  String kcalOver(int n) {
    return '$n in più';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n bruciate';
  }

  @override
  String get bodyWeight => 'Peso corporeo';

  @override
  String get notLoggedToday => 'Non registrato oggi';

  @override
  String get logWeight => 'Registra peso';

  @override
  String get weightInvalid => 'Inserisci un peso valido.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg kg  ·  registrato oggi';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg kg  ·  registrato il $date';
  }

  @override
  String get healthSync => 'Sincronizzazione Salute';

  @override
  String get healthConnectApple =>
      'Collega Apple Salute per importare le calorie bruciate e sincronizzare la tua nutrizione.';

  @override
  String get healthConnectGoogle =>
      'Collega Google Health Connect per importare le calorie bruciate e sincronizzare la tua nutrizione.';

  @override
  String get connectHealth => 'Collega Salute';

  @override
  String get healthDeniedIos =>
      'Apri Impostazioni → Privacy e sicurezza → Salute → PlateSimple per concedere l\'accesso.';

  @override
  String get healthDeniedAndroid =>
      'Apri Health Connect e concedi i permessi a PlateSimple.';

  @override
  String get statSteps => 'Passi';

  @override
  String get statBurned => 'Bruciate';

  @override
  String get syncNutrition => 'Sincronizza nutrizione con Salute';

  @override
  String get healthSynced => 'Nutrizione sincronizzata con Salute!';

  @override
  String get healthWriteFailed => 'Impossibile scrivere su Salute.';

  @override
  String get healthNotGranted =>
      'Accesso a Salute non concesso. Controlla i permessi.';

  @override
  String get activity => 'Attività';

  @override
  String get noActivityToday => 'Nessuna attività registrata oggi.';

  @override
  String get addActivity => 'Aggiungi attività';

  @override
  String get logActivityTitle => 'Registra attività';

  @override
  String get presets => 'Preimpostazioni';

  @override
  String get manual => 'Manuale';

  @override
  String get activityNameLabel => 'Nome dell\'attività';

  @override
  String get activityNameHint => 'es. Calcio, Ballo…';

  @override
  String get caloriesBurnedLabel => 'Calorie bruciate';

  @override
  String get durationLabel => 'Durata';

  @override
  String estimatedBurned(int n) {
    return 'Stima: ~$n kcal bruciate';
  }

  @override
  String get enterValidDuration => 'Inserisci una durata valida.';

  @override
  String get enterCaloriesBurned => 'Inserisci le calorie bruciate.';

  @override
  String get selectActivityFirst => 'Seleziona prima un\'attività.';

  @override
  String get customActivity => 'Attività personalizzata';

  @override
  String get actWalking => 'Camminata';

  @override
  String get actRunning => 'Corsa';

  @override
  String get actCycling => 'Ciclismo';

  @override
  String get actSwimming => 'Nuoto';

  @override
  String get actWeightTraining => 'Pesi';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Escursionismo';

  @override
  String get mealBreakfast => 'Colazione';

  @override
  String get mealLunch => 'Pranzo';

  @override
  String get mealDinner => 'Cena';

  @override
  String get mealSnack => 'Spuntino';

  @override
  String get deleteEntryTitle => 'Eliminare la voce?';

  @override
  String deleteEntryBody(String name, String meal) {
    return 'Rimuovere \"$name\" da $meal?';
  }

  @override
  String get holdToEdit => 'tieni premuto per modificare';

  @override
  String get servingSizeLabel => 'Dimensione porzione';

  @override
  String get addFoodTitle => 'Aggiungi cibo';

  @override
  String get pickIngredientTitle => 'Scegli ingrediente';

  @override
  String get tabSearch => 'Cerca';

  @override
  String get tabRecentFav => 'Recenti e preferiti';

  @override
  String get tabRecipes => 'Ricette';

  @override
  String get tabMyFoods => 'I miei cibi';

  @override
  String get searchHint => 'Cerca cibi…';

  @override
  String get scanTooltip => 'Scansiona codice a barre';

  @override
  String noResults(String query) {
    return 'Nessun risultato per \"$query\".\nProva un termine più specifico o scansiona il codice a barre.';
  }

  @override
  String searchErrorRetry(String error) {
    return '$error\nTrascina verso il basso per riprovare.';
  }

  @override
  String get createCustomFood => 'Crea cibo personalizzato';

  @override
  String get sectionFavourites => 'Preferiti ⭐';

  @override
  String get sectionRecent => 'Recenti';

  @override
  String get noFoodsYet => 'Ancora nessun cibo.';

  @override
  String get unlockScannerTitle => 'Sblocca lo scanner di codici a barre';

  @override
  String get unlockScannerBody =>
      'Guarda un breve annuncio per sbloccare lo scanner di codici a barre per il resto della giornata.';

  @override
  String get watchAd => 'Guarda l\'annuncio';

  @override
  String get adUnavailable =>
      'Annuncio non disponibile ora. Riprova tra un momento.';

  @override
  String get productNotFound => 'Prodotto non trovato nel database.';

  @override
  String get createNewRecipe => 'Crea nuova ricetta';

  @override
  String get noRecipesYet =>
      'Ancora nessuna ricetta.\nTocca \"Crea nuova ricetta\" per iniziare.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porzioni',
      one: '1 porzione',
    );
    return '$kcal kcal/porzione  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '$kcal kcal per porzione';
  }

  @override
  String get servingsToLog => 'Porzioni da registrare';

  @override
  String get createRecipeTitle => 'Crea ricetta';

  @override
  String get editRecipeTitle => 'Modifica ricetta';

  @override
  String get recipeNameLabel => 'Nome della ricetta';

  @override
  String get recipeNameRequired => 'Il nome della ricetta è obbligatorio.';

  @override
  String get recipeDescLabel => 'Descrizione (facoltativa)';

  @override
  String get servingsLabel => 'Porzioni';

  @override
  String get ingredients => 'Ingredienti';

  @override
  String get addAtLeastOne => 'Aggiungi almeno un ingrediente.';

  @override
  String get noIngredientsYet => 'Ancora nessun ingrediente.';

  @override
  String get nutritionSummary => 'Riepilogo nutrizionale';

  @override
  String get total => 'Totale';

  @override
  String get perServing => 'Per porzione';

  @override
  String perServingCount(int count) {
    return 'Per porzione ($count porzioni)';
  }

  @override
  String get createCustomFoodTitle => 'Crea cibo personalizzato';

  @override
  String get foodDetailsSection => 'Dettagli del cibo';

  @override
  String get valuesPer100 => 'I valori sono per 100 g / 100 ml.';

  @override
  String get foodNameLabel => 'Nome del cibo';

  @override
  String get brandOptional => 'Marca (facoltativa)';

  @override
  String get nutritionPer100 => 'Nutrizione per 100 g';

  @override
  String get fieldRequired => 'Obbligatorio';

  @override
  String get enterValidNumber => 'Inserisci un numero valido';

  @override
  String get saveAndLog => 'Salva e registra porzione';

  @override
  String get removeFavourite => 'Rimuovi dai preferiti';

  @override
  String get addToFavourites => 'Aggiungi ai preferiti';

  @override
  String get servingSizeG => 'Dimensione porzione (g)';

  @override
  String get addToLabel => 'Aggiungi a';

  @override
  String addToMeal(String meal) {
    return 'Aggiungi a $meal';
  }

  @override
  String get scanBarcodeTitle => 'Scansiona codice a barre';

  @override
  String get historyTitle => 'Cronologia';

  @override
  String get noLoggedDays => 'Ancora nessun giorno registrato.';

  @override
  String get today => 'Oggi';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => 'Analisi settimanali';

  @override
  String get premiumFeature => 'Funzione Premium';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get sevenDayAverage => 'Media di 7 giorni';

  @override
  String kcalAvg(int n) {
    return '$n kcal media';
  }

  @override
  String get kcalAvgEmpty => '— kcal media';

  @override
  String get weightTrend => 'Andamento del peso';

  @override
  String get prevMonth => 'Mese precedente';

  @override
  String get nextMonth => 'Mese successivo';

  @override
  String get shareDayTitle => 'Condividi la tua giornata';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => 'Obiettivo raggiunto!';

  @override
  String ofGoal(int n) {
    return 'su $n obiettivo';
  }

  @override
  String get trackedWith => 'monitorato con PlateSimple';

  @override
  String get preparing => 'Preparazione…';

  @override
  String get share => 'Condividi';

  @override
  String shareText(String url) {
    return 'La mia nutrizione oggi — monitorata con PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle => 'Sblocca l\'esperienza completa';

  @override
  String get featInsightsTitle => 'Analisi settimanali (7 giorni)';

  @override
  String get featInsightsSub =>
      'Vedi il grafico delle calorie e la media di 7 giorni in un colpo d\'occhio.';

  @override
  String get featAdFreeTitle => 'Senza pubblicità';

  @override
  String get featAdFreeSub => 'Nessun annuncio interstitial o con premio. Mai.';

  @override
  String get featSupportTitle => 'Sostieni uno sviluppatore indipendente';

  @override
  String get featSupportSub =>
      'PlateSimple è creato e mantenuto da una sola persona. Il tuo abbonamento lo mantiene attivo.';

  @override
  String get loadPricingError =>
      'Impossibile caricare i prezzi.\nControlla la connessione e riprova.';

  @override
  String get choosePlan => 'Scegli un piano';

  @override
  String get alreadyPremium => 'Sei già Premium ✓';

  @override
  String get subscribe => 'Abbonati';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get privacyPolicy => 'Privacy';

  @override
  String get termsOfUse => 'Termini d\'uso';

  @override
  String get subsRenew =>
      'Gli abbonamenti si rinnovano automaticamente. Annulla quando vuoi nelle impostazioni del dispositivo.';

  @override
  String get premiumRestored => 'Premium ripristinato con successo!';

  @override
  String get noSubFound => 'Nessun abbonamento attivo trovato.';

  @override
  String get planYearly => 'Annuale';

  @override
  String get planMonthly => 'Mensile';

  @override
  String get bestValue => 'MIGLIOR VALORE';

  @override
  String get billedYearly => 'Addebitato una volta all\'anno';

  @override
  String get billedMonthly => 'Addebitato mensilmente';

  @override
  String get freeTrial => 'Prova gratuita';

  @override
  String get legendUnder => 'Sotto';

  @override
  String get legendOnTarget => 'In obiettivo';

  @override
  String get legendOver => 'Sopra';

  @override
  String get notifTitle => 'È ora di registrare i pasti 🥗';

  @override
  String get notifBody =>
      'Mantieni la tua serie — registra cosa hai mangiato oggi!';

  @override
  String get notifChannelName => 'Promemoria giornalieri';

  @override
  String get notifChannelDesc => 'Ti ricorda di registrare i pasti ogni giorno';
}
