// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get update => 'Atualizar';

  @override
  String get reset => 'Redefinir';

  @override
  String get remove => 'Remover';

  @override
  String get edit => 'Editar';

  @override
  String get add => 'Adicionar';

  @override
  String get logAction => 'Registrar';

  @override
  String get getStarted => 'Começar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get letsGo => 'Vamos lá!';

  @override
  String get skipForNow => 'Pular por enquanto';

  @override
  String get openSettings => 'Abrir Ajustes';

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get navToday => 'Hoje';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navGoals => 'Metas';

  @override
  String get macroCalories => 'Calorias';

  @override
  String get macroProtein => 'Proteína';

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroFat => 'Gordura';

  @override
  String get fieldCalories => 'Calorias';

  @override
  String get fieldProtein => 'Proteína';

  @override
  String get fieldCarbohydrates => 'Carboidratos';

  @override
  String get fieldFat => 'Gordura';

  @override
  String get fieldDailyCalories => 'Calorias diárias';

  @override
  String get fieldProteinPct => 'Proteína %';

  @override
  String get fieldCarbsPct => 'Carboidratos %';

  @override
  String get fieldFatPct => 'Gordura %';

  @override
  String get calculatedCalories => 'Calorias calculadas';

  @override
  String get goalModeManual => 'Manual';

  @override
  String get goalModePercent => '% → Macros';

  @override
  String get goalModeMacros => 'Macros → kcal';

  @override
  String get goalModeManualDesc =>
      'Insira suas calorias e gramas de macros diretamente.';

  @override
  String get goalModePercentDesc =>
      'Insira as calorias totais e a divisão em % — os gramas são calculados ao vivo.';

  @override
  String get goalModeMacrosDesc =>
      'Insira seus gramas de macros — as calorias totais são calculadas ao vivo.';

  @override
  String get pctTotalOk => 'As porcentagens somam 100% ✓';

  @override
  String pctTotalOff(int sum) {
    return 'As porcentagens somam $sum% (devem ser 100%)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g de proteína';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g de carboidratos';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g de gordura';
  }

  @override
  String get welcomeTitle => 'Boas-vindas ao PlateSimple';

  @override
  String get welcomeSubtitle =>
      'Contagem de calorias rápida e limpa.\nLeitura de código de barras grátis. Sem bagunça.';

  @override
  String get onbSetGoalsTitle => 'Defina suas metas diárias';

  @override
  String get onbSetGoalsSubtitle =>
      'Você pode alterá-las quando quiser em Metas.';

  @override
  String get onbStayOnTrackTitle => 'Mantenha o foco';

  @override
  String get onbStayOnTrackBody =>
      'Permita as notificações para lembrarmos você de registrar as refeições e manter sua sequência viva.';

  @override
  String get goalsDailyTargets => 'Metas nutricionais diárias';

  @override
  String get goalsChooseHow => 'Escolha como deseja definir suas metas.';

  @override
  String get goalsCalcTdee => 'Calcular com TDEE / IMC';

  @override
  String get goalsSaveBtn => 'Salvar metas';

  @override
  String get goalsSavedSnack => 'Metas salvas!';

  @override
  String get waterTrackingTitle => 'Controle de água';

  @override
  String get waterTrackingSubtitle =>
      'Acompanhe seu consumo diário de água na tela inicial.';

  @override
  String get waterShowTracker => 'Mostrar controle de água';

  @override
  String get waterShowTrackerSub => 'Exibe o cartão de água na tela Hoje';

  @override
  String get waterDailyGoal => 'Meta diária';

  @override
  String get waterGlassesUnit => 'copos';

  @override
  String get water => 'Água';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal copos';
  }

  @override
  String get resetWaterTitle => 'Redefinir água?';

  @override
  String get resetWaterBody => 'Voltar a contagem de água de hoje para 0?';

  @override
  String get reminderTitle => 'Lembrete diário';

  @override
  String get reminderSubtitle =>
      'Receba um lembrete diário para registrar suas refeições.';

  @override
  String get reminderEnable => 'Ativar lembrete';

  @override
  String get reminderEnableSub => 'Envia uma notificação diária';

  @override
  String get reminderTimeLabel => 'Horário do lembrete';

  @override
  String get feedbackTitle => 'Comentários';

  @override
  String get feedbackBody =>
      'Sou um desenvolvedor solo e seu comentário ajuda a melhorar o PlateSimple. Leva menos de um minuto!';

  @override
  String get feedbackShare => 'Compartilhar comentário';

  @override
  String get dataExportTitle => 'Exportar dados';

  @override
  String get dataExportSubtitle =>
      'Exporte seu diário alimentar, peso e atividades.';

  @override
  String get exportCsv => 'Exportar como CSV';

  @override
  String get exportCsvSub => 'Compatível com planilhas';

  @override
  String get exportJson => 'Exportar como JSON';

  @override
  String get exportJsonSub => 'Backup completo';

  @override
  String get aboutTitle => 'Sobre o PlateSimple';

  @override
  String get premiumBannerUpgradeTitle => 'Assinar o Premium';

  @override
  String get premiumBannerMemberTitle => 'Você é membro Premium';

  @override
  String get premiumBannerUpgradeSub =>
      'Análises semanais · Sem anúncios · Apoie o dev';

  @override
  String get premiumBannerMemberSub =>
      'Análises semanais desbloqueadas · Sem anúncios';

  @override
  String get tdeeTitle => 'Calculadora de TDEE';

  @override
  String get tdeeSubtitle =>
      'Insira seus dados para calcular seu gasto energético diário total e definir sua meta de calorias automaticamente.';

  @override
  String get sexMale => 'Masculino';

  @override
  String get sexFemale => 'Feminino';

  @override
  String get fieldAge => 'Idade';

  @override
  String get fieldHeight => 'Altura';

  @override
  String get fieldWeight => 'Peso';

  @override
  String get unitYears => 'anos';

  @override
  String get activityLevelLabel => 'Nível de atividade';

  @override
  String get goalLabel => 'Meta';

  @override
  String get calculate => 'Calcular';

  @override
  String get tdeeInvalid => 'Insira valores válidos em todos os campos.';

  @override
  String get yourResults => 'Seus resultados';

  @override
  String get bmrLabel => 'TMB (taxa metabólica basal)';

  @override
  String get tdeeMaintenance => 'TDEE (manutenção)';

  @override
  String get bmiLabel => 'IMC';

  @override
  String get suggestedGoals => 'Metas sugeridas';

  @override
  String get applyGoals => 'Aplicar estas metas';

  @override
  String get tdeeAppliedSnack => 'Metas atualizadas pela calculadora de TDEE!';

  @override
  String get activitySedentary => 'Sedentário (pouco ou nenhum exercício)';

  @override
  String get activityLight => 'Levemente ativo (1–3 dias/semana)';

  @override
  String get activityModerate => 'Moderadamente ativo (3–5 dias/semana)';

  @override
  String get activityVery => 'Muito ativo (6–7 dias/semana)';

  @override
  String get activityExtra => 'Extremamente ativo (trabalho físico + treino)';

  @override
  String get goalLose => 'Perder peso';

  @override
  String get goalMaintain => 'Manter peso';

  @override
  String get goalGain => 'Ganhar peso';

  @override
  String get bmiUnderweight => 'Abaixo do peso';

  @override
  String get bmiNormal => 'Peso normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obesidade';

  @override
  String get todayShareTooltip => 'Compartilhe seu dia';

  @override
  String get todayCopyTooltip => 'Copiar refeições de ontem';

  @override
  String get logFood => 'Registrar comida';

  @override
  String get emptyTodayTitle => 'Nada registrado hoje ainda';

  @override
  String get emptyTodayBody =>
      'Registre sua primeira refeição para começar a acompanhar calorias e macros.';

  @override
  String get copyYesterdayTitle => 'Copiar ontem?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copiar $count itens de ontem para hoje?',
      one: 'Copiar 1 item de ontem para hoje?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'Nada registrado ontem.';

  @override
  String get copyAction => 'Copiar';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens de ontem copiados.',
      one: '1 item de ontem copiado.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal ingeridas';

  @override
  String get netKcal => 'kcal líquidas';

  @override
  String kcalLeft(int n) {
    return '$n restantes';
  }

  @override
  String kcalOver(int n) {
    return '$n a mais';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n queimadas';
  }

  @override
  String get bodyWeight => 'Peso corporal';

  @override
  String get notLoggedToday => 'Não registrado hoje';

  @override
  String get logWeight => 'Registrar peso';

  @override
  String get weightInvalid => 'Insira um peso válido.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg kg  ·  registrado hoje';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg kg  ·  registrado em $date';
  }

  @override
  String get healthSync => 'Sincronização com Saúde';

  @override
  String get healthConnectApple =>
      'Conecte o Apple Saúde para importar calorias queimadas e sincronizar sua nutrição.';

  @override
  String get healthConnectGoogle =>
      'Conecte o Google Health Connect para importar calorias queimadas e sincronizar sua nutrição.';

  @override
  String get connectHealth => 'Conectar Saúde';

  @override
  String get healthDeniedIos =>
      'Abra Ajustes → Privacidade e Segurança → Saúde → PlateSimple para conceder acesso.';

  @override
  String get healthDeniedAndroid =>
      'Abra o Health Connect e conceda as permissões ao PlateSimple.';

  @override
  String get statSteps => 'Passos';

  @override
  String get statBurned => 'Queimadas';

  @override
  String get syncNutrition => 'Sincronizar nutrição com Saúde';

  @override
  String get healthSynced => 'Nutrição sincronizada com Saúde!';

  @override
  String get healthWriteFailed => 'Não foi possível gravar no Saúde.';

  @override
  String get healthNotGranted =>
      'Acesso ao Saúde não concedido. Verifique as permissões.';

  @override
  String get activity => 'Atividade';

  @override
  String get noActivityToday => 'Nenhuma atividade registrada hoje.';

  @override
  String get addActivity => 'Adicionar atividade';

  @override
  String get logActivityTitle => 'Registrar atividade';

  @override
  String get presets => 'Predefinições';

  @override
  String get manual => 'Manual';

  @override
  String get activityNameLabel => 'Nome da atividade';

  @override
  String get activityNameHint => 'ex.: Futebol, Dança…';

  @override
  String get caloriesBurnedLabel => 'Calorias queimadas';

  @override
  String get durationLabel => 'Duração';

  @override
  String estimatedBurned(int n) {
    return 'Estimativa: ~$n kcal queimadas';
  }

  @override
  String get enterValidDuration => 'Insira uma duração válida.';

  @override
  String get enterCaloriesBurned => 'Insira as calorias queimadas.';

  @override
  String get selectActivityFirst => 'Selecione uma atividade primeiro.';

  @override
  String get customActivity => 'Atividade personalizada';

  @override
  String get actWalking => 'Caminhada';

  @override
  String get actRunning => 'Corrida';

  @override
  String get actCycling => 'Ciclismo';

  @override
  String get actSwimming => 'Natação';

  @override
  String get actWeightTraining => 'Musculação';

  @override
  String get actYoga => 'Ioga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Trilha';

  @override
  String get mealBreakfast => 'Café da manhã';

  @override
  String get mealLunch => 'Almoço';

  @override
  String get mealDinner => 'Jantar';

  @override
  String get mealSnack => 'Lanche';

  @override
  String get deleteEntryTitle => 'Excluir item?';

  @override
  String deleteEntryBody(String name, String meal) {
    return 'Remover \"$name\" de $meal?';
  }

  @override
  String get holdToEdit => 'segure para editar';

  @override
  String get servingSizeLabel => 'Tamanho da porção';

  @override
  String get addFoodTitle => 'Adicionar comida';

  @override
  String get pickIngredientTitle => 'Escolher ingrediente';

  @override
  String get tabSearch => 'Buscar';

  @override
  String get tabRecentFav => 'Recentes e favoritos';

  @override
  String get tabRecipes => 'Receitas';

  @override
  String get tabMyFoods => 'Meus alimentos';

  @override
  String get searchHint => 'Buscar alimentos…';

  @override
  String get scanTooltip => 'Escanear código de barras';

  @override
  String noResults(String query) {
    return 'Nenhum resultado para \"$query\".\nTente um termo mais específico ou escaneie o código de barras.';
  }

  @override
  String searchErrorRetry(String error) {
    return '$error\nPuxe para baixo para tentar de novo.';
  }

  @override
  String get createCustomFood => 'Criar alimento personalizado';

  @override
  String get sectionFavourites => 'Favoritos ⭐';

  @override
  String get sectionRecent => 'Recentes';

  @override
  String get noFoodsYet => 'Ainda sem alimentos.';

  @override
  String get unlockScannerTitle => 'Desbloquear leitor de código de barras';

  @override
  String get unlockScannerBody =>
      'Assista a um anúncio curto para desbloquear o leitor de código de barras pelo resto do dia.';

  @override
  String get watchAd => 'Assistir anúncio';

  @override
  String get adUnavailable =>
      'Anúncio indisponível agora. Tente novamente em instantes.';

  @override
  String get productNotFound => 'Produto não encontrado no banco de dados.';

  @override
  String get createNewRecipe => 'Criar nova receita';

  @override
  String get noRecipesYet =>
      'Ainda sem receitas.\nToque em \"Criar nova receita\" para começar.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porções',
      one: '1 porção',
    );
    return '$kcal kcal/porção  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '$kcal kcal por porção';
  }

  @override
  String get servingsToLog => 'Porções a registrar';

  @override
  String get createRecipeTitle => 'Criar receita';

  @override
  String get editRecipeTitle => 'Editar receita';

  @override
  String get recipeNameLabel => 'Nome da receita';

  @override
  String get recipeNameRequired => 'O nome da receita é obrigatório.';

  @override
  String get recipeDescLabel => 'Descrição (opcional)';

  @override
  String get servingsLabel => 'Porções';

  @override
  String get ingredients => 'Ingredientes';

  @override
  String get addAtLeastOne => 'Adicione pelo menos um ingrediente.';

  @override
  String get noIngredientsYet => 'Ainda sem ingredientes.';

  @override
  String get nutritionSummary => 'Resumo nutricional';

  @override
  String get total => 'Total';

  @override
  String get perServing => 'Por porção';

  @override
  String perServingCount(int count) {
    return 'Por porção ($count porções)';
  }

  @override
  String get createCustomFoodTitle => 'Criar alimento personalizado';

  @override
  String get foodDetailsSection => 'Detalhes do alimento';

  @override
  String get valuesPer100 => 'Os valores são por 100 g / 100 ml.';

  @override
  String get foodNameLabel => 'Nome do alimento';

  @override
  String get brandOptional => 'Marca (opcional)';

  @override
  String get nutritionPer100 => 'Nutrição por 100 g';

  @override
  String get fieldRequired => 'Obrigatório';

  @override
  String get enterValidNumber => 'Insira um número válido';

  @override
  String get saveAndLog => 'Salvar e registrar porção';

  @override
  String get removeFavourite => 'Remover dos favoritos';

  @override
  String get addToFavourites => 'Adicionar aos favoritos';

  @override
  String get servingSizeG => 'Tamanho da porção (g)';

  @override
  String get addToLabel => 'Adicionar a';

  @override
  String addToMeal(String meal) {
    return 'Adicionar a $meal';
  }

  @override
  String get scanBarcodeTitle => 'Escanear código de barras';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get noLoggedDays => 'Ainda sem dias registrados.';

  @override
  String get today => 'Hoje';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => 'Análises semanais';

  @override
  String get premiumFeature => 'Recurso Premium';

  @override
  String get upgradeToPremium => 'Assinar o Premium';

  @override
  String get sevenDayAverage => 'Média de 7 dias';

  @override
  String kcalAvg(int n) {
    return '$n kcal méd.';
  }

  @override
  String get kcalAvgEmpty => '— kcal méd.';

  @override
  String get weightTrend => 'Tendência de peso';

  @override
  String get prevMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Próximo mês';

  @override
  String get shareDayTitle => 'Compartilhe seu dia';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => 'Meta batida!';

  @override
  String ofGoal(int n) {
    return 'de $n meta';
  }

  @override
  String get trackedWith => 'registrado com PlateSimple';

  @override
  String get preparing => 'Preparando…';

  @override
  String get share => 'Compartilhar';

  @override
  String shareText(String url) {
    return 'Minha nutrição hoje — registrada com PlateSimple 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle => 'Desbloqueie a experiência completa';

  @override
  String get featInsightsTitle => 'Análises semanais (7 dias)';

  @override
  String get featInsightsSub =>
      'Veja seu gráfico de calorias e a média de 7 dias num relance.';

  @override
  String get featAdFreeTitle => 'Sem anúncios';

  @override
  String get featAdFreeSub => 'Sem anúncios intersticiais ou premiados. Nunca.';

  @override
  String get featSupportTitle => 'Apoie um desenvolvedor solo';

  @override
  String get featSupportSub =>
      'O PlateSimple é criado e mantido por uma só pessoa. Sua assinatura o mantém funcionando.';

  @override
  String get loadPricingError =>
      'Não foi possível carregar os preços.\nVerifique sua conexão e tente de novo.';

  @override
  String get choosePlan => 'Escolha um plano';

  @override
  String get alreadyPremium => 'Você já é Premium ✓';

  @override
  String get subscribe => 'Assinar';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get privacyPolicy => 'Privacidade';

  @override
  String get termsOfUse => 'Termos de uso';

  @override
  String get subsRenew =>
      'As assinaturas são renovadas automaticamente. Cancele quando quiser nos ajustes do dispositivo.';

  @override
  String get premiumRestored => 'Premium restaurado com sucesso!';

  @override
  String get noSubFound => 'Nenhuma assinatura ativa encontrada.';

  @override
  String get planYearly => 'Anual';

  @override
  String get planMonthly => 'Mensal';

  @override
  String get bestValue => 'MELHOR VALOR';

  @override
  String get billedYearly => 'Cobrado uma vez por ano';

  @override
  String get billedMonthly => 'Cobrado mensalmente';

  @override
  String get legendUnder => 'Abaixo';

  @override
  String get legendOnTarget => 'Na meta';

  @override
  String get legendOver => 'Acima';

  @override
  String get notifTitle => 'Hora de registrar suas refeições 🥗';

  @override
  String get notifBody =>
      'Mantenha sua sequência — registre o que você comeu hoje!';

  @override
  String get notifChannelName => 'Lembretes diários';

  @override
  String get notifChannelDesc =>
      'Lembra você de registrar suas refeições todos os dias';
}
