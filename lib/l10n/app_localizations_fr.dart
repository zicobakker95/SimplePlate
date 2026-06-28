// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get update => 'Mettre à jour';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get remove => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get logAction => 'Enregistrer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get letsGo => 'C\'est parti !';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get navToday => 'Aujourd\'hui';

  @override
  String get navHistory => 'Historique';

  @override
  String get navGoals => 'Objectifs';

  @override
  String get macroCalories => 'Calories';

  @override
  String get macroProtein => 'Protéines';

  @override
  String get macroCarbs => 'Gluc.';

  @override
  String get macroFat => 'Lipides';

  @override
  String get fieldCalories => 'Calories';

  @override
  String get fieldProtein => 'Protéines';

  @override
  String get fieldCarbohydrates => 'Glucides';

  @override
  String get fieldFat => 'Lipides';

  @override
  String get fieldDailyCalories => 'Calories quotidiennes';

  @override
  String get fieldProteinPct => 'Protéines %';

  @override
  String get fieldCarbsPct => 'Glucides %';

  @override
  String get fieldFatPct => 'Lipides %';

  @override
  String get calculatedCalories => 'Calories calculées';

  @override
  String get goalModeManual => 'Manuel';

  @override
  String get goalModePercent => '% → Macros';

  @override
  String get goalModeMacros => 'Macros → kcal';

  @override
  String get goalModeManualDesc =>
      'Saisissez directement vos calories et grammes de macros.';

  @override
  String get goalModePercentDesc =>
      'Saisissez les calories totales et la répartition en % — les grammes sont calculés en direct.';

  @override
  String get goalModeMacrosDesc =>
      'Saisissez vos grammes de macros — les calories totales sont calculées en direct.';

  @override
  String get pctTotalOk => 'Les pourcentages font 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return 'Les pourcentages font $sum% (doivent faire 100%)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g de protéines';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g de glucides';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g de lipides';
  }

  @override
  String get welcomeTitle => 'Bienvenue sur PlateSimple';

  @override
  String get welcomeSubtitle =>
      'Comptage des calories rapide et épuré.\nScan de codes-barres gratuit. Sans superflu.';

  @override
  String get onbSetGoalsTitle => 'Définissez vos objectifs quotidiens';

  @override
  String get onbSetGoalsSubtitle =>
      'Vous pouvez les modifier à tout moment dans Objectifs.';

  @override
  String get onbStayOnTrackTitle => 'Restez sur la bonne voie';

  @override
  String get onbStayOnTrackBody =>
      'Autorisez les notifications pour que nous puissions vous rappeler d\'enregistrer vos repas et garder votre série active.';

  @override
  String get goalsDailyTargets => 'Objectifs nutritionnels quotidiens';

  @override
  String get goalsChooseHow => 'Choisissez comment définir vos objectifs.';

  @override
  String get goalsCalcTdee => 'Calculer avec DEJ / IMC';

  @override
  String get goalsSaveBtn => 'Enregistrer les objectifs';

  @override
  String get goalsSavedSnack => 'Objectifs enregistrés !';

  @override
  String get waterTrackingTitle => 'Suivi de l\'eau';

  @override
  String get waterTrackingSubtitle =>
      'Suivez votre consommation d\'eau quotidienne sur l\'écran d\'accueil.';

  @override
  String get waterShowTracker => 'Afficher le suivi de l\'eau';

  @override
  String get waterShowTrackerSub =>
      'Affiche la carte d\'eau sur l\'écran Aujourd\'hui';

  @override
  String get waterDailyGoal => 'Objectif quotidien';

  @override
  String get waterGlassesUnit => 'verres';

  @override
  String get water => 'Eau';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal verres';
  }

  @override
  String get resetWaterTitle => 'Réinitialiser l\'eau ?';

  @override
  String get resetWaterBody =>
      'Remettre le compteur d\'eau d\'aujourd\'hui à 0 ?';

  @override
  String get reminderTitle => 'Rappel quotidien';

  @override
  String get reminderSubtitle =>
      'Recevez un rappel quotidien pour enregistrer vos repas.';

  @override
  String get reminderEnable => 'Activer le rappel';

  @override
  String get reminderEnableSub => 'Envoie une notification quotidienne';

  @override
  String get reminderTimeLabel => 'Heure du rappel';

  @override
  String get feedbackTitle => 'Avis';

  @override
  String get feedbackBody =>
      'Je suis un développeur indépendant et votre avis aide à améliorer PlateSimple. Moins d\'une minute !';

  @override
  String get feedbackShare => 'Partager un avis';

  @override
  String get dataExportTitle => 'Export des données';

  @override
  String get dataExportSubtitle =>
      'Exportez votre journal alimentaire, votre poids et vos activités.';

  @override
  String get exportCsv => 'Exporter en CSV';

  @override
  String get exportCsvSub => 'Compatible tableur';

  @override
  String get exportJson => 'Exporter en JSON';

  @override
  String get exportJsonSub => 'Sauvegarde complète';

  @override
  String get aboutTitle => 'À propos de PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => 'Passer à Premium';

  @override
  String get premiumBannerMemberTitle => 'Vous êtes membre Premium';

  @override
  String get premiumBannerUpgradeSub =>
      'Analyses hebdo · Sans pub · Soutenir le dev';

  @override
  String get premiumBannerMemberSub => 'Analyses hebdo débloquées · Sans pub';

  @override
  String get tdeeTitle => 'Calculateur DEJ';

  @override
  String get tdeeSubtitle =>
      'Saisissez vos données pour calculer votre dépense énergétique journalière et définir automatiquement votre objectif calorique.';

  @override
  String get sexMale => 'Homme';

  @override
  String get sexFemale => 'Femme';

  @override
  String get fieldAge => 'Âge';

  @override
  String get fieldHeight => 'Taille';

  @override
  String get fieldWeight => 'Poids';

  @override
  String get unitYears => 'ans';

  @override
  String get activityLevelLabel => 'Niveau d\'activité';

  @override
  String get goalLabel => 'Objectif';

  @override
  String get calculate => 'Calculer';

  @override
  String get tdeeInvalid =>
      'Veuillez saisir des valeurs valides pour tous les champs.';

  @override
  String get yourResults => 'Vos résultats';

  @override
  String get bmrLabel => 'MB (métabolisme de base)';

  @override
  String get tdeeMaintenance => 'DEJ (maintien)';

  @override
  String get bmiLabel => 'IMC';

  @override
  String get suggestedGoals => 'Objectifs suggérés';

  @override
  String get applyGoals => 'Appliquer ces objectifs';

  @override
  String get tdeeAppliedSnack =>
      'Objectifs mis à jour via le calculateur DEJ !';

  @override
  String get activitySedentary => 'Sédentaire (peu ou pas d\'exercice)';

  @override
  String get activityLight => 'Légèrement actif (1–3 jours/semaine)';

  @override
  String get activityModerate => 'Modérément actif (3–5 jours/semaine)';

  @override
  String get activityVery => 'Très actif (6–7 jours/semaine)';

  @override
  String get activityExtra =>
      'Extrêmement actif (travail physique + entraînement)';

  @override
  String get goalLose => 'Perdre du poids';

  @override
  String get goalMaintain => 'Maintenir le poids';

  @override
  String get goalGain => 'Prendre du poids';

  @override
  String get bmiUnderweight => 'Insuffisance pondérale';

  @override
  String get bmiNormal => 'Poids normal';

  @override
  String get bmiOverweight => 'Surpoids';

  @override
  String get bmiObese => 'Obésité';

  @override
  String get todayShareTooltip => 'Partagez votre journée';

  @override
  String get todayCopyTooltip => 'Copier les repas d\'hier';

  @override
  String get logFood => 'Enregistrer un aliment';

  @override
  String get emptyTodayTitle => 'Rien d\'enregistré aujourd\'hui';

  @override
  String get emptyTodayBody =>
      'Enregistrez votre premier repas pour suivre calories et macros.';

  @override
  String get copyYesterdayTitle => 'Copier hier ?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copier $count éléments d\'hier vers aujourd\'hui ?',
      one: 'Copier 1 élément d\'hier vers aujourd\'hui ?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'Rien d\'enregistré hier.';

  @override
  String get copyAction => 'Copier';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments d\'hier copiés.',
      one: '1 élément d\'hier copié.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal consommées';

  @override
  String get netKcal => 'kcal nettes';

  @override
  String kcalLeft(int n) {
    return '$n restantes';
  }

  @override
  String kcalOver(int n) {
    return '$n en trop';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n brûlées';
  }

  @override
  String get bodyWeight => 'Poids corporel';

  @override
  String get notLoggedToday => 'Pas enregistré aujourd\'hui';

  @override
  String get logWeight => 'Enregistrer le poids';

  @override
  String get weightInvalid => 'Saisissez un poids valide.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg kg  ·  enregistré aujourd\'hui';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg kg  ·  enregistré le $date';
  }

  @override
  String get healthSync => 'Sync Santé';

  @override
  String get healthConnectApple =>
      'Connectez Apple Santé pour importer les calories brûlées et synchroniser votre nutrition.';

  @override
  String get healthConnectGoogle =>
      'Connectez Google Health Connect pour importer les calories brûlées et synchroniser votre nutrition.';

  @override
  String get connectHealth => 'Connecter Santé';

  @override
  String get healthDeniedIos =>
      'Ouvrez Réglages → Confidentialité et sécurité → Santé → PlateSimple pour autoriser l\'accès.';

  @override
  String get healthDeniedAndroid =>
      'Ouvrez Health Connect et accordez les autorisations à PlateSimple.';

  @override
  String get statSteps => 'Pas';

  @override
  String get statBurned => 'Brûlées';

  @override
  String get syncNutrition => 'Synchroniser la nutrition avec Santé';

  @override
  String get healthSynced => 'Nutrition synchronisée avec Santé !';

  @override
  String get healthWriteFailed => 'Impossible d\'écrire dans Santé.';

  @override
  String get healthNotGranted =>
      'Accès Santé non accordé. Vérifiez les autorisations.';

  @override
  String get activity => 'Activité';

  @override
  String get noActivityToday => 'Aucune activité enregistrée aujourd\'hui.';

  @override
  String get addActivity => 'Ajouter une activité';

  @override
  String get logActivityTitle => 'Enregistrer une activité';

  @override
  String get presets => 'Préréglages';

  @override
  String get manual => 'Manuel';

  @override
  String get activityNameLabel => 'Nom de l\'activité';

  @override
  String get activityNameHint => 'ex. Football, Danse…';

  @override
  String get caloriesBurnedLabel => 'Calories brûlées';

  @override
  String get durationLabel => 'Durée';

  @override
  String estimatedBurned(int n) {
    return 'Estimation : ~$n kcal brûlées';
  }

  @override
  String get enterValidDuration => 'Saisissez une durée valide.';

  @override
  String get enterCaloriesBurned => 'Saisissez les calories brûlées.';

  @override
  String get selectActivityFirst => 'Sélectionnez d\'abord une activité.';

  @override
  String get customActivity => 'Activité personnalisée';

  @override
  String get actWalking => 'Marche';

  @override
  String get actRunning => 'Course';

  @override
  String get actCycling => 'Vélo';

  @override
  String get actSwimming => 'Natation';

  @override
  String get actWeightTraining => 'Musculation';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Randonnée';

  @override
  String get mealBreakfast => 'Petit-déjeuner';

  @override
  String get mealLunch => 'Déjeuner';

  @override
  String get mealDinner => 'Dîner';

  @override
  String get mealSnack => 'Collation';

  @override
  String get deleteEntryTitle => 'Supprimer l\'entrée ?';

  @override
  String deleteEntryBody(String name, String meal) {
    return 'Retirer « $name » de $meal ?';
  }

  @override
  String get holdToEdit => 'maintenir pour modifier';

  @override
  String get servingSizeLabel => 'Taille de portion';

  @override
  String get addFoodTitle => 'Ajouter un aliment';

  @override
  String get pickIngredientTitle => 'Choisir un ingrédient';

  @override
  String get tabSearch => 'Recherche';

  @override
  String get tabRecentFav => 'Récents et favoris';

  @override
  String get tabRecipes => 'Recettes';

  @override
  String get tabMyFoods => 'Mes aliments';

  @override
  String get searchHint => 'Rechercher des aliments…';

  @override
  String get scanTooltip => 'Scanner un code-barres';

  @override
  String noResults(String query) {
    return 'Aucun résultat pour « $query ».\nEssayez un terme plus précis ou scannez le code-barres.';
  }

  @override
  String searchErrorRetry(String error) {
    return '$error\nTirez vers le bas pour réessayer.';
  }

  @override
  String get createCustomFood => 'Créer un aliment personnalisé';

  @override
  String get sectionFavourites => 'Favoris ⭐';

  @override
  String get sectionRecent => 'Récents';

  @override
  String get noFoodsYet => 'Aucun aliment pour l\'instant.';

  @override
  String get unlockScannerTitle => 'Débloquer le scanner de codes-barres';

  @override
  String get unlockScannerBody =>
      'Regardez une courte pub pour débloquer le scanner de codes-barres pour le reste de la journée.';

  @override
  String get watchAd => 'Regarder la pub';

  @override
  String get adUnavailable =>
      'Pub indisponible pour le moment. Réessayez dans un instant.';

  @override
  String get productNotFound => 'Produit introuvable dans la base de données.';

  @override
  String get createNewRecipe => 'Créer une nouvelle recette';

  @override
  String get noRecipesYet =>
      'Aucune recette pour l\'instant.\nAppuyez sur « Créer une nouvelle recette » pour commencer.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count portions',
      one: '1 portion',
    );
    return '$kcal kcal/portion  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '$kcal kcal par portion';
  }

  @override
  String get servingsToLog => 'Portions à enregistrer';

  @override
  String get createRecipeTitle => 'Créer une recette';

  @override
  String get editRecipeTitle => 'Modifier la recette';

  @override
  String get recipeNameLabel => 'Nom de la recette';

  @override
  String get recipeNameRequired => 'Le nom de la recette est requis.';

  @override
  String get recipeDescLabel => 'Description (facultatif)';

  @override
  String get servingsLabel => 'Portions';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get addAtLeastOne => 'Ajoutez au moins un ingrédient.';

  @override
  String get noIngredientsYet => 'Aucun ingrédient pour l\'instant.';

  @override
  String get nutritionSummary => 'Résumé nutritionnel';

  @override
  String get total => 'Total';

  @override
  String get perServing => 'Par portion';

  @override
  String perServingCount(int count) {
    return 'Par portion ($count portions)';
  }

  @override
  String get createCustomFoodTitle => 'Créer un aliment personnalisé';

  @override
  String get foodDetailsSection => 'Détails de l\'aliment';

  @override
  String get valuesPer100 => 'Les valeurs sont pour 100 g / 100 ml.';

  @override
  String get foodNameLabel => 'Nom de l\'aliment';

  @override
  String get brandOptional => 'Marque (facultatif)';

  @override
  String get nutritionPer100 => 'Nutrition pour 100 g';

  @override
  String get fieldRequired => 'Requis';

  @override
  String get enterValidNumber => 'Saisissez un nombre valide';

  @override
  String get saveAndLog => 'Enregistrer et logger la portion';

  @override
  String get removeFavourite => 'Retirer des favoris';

  @override
  String get addToFavourites => 'Ajouter aux favoris';

  @override
  String get servingSizeG => 'Taille de portion (g)';

  @override
  String get addToLabel => 'Ajouter à';

  @override
  String addToMeal(String meal) {
    return 'Ajouter à $meal';
  }

  @override
  String get scanBarcodeTitle => 'Scanner un code-barres';

  @override
  String get historyTitle => 'Historique';

  @override
  String get noLoggedDays => 'Aucun jour enregistré pour l\'instant.';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => 'Analyses hebdomadaires';

  @override
  String get premiumFeature => 'Fonction Premium';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get sevenDayAverage => 'Moyenne sur 7 jours';

  @override
  String kcalAvg(int n) {
    return '$n kcal moy.';
  }

  @override
  String get kcalAvgEmpty => '— kcal moy.';

  @override
  String get weightTrend => 'Tendance du poids';

  @override
  String get prevMonth => 'Mois précédent';

  @override
  String get nextMonth => 'Mois suivant';

  @override
  String get shareDayTitle => 'Partagez votre journée';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => 'Objectif atteint !';

  @override
  String ofGoal(int n) {
    return 'sur $n objectif';
  }

  @override
  String get trackedWith => 'suivi avec PlateSimple';

  @override
  String get preparing => 'Préparation…';

  @override
  String get share => 'Partager';

  @override
  String shareText(String url) {
    return 'Ma nutrition aujourd\'hui — suivie avec PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle => 'Débloquez l\'expérience complète';

  @override
  String get featInsightsTitle => 'Analyses hebdomadaires (7 jours)';

  @override
  String get featInsightsSub =>
      'Visualisez votre courbe de calories et votre moyenne sur 7 jours d\'un coup d\'œil.';

  @override
  String get featAdFreeTitle => 'Sans publicité';

  @override
  String get featAdFreeSub =>
      'Aucune pub interstitielle ni récompensée. Jamais.';

  @override
  String get featSupportTitle => 'Soutenez un développeur indépendant';

  @override
  String get featSupportSub =>
      'PlateSimple est conçu et maintenu par une seule personne. Votre abonnement le fait vivre.';

  @override
  String get loadPricingError =>
      'Impossible de charger les tarifs.\nVérifiez votre connexion et réessayez.';

  @override
  String get choosePlan => 'Choisissez une formule';

  @override
  String get alreadyPremium => 'Vous êtes déjà Premium ✓';

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get privacyPolicy => 'Confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get subsRenew =>
      'Les abonnements se renouvellent automatiquement. Annulez à tout moment dans les réglages de votre appareil.';

  @override
  String get premiumRestored => 'Premium restauré avec succès !';

  @override
  String get noSubFound => 'Aucun abonnement actif trouvé.';

  @override
  String get planYearly => 'Annuel';

  @override
  String get planMonthly => 'Mensuel';

  @override
  String get bestValue => 'MEILLEURE OFFRE';

  @override
  String get billedYearly => 'Facturé une fois par an';

  @override
  String get billedMonthly => 'Facturé mensuellement';

  @override
  String get legendUnder => 'En dessous';

  @override
  String get legendOnTarget => 'Dans l\'objectif';

  @override
  String get legendOver => 'Au-dessus';

  @override
  String get notifTitle => 'C\'est l\'heure d\'enregistrer vos repas 🥗';

  @override
  String get notifBody =>
      'Gardez votre série active — enregistrez ce que vous avez mangé aujourd\'hui !';

  @override
  String get notifChannelName => 'Rappels quotidiens';

  @override
  String get notifChannelDesc =>
      'Vous rappelle d\'enregistrer vos repas chaque jour';
}
