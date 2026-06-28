// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get update => 'Actualizar';

  @override
  String get reset => 'Restablecer';

  @override
  String get remove => 'Quitar';

  @override
  String get edit => 'Editar';

  @override
  String get add => 'Añadir';

  @override
  String get logAction => 'Registrar';

  @override
  String get getStarted => 'Empezar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get letsGo => '¡Vamos!';

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get navToday => 'Hoy';

  @override
  String get navHistory => 'Historial';

  @override
  String get navGoals => 'Objetivos';

  @override
  String get macroCalories => 'Calorías';

  @override
  String get macroProtein => 'Proteína';

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroFat => 'Grasa';

  @override
  String get fieldCalories => 'Calorías';

  @override
  String get fieldProtein => 'Proteína';

  @override
  String get fieldCarbohydrates => 'Carbohidratos';

  @override
  String get fieldFat => 'Grasa';

  @override
  String get fieldDailyCalories => 'Calorías diarias';

  @override
  String get fieldProteinPct => 'Proteína %';

  @override
  String get fieldCarbsPct => 'Carbohidratos %';

  @override
  String get fieldFatPct => 'Grasa %';

  @override
  String get calculatedCalories => 'Calorías calculadas';

  @override
  String get goalModeManual => 'Manual';

  @override
  String get goalModePercent => '% → Macros';

  @override
  String get goalModeMacros => 'Macros → kcal';

  @override
  String get goalModeManualDesc =>
      'Introduce tus calorías y gramos de macros directamente.';

  @override
  String get goalModePercentDesc =>
      'Introduce las calorías totales y la división en % — los gramos se calculan en vivo.';

  @override
  String get goalModeMacrosDesc =>
      'Introduce tus gramos de macros — las calorías totales se calculan en vivo.';

  @override
  String get pctTotalOk => 'Los porcentajes suman 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return 'Los porcentajes suman $sum% (deben ser 100%)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g de proteína';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g de carbohidratos';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g de grasa';
  }

  @override
  String get welcomeTitle => 'Te damos la bienvenida a PlateSimple';

  @override
  String get welcomeSubtitle =>
      'Conteo de calorías rápido y limpio.\nEscaneo de códigos de barras gratis. Sin lío.';

  @override
  String get onbSetGoalsTitle => 'Define tus objetivos diarios';

  @override
  String get onbSetGoalsSubtitle =>
      'Puedes cambiarlos cuando quieras en Objetivos.';

  @override
  String get onbStayOnTrackTitle => 'Mantén el rumbo';

  @override
  String get onbStayOnTrackBody =>
      'Permite las notificaciones para recordarte registrar comidas y mantener tu racha viva.';

  @override
  String get goalsDailyTargets => 'Objetivos nutricionales diarios';

  @override
  String get goalsChooseHow => 'Elige cómo quieres definir tus objetivos.';

  @override
  String get goalsCalcTdee => 'Calcular con TDEE / IMC';

  @override
  String get goalsSaveBtn => 'Guardar objetivos';

  @override
  String get goalsSavedSnack => '¡Objetivos guardados!';

  @override
  String get waterTrackingTitle => 'Registro de agua';

  @override
  String get waterTrackingSubtitle =>
      'Controla tu consumo diario de agua en la pantalla de inicio.';

  @override
  String get waterShowTracker => 'Mostrar registro de agua';

  @override
  String get waterShowTrackerSub =>
      'Muestra la tarjeta de agua en la pantalla Hoy';

  @override
  String get waterDailyGoal => 'Objetivo diario';

  @override
  String get waterGlassesUnit => 'vasos';

  @override
  String get water => 'Agua';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal vasos';
  }

  @override
  String get resetWaterTitle => '¿Restablecer agua?';

  @override
  String get resetWaterBody => '¿Volver a poner a 0 el conteo de agua de hoy?';

  @override
  String get reminderTitle => 'Recordatorio diario';

  @override
  String get reminderSubtitle =>
      'Recibe un aviso diario para registrar tus comidas.';

  @override
  String get reminderEnable => 'Activar recordatorio';

  @override
  String get reminderEnableSub => 'Envía una notificación diaria';

  @override
  String get reminderTimeLabel => 'Hora del recordatorio';

  @override
  String get feedbackTitle => 'Opiniones';

  @override
  String get feedbackBody =>
      'Soy un desarrollador independiente y tu opinión ayuda a mejorar PlateSimple. ¡Menos de un minuto!';

  @override
  String get feedbackShare => 'Compartir opinión';

  @override
  String get dataExportTitle => 'Exportar datos';

  @override
  String get dataExportSubtitle =>
      'Exporta tu registro de comidas, peso y actividad.';

  @override
  String get exportCsv => 'Exportar como CSV';

  @override
  String get exportCsvSub => 'Compatible con hojas de cálculo';

  @override
  String get exportJson => 'Exportar como JSON';

  @override
  String get exportJsonSub => 'Copia de seguridad completa';

  @override
  String get aboutTitle => 'Acerca de PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => 'Mejorar a Premium';

  @override
  String get premiumBannerMemberTitle => 'Eres miembro Premium';

  @override
  String get premiumBannerUpgradeSub =>
      'Análisis semanales · Sin anuncios · Apoya al dev';

  @override
  String get premiumBannerMemberSub =>
      'Análisis semanales desbloqueados · Sin anuncios';

  @override
  String get tdeeTitle => 'Calculadora TDEE';

  @override
  String get tdeeSubtitle =>
      'Introduce tus datos para calcular tu gasto energético diario total y fijar tu objetivo de calorías automáticamente.';

  @override
  String get sexMale => 'Hombre';

  @override
  String get sexFemale => 'Mujer';

  @override
  String get fieldAge => 'Edad';

  @override
  String get fieldHeight => 'Altura';

  @override
  String get fieldWeight => 'Peso';

  @override
  String get unitYears => 'años';

  @override
  String get activityLevelLabel => 'Nivel de actividad';

  @override
  String get goalLabel => 'Objetivo';

  @override
  String get calculate => 'Calcular';

  @override
  String get tdeeInvalid => 'Introduce valores válidos en todos los campos.';

  @override
  String get yourResults => 'Tus resultados';

  @override
  String get bmrLabel => 'TMB (tasa metabólica basal)';

  @override
  String get tdeeMaintenance => 'TDEE (mantenimiento)';

  @override
  String get bmiLabel => 'IMC';

  @override
  String get suggestedGoals => 'Objetivos sugeridos';

  @override
  String get applyGoals => 'Aplicar estos objetivos';

  @override
  String get tdeeAppliedSnack =>
      '¡Objetivos actualizados con la calculadora TDEE!';

  @override
  String get activitySedentary => 'Sedentario (poco o nada de ejercicio)';

  @override
  String get activityLight => 'Ligeramente activo (1–3 días/semana)';

  @override
  String get activityModerate => 'Moderadamente activo (3–5 días/semana)';

  @override
  String get activityVery => 'Muy activo (6–7 días/semana)';

  @override
  String get activityExtra =>
      'Extremadamente activo (trabajo físico + entrenamiento)';

  @override
  String get goalLose => 'Perder peso';

  @override
  String get goalMaintain => 'Mantener peso';

  @override
  String get goalGain => 'Ganar peso';

  @override
  String get bmiUnderweight => 'Bajo peso';

  @override
  String get bmiNormal => 'Peso normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obesidad';

  @override
  String get todayShareTooltip => 'Comparte tu día';

  @override
  String get todayCopyTooltip => 'Copiar las comidas de ayer';

  @override
  String get logFood => 'Registrar comida';

  @override
  String get emptyTodayTitle => 'Nada registrado hoy todavía';

  @override
  String get emptyTodayBody =>
      'Registra tu primera comida para empezar a controlar calorías y macros.';

  @override
  String get copyYesterdayTitle => '¿Copiar ayer?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Copiar $count elementos de ayer a hoy?',
      one: '¿Copiar 1 elemento de ayer a hoy?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'No se registró nada ayer.';

  @override
  String get copyAction => 'Copiar';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se copiaron $count elementos de ayer.',
      one: 'Se copió 1 elemento de ayer.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal consumidas';

  @override
  String get netKcal => 'kcal netas';

  @override
  String kcalLeft(int n) {
    return '$n restantes';
  }

  @override
  String kcalOver(int n) {
    return '$n de más';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n quemadas';
  }

  @override
  String get bodyWeight => 'Peso corporal';

  @override
  String get notLoggedToday => 'No registrado hoy';

  @override
  String get logWeight => 'Registrar peso';

  @override
  String get weightInvalid => 'Introduce un peso válido.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg kg  ·  registrado hoy';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg kg  ·  registrado el $date';
  }

  @override
  String get healthSync => 'Sincronización de Salud';

  @override
  String get healthConnectApple =>
      'Conecta Apple Salud para importar calorías quemadas y sincronizar tu nutrición.';

  @override
  String get healthConnectGoogle =>
      'Conecta Google Health Connect para importar calorías quemadas y sincronizar tu nutrición.';

  @override
  String get connectHealth => 'Conectar Salud';

  @override
  String get healthDeniedIos =>
      'Abre Ajustes → Privacidad y seguridad → Salud → PlateSimple para conceder acceso.';

  @override
  String get healthDeniedAndroid =>
      'Abre Health Connect y concede permisos a PlateSimple.';

  @override
  String get statSteps => 'Pasos';

  @override
  String get statBurned => 'Quemadas';

  @override
  String get syncNutrition => 'Sincronizar nutrición con Salud';

  @override
  String get healthSynced => '¡Nutrición sincronizada con Salud!';

  @override
  String get healthWriteFailed => 'No se pudo escribir en Salud.';

  @override
  String get healthNotGranted =>
      'Acceso a Salud no concedido. Revisa los permisos.';

  @override
  String get activity => 'Actividad';

  @override
  String get noActivityToday => 'Sin actividad registrada hoy.';

  @override
  String get addActivity => 'Añadir actividad';

  @override
  String get logActivityTitle => 'Registrar actividad';

  @override
  String get presets => 'Predefinidos';

  @override
  String get manual => 'Manual';

  @override
  String get activityNameLabel => 'Nombre de la actividad';

  @override
  String get activityNameHint => 'p. ej. Fútbol, Bailar…';

  @override
  String get caloriesBurnedLabel => 'Calorías quemadas';

  @override
  String get durationLabel => 'Duración';

  @override
  String estimatedBurned(int n) {
    return 'Estimado: ~$n kcal quemadas';
  }

  @override
  String get enterValidDuration => 'Introduce una duración válida.';

  @override
  String get enterCaloriesBurned => 'Introduce las calorías quemadas.';

  @override
  String get selectActivityFirst => 'Selecciona primero una actividad.';

  @override
  String get customActivity => 'Actividad personalizada';

  @override
  String get actWalking => 'Caminar';

  @override
  String get actRunning => 'Correr';

  @override
  String get actCycling => 'Ciclismo';

  @override
  String get actSwimming => 'Natación';

  @override
  String get actWeightTraining => 'Pesas';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Senderismo';

  @override
  String get mealBreakfast => 'Desayuno';

  @override
  String get mealLunch => 'Almuerzo';

  @override
  String get mealDinner => 'Cena';

  @override
  String get mealSnack => 'Tentempié';

  @override
  String get deleteEntryTitle => '¿Eliminar entrada?';

  @override
  String deleteEntryBody(String name, String meal) {
    return '¿Quitar «$name» de $meal?';
  }

  @override
  String get holdToEdit => 'mantén para editar';

  @override
  String get servingSizeLabel => 'Tamaño de la ración';

  @override
  String get addFoodTitle => 'Añadir comida';

  @override
  String get pickIngredientTitle => 'Elegir ingrediente';

  @override
  String get tabSearch => 'Buscar';

  @override
  String get tabRecentFav => 'Recientes y favoritos';

  @override
  String get tabRecipes => 'Recetas';

  @override
  String get tabMyFoods => 'Mis alimentos';

  @override
  String get searchHint => 'Buscar alimentos…';

  @override
  String get scanTooltip => 'Escanear código de barras';

  @override
  String noResults(String query) {
    return 'Sin resultados para «$query».\nPrueba un término más específico o escanea el código de barras.';
  }

  @override
  String searchErrorRetry(String error) {
    return '$error\nDesliza hacia abajo para reintentar.';
  }

  @override
  String get createCustomFood => 'Crear alimento personalizado';

  @override
  String get sectionFavourites => 'Favoritos ⭐';

  @override
  String get sectionRecent => 'Recientes';

  @override
  String get noFoodsYet => 'Aún no hay alimentos.';

  @override
  String get unlockScannerTitle => 'Desbloquear escáner de códigos de barras';

  @override
  String get unlockScannerBody =>
      'Mira un anuncio breve para desbloquear el escáner de códigos de barras el resto del día.';

  @override
  String get watchAd => 'Ver anuncio';

  @override
  String get adUnavailable =>
      'Anuncio no disponible ahora. Inténtalo en un momento.';

  @override
  String get productNotFound => 'Producto no encontrado en la base de datos.';

  @override
  String get createNewRecipe => 'Crear nueva receta';

  @override
  String get noRecipesYet =>
      'Aún no hay recetas.\nToca «Crear nueva receta» para empezar.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count raciones',
      one: '1 ración',
    );
    return '$kcal kcal/ración  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '$kcal kcal por ración';
  }

  @override
  String get servingsToLog => 'Raciones a registrar';

  @override
  String get createRecipeTitle => 'Crear receta';

  @override
  String get editRecipeTitle => 'Editar receta';

  @override
  String get recipeNameLabel => 'Nombre de la receta';

  @override
  String get recipeNameRequired => 'El nombre de la receta es obligatorio.';

  @override
  String get recipeDescLabel => 'Descripción (opcional)';

  @override
  String get servingsLabel => 'Raciones';

  @override
  String get ingredients => 'Ingredientes';

  @override
  String get addAtLeastOne => 'Añade al menos un ingrediente.';

  @override
  String get noIngredientsYet => 'Aún no hay ingredientes.';

  @override
  String get nutritionSummary => 'Resumen nutricional';

  @override
  String get total => 'Total';

  @override
  String get perServing => 'Por ración';

  @override
  String perServingCount(int count) {
    return 'Por ración ($count raciones)';
  }

  @override
  String get createCustomFoodTitle => 'Crear alimento personalizado';

  @override
  String get foodDetailsSection => 'Detalles del alimento';

  @override
  String get valuesPer100 => 'Los valores son por 100 g / 100 ml.';

  @override
  String get foodNameLabel => 'Nombre del alimento';

  @override
  String get brandOptional => 'Marca (opcional)';

  @override
  String get nutritionPer100 => 'Nutrición por 100 g';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get enterValidNumber => 'Introduce un número válido';

  @override
  String get saveAndLog => 'Guardar y registrar ración';

  @override
  String get removeFavourite => 'Quitar de favoritos';

  @override
  String get addToFavourites => 'Añadir a favoritos';

  @override
  String get servingSizeG => 'Tamaño de la ración (g)';

  @override
  String get addToLabel => 'Añadir a';

  @override
  String addToMeal(String meal) {
    return 'Añadir a $meal';
  }

  @override
  String get scanBarcodeTitle => 'Escanear código de barras';

  @override
  String get historyTitle => 'Historial';

  @override
  String get noLoggedDays => 'Aún no hay días registrados.';

  @override
  String get today => 'Hoy';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => 'Análisis semanales';

  @override
  String get premiumFeature => 'Función Premium';

  @override
  String get upgradeToPremium => 'Mejorar a Premium';

  @override
  String get sevenDayAverage => 'Media de 7 días';

  @override
  String kcalAvg(int n) {
    return '$n kcal med.';
  }

  @override
  String get kcalAvgEmpty => '— kcal med.';

  @override
  String get weightTrend => 'Tendencia de peso';

  @override
  String get prevMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get shareDayTitle => 'Comparte tu día';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => '¡Objetivo logrado!';

  @override
  String ofGoal(int n) {
    return 'de $n objetivo';
  }

  @override
  String get trackedWith => 'registrado con PlateSimple';

  @override
  String get preparing => 'Preparando…';

  @override
  String get share => 'Compartir';

  @override
  String shareText(String url) {
    return 'Mi nutrición de hoy — registrada con PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle => 'Desbloquea la experiencia completa';

  @override
  String get featInsightsTitle => 'Análisis semanales (7 días)';

  @override
  String get featInsightsSub =>
      'Ve tu gráfico de calorías y tu media de 7 días de un vistazo.';

  @override
  String get featAdFreeTitle => 'Sin anuncios';

  @override
  String get featAdFreeSub =>
      'Sin anuncios intersticiales ni recompensados. Nunca.';

  @override
  String get featSupportTitle => 'Apoya a un desarrollador independiente';

  @override
  String get featSupportSub =>
      'PlateSimple lo crea y mantiene una sola persona. Tu suscripción lo mantiene en marcha.';

  @override
  String get loadPricingError =>
      'No se pudieron cargar los precios.\nComprueba tu conexión e inténtalo de nuevo.';

  @override
  String get choosePlan => 'Elige un plan';

  @override
  String get alreadyPremium => 'Ya eres Premium ✓';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get subsRenew =>
      'Las suscripciones se renuevan automáticamente. Cancela cuando quieras en los ajustes de tu dispositivo.';

  @override
  String get premiumRestored => '¡Premium restaurado correctamente!';

  @override
  String get noSubFound => 'No se encontró ninguna suscripción activa.';

  @override
  String get planYearly => 'Anual';

  @override
  String get planMonthly => 'Mensual';

  @override
  String get bestValue => 'MEJOR VALOR';

  @override
  String get billedYearly => 'Se cobra una vez al año';

  @override
  String get billedMonthly => 'Se cobra mensualmente';

  @override
  String get legendUnder => 'Por debajo';

  @override
  String get legendOnTarget => 'En objetivo';

  @override
  String get legendOver => 'Por encima';

  @override
  String get notifTitle => 'Hora de registrar tus comidas 🥗';

  @override
  String get notifBody => 'Mantén tu racha — ¡registra lo que comiste hoy!';

  @override
  String get notifChannelName => 'Recordatorios diarios';

  @override
  String get notifChannelDesc => 'Te recuerda registrar tus comidas cada día';
}
