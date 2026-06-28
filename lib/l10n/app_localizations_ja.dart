// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get update => '更新';

  @override
  String get reset => 'リセット';

  @override
  String get remove => '削除';

  @override
  String get edit => '編集';

  @override
  String get add => '追加';

  @override
  String get logAction => '記録';

  @override
  String get getStarted => 'はじめる';

  @override
  String get continueLabel => '次へ';

  @override
  String get letsGo => 'はじめましょう！';

  @override
  String get skipForNow => '今はスキップ';

  @override
  String get openSettings => '設定を開く';

  @override
  String get tryAgain => '再試行';

  @override
  String get navToday => '今日';

  @override
  String get navHistory => '履歴';

  @override
  String get navGoals => '目標';

  @override
  String get macroCalories => 'カロリー';

  @override
  String get macroProtein => 'たんぱく質';

  @override
  String get macroCarbs => '炭水化物';

  @override
  String get macroFat => '脂質';

  @override
  String get fieldCalories => 'カロリー';

  @override
  String get fieldProtein => 'たんぱく質';

  @override
  String get fieldCarbohydrates => '炭水化物';

  @override
  String get fieldFat => '脂質';

  @override
  String get fieldDailyCalories => '1日のカロリー';

  @override
  String get fieldProteinPct => 'たんぱく質 %';

  @override
  String get fieldCarbsPct => '炭水化物 %';

  @override
  String get fieldFatPct => '脂質 %';

  @override
  String get calculatedCalories => '計算されたカロリー';

  @override
  String get goalModeManual => '手動';

  @override
  String get goalModePercent => '% → マクロ';

  @override
  String get goalModeMacros => 'マクロ → kcal';

  @override
  String get goalModeManualDesc => 'カロリーとマクロのグラム数を直接入力します。';

  @override
  String get goalModePercentDesc => '合計カロリーと%配分を入力すると、グラム数がリアルタイムで計算されます。';

  @override
  String get goalModeMacrosDesc => 'マクロのグラム数を入力すると、合計カロリーがリアルタイムで計算されます。';

  @override
  String get pctTotalOk => '合計が100%です ✓';

  @override
  String pctTotalOff(int sum) {
    return '合計が$sum%です（100%にしてください）';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → たんぱく質 $grams g';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → 炭水化物 $grams g';
  }

  @override
  String pctHintFat(int grams) {
    return '  → 脂質 $grams g';
  }

  @override
  String get welcomeTitle => 'PlateSimpleへようこそ';

  @override
  String get welcomeSubtitle => '速くてすっきりしたカロリー記録。\n無料のバーコードスキャン。余計なものなし。';

  @override
  String get onbSetGoalsTitle => '1日の目標を設定';

  @override
  String get onbSetGoalsSubtitle => '目標はいつでも変更できます。';

  @override
  String get onbStayOnTrackTitle => '継続しよう';

  @override
  String get onbStayOnTrackBody => '通知を許可すると、食事の記録をお知らせして連続記録を維持できます。';

  @override
  String get goalsDailyTargets => '1日の栄養目標';

  @override
  String get goalsChooseHow => '目標の設定方法を選んでください。';

  @override
  String get goalsCalcTdee => 'TDEE / BMI で計算';

  @override
  String get goalsSaveBtn => '目標を保存';

  @override
  String get goalsSavedSnack => '目標を保存しました！';

  @override
  String get waterTrackingTitle => '水分記録';

  @override
  String get waterTrackingSubtitle => 'ホーム画面で1日の水分摂取を記録します。';

  @override
  String get waterShowTracker => '水分トラッカーを表示';

  @override
  String get waterShowTrackerSub => '「今日」画面に水分カードを表示します';

  @override
  String get waterDailyGoal => '1日の目標';

  @override
  String get waterGlassesUnit => '杯';

  @override
  String get water => '水分';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal 杯';
  }

  @override
  String get resetWaterTitle => '水分をリセットしますか？';

  @override
  String get resetWaterBody => '今日の水分カウントを0に戻しますか？';

  @override
  String get reminderTitle => '毎日のリマインダー';

  @override
  String get reminderSubtitle => '食事の記録を毎日お知らせします。';

  @override
  String get reminderEnable => 'リマインダーを有効化';

  @override
  String get reminderEnableSub => '毎日通知を送ります';

  @override
  String get reminderTimeLabel => 'リマインダーの時刻';

  @override
  String get feedbackTitle => 'フィードバック';

  @override
  String get feedbackBody =>
      '個人開発者です。あなたのフィードバックがPlateSimpleの改善に役立ちます。1分もかかりません！';

  @override
  String get feedbackShare => 'フィードバックを送る';

  @override
  String get dataExportTitle => 'データのエクスポート';

  @override
  String get dataExportSubtitle => '食事ログ・体重・アクティビティをエクスポートします。';

  @override
  String get exportCsv => 'CSVでエクスポート';

  @override
  String get exportCsvSub => '表計算ソフト対応の形式';

  @override
  String get exportJson => 'JSONでエクスポート';

  @override
  String get exportJsonSub => '完全バックアップ';

  @override
  String get aboutTitle => 'PlateSimpleについて';

  @override
  String get premiumBannerUpgradeTitle => 'プレミアムにアップグレード';

  @override
  String get premiumBannerMemberTitle => 'あなたはプレミアム会員です';

  @override
  String get premiumBannerUpgradeSub => '週間インサイト・広告なし・開発者を応援';

  @override
  String get premiumBannerMemberSub => '週間インサイト解放・広告なし';

  @override
  String get tdeeTitle => 'TDEE計算機';

  @override
  String get tdeeSubtitle => '情報を入力して総消費カロリーを計算し、カロリー目標を自動設定します。';

  @override
  String get sexMale => '男性';

  @override
  String get sexFemale => '女性';

  @override
  String get fieldAge => '年齢';

  @override
  String get fieldHeight => '身長';

  @override
  String get fieldWeight => '体重';

  @override
  String get unitYears => '歳';

  @override
  String get activityLevelLabel => '活動レベル';

  @override
  String get goalLabel => '目標';

  @override
  String get calculate => '計算';

  @override
  String get tdeeInvalid => 'すべての項目に有効な値を入力してください。';

  @override
  String get yourResults => '結果';

  @override
  String get bmrLabel => 'BMR（基礎代謝量）';

  @override
  String get tdeeMaintenance => 'TDEE（維持）';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get suggestedGoals => '推奨目標';

  @override
  String get applyGoals => 'この目標を適用';

  @override
  String get tdeeAppliedSnack => 'TDEE計算機から目標を更新しました！';

  @override
  String get activitySedentary => '座りがち（運動ほぼなし）';

  @override
  String get activityLight => '軽い活動（週1〜3日）';

  @override
  String get activityModerate => '中程度の活動（週3〜5日）';

  @override
  String get activityVery => '活発（週6〜7日）';

  @override
  String get activityExtra => '非常に活発（肉体労働＋トレーニング）';

  @override
  String get goalLose => '減量';

  @override
  String get goalMaintain => '体重維持';

  @override
  String get goalGain => '増量';

  @override
  String get bmiUnderweight => '低体重';

  @override
  String get bmiNormal => '標準体重';

  @override
  String get bmiOverweight => '過体重';

  @override
  String get bmiObese => '肥満';

  @override
  String get todayShareTooltip => '今日をシェア';

  @override
  String get todayCopyTooltip => '昨日の食事をコピー';

  @override
  String get logFood => '食事を記録';

  @override
  String get emptyTodayTitle => '今日はまだ記録がありません';

  @override
  String get emptyTodayBody => '最初の食事を記録して、カロリーとマクロの管理を始めましょう。';

  @override
  String get copyYesterdayTitle => '昨日をコピーしますか？';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '昨日の$count件を今日にコピーしますか？',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => '昨日は記録がありません。';

  @override
  String get copyAction => 'コピー';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '昨日の$count件をコピーしました。',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal 摂取';

  @override
  String get netKcal => '正味 kcal';

  @override
  String kcalLeft(int n) {
    return '残り $n';
  }

  @override
  String kcalOver(int n) {
    return '$n オーバー';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n 消費';
  }

  @override
  String get bodyWeight => '体重';

  @override
  String get notLoggedToday => '今日は未記録';

  @override
  String get logWeight => '体重を記録';

  @override
  String get weightInvalid => '有効な体重を入力してください。';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg kg  ·  今日記録';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg kg  ·  $date 記録';
  }

  @override
  String get healthSync => 'ヘルス同期';

  @override
  String get healthConnectApple => 'Appleヘルスを連携して、消費カロリーを取り込み、栄養データを同期します。';

  @override
  String get healthConnectGoogle =>
      'Google Health Connectを連携して、消費カロリーを取り込み、栄養データを同期します。';

  @override
  String get connectHealth => 'ヘルスを連携';

  @override
  String get healthDeniedIos =>
      '設定 → プライバシーとセキュリティ → ヘルスケア → PlateSimple でアクセスを許可してください。';

  @override
  String get healthDeniedAndroid =>
      'Health Connectを開いてPlateSimpleに権限を付与してください。';

  @override
  String get statSteps => '歩数';

  @override
  String get statBurned => '消費';

  @override
  String get syncNutrition => '栄養をヘルスに同期';

  @override
  String get healthSynced => '栄養をヘルスに同期しました！';

  @override
  String get healthWriteFailed => 'ヘルスに書き込めませんでした。';

  @override
  String get healthNotGranted => 'ヘルスのアクセスが許可されていません。権限を確認してください。';

  @override
  String get activity => 'アクティビティ';

  @override
  String get noActivityToday => '今日のアクティビティ記録はありません。';

  @override
  String get addActivity => 'アクティビティを追加';

  @override
  String get logActivityTitle => 'アクティビティを記録';

  @override
  String get presets => 'プリセット';

  @override
  String get manual => '手動';

  @override
  String get activityNameLabel => 'アクティビティ名';

  @override
  String get activityNameHint => '例：サッカー、ダンス…';

  @override
  String get caloriesBurnedLabel => '消費カロリー';

  @override
  String get durationLabel => '時間';

  @override
  String estimatedBurned(int n) {
    return '推定：約 $n kcal 消費';
  }

  @override
  String get enterValidDuration => '有効な時間を入力してください。';

  @override
  String get enterCaloriesBurned => '消費カロリーを入力してください。';

  @override
  String get selectActivityFirst => '先にアクティビティを選択してください。';

  @override
  String get customActivity => 'カスタムアクティビティ';

  @override
  String get actWalking => 'ウォーキング';

  @override
  String get actRunning => 'ランニング';

  @override
  String get actCycling => 'サイクリング';

  @override
  String get actSwimming => '水泳';

  @override
  String get actWeightTraining => '筋トレ';

  @override
  String get actYoga => 'ヨガ';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'ハイキング';

  @override
  String get mealBreakfast => '朝食';

  @override
  String get mealLunch => '昼食';

  @override
  String get mealDinner => '夕食';

  @override
  String get mealSnack => '間食';

  @override
  String get deleteEntryTitle => '項目を削除しますか？';

  @override
  String deleteEntryBody(String name, String meal) {
    return '$mealから「$name」を削除しますか？';
  }

  @override
  String get holdToEdit => '長押しで編集';

  @override
  String get servingSizeLabel => '分量';

  @override
  String get addFoodTitle => '食事を追加';

  @override
  String get pickIngredientTitle => '材料を選択';

  @override
  String get tabSearch => '検索';

  @override
  String get tabRecentFav => '最近・お気に入り';

  @override
  String get tabRecipes => 'レシピ';

  @override
  String get tabMyFoods => 'マイ食品';

  @override
  String get searchHint => '食品を検索…';

  @override
  String get scanTooltip => 'バーコードをスキャン';

  @override
  String noResults(String query) {
    return '「$query」の結果がありません。\nより具体的な語句を試すか、バーコードをスキャンしてください。';
  }

  @override
  String searchErrorRetry(String error) {
    return '$error\n下に引っ張って再試行してください。';
  }

  @override
  String get createCustomFood => 'カスタム食品を作成';

  @override
  String get sectionFavourites => 'お気に入り ⭐';

  @override
  String get sectionRecent => '最近';

  @override
  String get noFoodsYet => 'まだ食品がありません。';

  @override
  String get unlockScannerTitle => 'バーコードスキャナーを解除';

  @override
  String get unlockScannerBody => '短い広告を見ると、その日の残りの時間バーコードスキャナーが使えます。';

  @override
  String get watchAd => '広告を見る';

  @override
  String get adUnavailable => '現在広告を利用できません。少し後でお試しください。';

  @override
  String get productNotFound => 'データベースに製品が見つかりません。';

  @override
  String get createNewRecipe => '新しいレシピを作成';

  @override
  String get noRecipesYet => 'まだレシピがありません。\n「新しいレシピを作成」をタップして始めましょう。';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count食分',
    );
    return '$kcal kcal/1食分  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return '1食分あたり $kcal kcal';
  }

  @override
  String get servingsToLog => '記録する食数';

  @override
  String get createRecipeTitle => 'レシピを作成';

  @override
  String get editRecipeTitle => 'レシピを編集';

  @override
  String get recipeNameLabel => 'レシピ名';

  @override
  String get recipeNameRequired => 'レシピ名は必須です。';

  @override
  String get recipeDescLabel => '説明（任意）';

  @override
  String get servingsLabel => '食数';

  @override
  String get ingredients => '材料';

  @override
  String get addAtLeastOne => '材料を1つ以上追加してください。';

  @override
  String get noIngredientsYet => 'まだ材料がありません。';

  @override
  String get nutritionSummary => '栄養サマリー';

  @override
  String get total => '合計';

  @override
  String get perServing => '1食分あたり';

  @override
  String perServingCount(int count) {
    return '1食分あたり（$count食分）';
  }

  @override
  String get createCustomFoodTitle => 'カスタム食品を作成';

  @override
  String get foodDetailsSection => '食品の詳細';

  @override
  String get valuesPer100 => '値は100g/100mlあたりです。';

  @override
  String get foodNameLabel => '食品名';

  @override
  String get brandOptional => 'ブランド（任意）';

  @override
  String get nutritionPer100 => '100gあたりの栄養';

  @override
  String get fieldRequired => '必須';

  @override
  String get enterValidNumber => '有効な数値を入力してください';

  @override
  String get saveAndLog => '保存して分量を記録';

  @override
  String get removeFavourite => 'お気に入りから削除';

  @override
  String get addToFavourites => 'お気に入りに追加';

  @override
  String get servingSizeG => '分量（g）';

  @override
  String get addToLabel => '追加先';

  @override
  String addToMeal(String meal) {
    return '$mealに追加';
  }

  @override
  String get scanBarcodeTitle => 'バーコードをスキャン';

  @override
  String get historyTitle => '履歴';

  @override
  String get noLoggedDays => 'まだ記録した日がありません。';

  @override
  String get today => '今日';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => '週間インサイト';

  @override
  String get premiumFeature => 'プレミアム機能';

  @override
  String get upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get sevenDayAverage => '7日間の平均';

  @override
  String kcalAvg(int n) {
    return '平均 $n kcal';
  }

  @override
  String get kcalAvgEmpty => '平均 — kcal';

  @override
  String get weightTrend => '体重の推移';

  @override
  String get prevMonth => '前の月';

  @override
  String get nextMonth => '次の月';

  @override
  String get shareDayTitle => '今日をシェア';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => '目標達成！';

  @override
  String ofGoal(int n) {
    return '目標 $n 中';
  }

  @override
  String get trackedWith => 'PlateSimpleで記録';

  @override
  String get preparing => '準備中…';

  @override
  String get share => 'シェア';

  @override
  String shareText(String url) {
    return '今日の栄養 — PlateSimpleで記録 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple プレミアム';

  @override
  String get premiumSubtitle => 'すべての機能を解放';

  @override
  String get featInsightsTitle => '週間インサイト（7日間）';

  @override
  String get featInsightsSub => 'カロリーの推移グラフと7日間の平均をひと目で確認。';

  @override
  String get featAdFreeTitle => '広告なし';

  @override
  String get featAdFreeSub => 'インタースティシャル広告もリワード広告も一切なし。';

  @override
  String get featSupportTitle => '個人開発者を応援';

  @override
  String get featSupportSub => 'PlateSimpleは一人で開発・運営しています。あなたの登録が継続を支えます。';

  @override
  String get loadPricingError => '価格を読み込めませんでした。\n接続を確認して再試行してください。';

  @override
  String get choosePlan => 'プランを選択';

  @override
  String get alreadyPremium => 'すでにプレミアムです ✓';

  @override
  String get subscribe => '登録する';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfUse => '利用規約';

  @override
  String get subsRenew => 'サブスクリプションは自動更新されます。デバイスの設定でいつでもキャンセルできます。';

  @override
  String get premiumRestored => 'プレミアムを復元しました！';

  @override
  String get noSubFound => '有効なサブスクリプションが見つかりません。';

  @override
  String get planYearly => '年額';

  @override
  String get planMonthly => '月額';

  @override
  String get bestValue => 'おトク';

  @override
  String get billedYearly => '年1回の請求';

  @override
  String get billedMonthly => '毎月の請求';

  @override
  String get legendUnder => '不足';

  @override
  String get legendOnTarget => '目標どおり';

  @override
  String get legendOver => '超過';

  @override
  String get notifTitle => '食事を記録する時間です 🥗';

  @override
  String get notifBody => '連続記録を続けよう — 今日食べたものを記録しましょう！';

  @override
  String get notifChannelName => '毎日のリマインダー';

  @override
  String get notifChannelDesc => '毎日、食事の記録をお知らせします';
}
