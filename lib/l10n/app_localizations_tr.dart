// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'PlateSimple';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get update => 'Güncelle';

  @override
  String get reset => 'Sıfırla';

  @override
  String get remove => 'Kaldır';

  @override
  String get edit => 'Düzenle';

  @override
  String get add => 'Ekle';

  @override
  String get logAction => 'Kaydet';

  @override
  String get getStarted => 'Başla';

  @override
  String get continueLabel => 'Devam';

  @override
  String get letsGo => 'Hadi başlayalım!';

  @override
  String get skipForNow => 'Şimdilik atla';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get navToday => 'Bugün';

  @override
  String get navHistory => 'Geçmiş';

  @override
  String get navGoals => 'Hedefler';

  @override
  String get macroCalories => 'Kalori';

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarbs => 'Karb.';

  @override
  String get macroFat => 'Yağ';

  @override
  String get fieldCalories => 'Kalori';

  @override
  String get fieldProtein => 'Protein';

  @override
  String get fieldCarbohydrates => 'Karbonhidrat';

  @override
  String get fieldFat => 'Yağ';

  @override
  String get fieldDailyCalories => 'Günlük kalori';

  @override
  String get fieldProteinPct => 'Protein %';

  @override
  String get fieldCarbsPct => 'Karbonhidrat %';

  @override
  String get fieldFatPct => 'Yağ %';

  @override
  String get calculatedCalories => 'Hesaplanan kalori';

  @override
  String get goalModeManual => 'Manuel';

  @override
  String get goalModePercent => '% → Makrolar';

  @override
  String get goalModeMacros => 'Makrolar → kcal';

  @override
  String get goalModeManualDesc => 'Kalori ve makro gramlarını doğrudan gir.';

  @override
  String get goalModePercentDesc =>
      'Toplam kaloriyi ve yüzde dağılımını gir, gramlar anında hesaplanır.';

  @override
  String get goalModeMacrosDesc =>
      'Makro gramlarını gir, toplam kalori anında hesaplanır.';

  @override
  String get pctTotalOk => 'Yüzdelerin toplamı %100 ✓';

  @override
  String pctTotalOff(int sum) {
    return 'Yüzdelerin toplamı %$sum (%100 olmalı)';
  }

  @override
  String pctHintProtein(int grams) {
    return '  → $grams g protein';
  }

  @override
  String pctHintCarbs(int grams) {
    return '  → $grams g karbonhidrat';
  }

  @override
  String pctHintFat(int grams) {
    return '  → $grams g yağ';
  }

  @override
  String get welcomeTitle => 'PlateSimple\'a hoş geldin';

  @override
  String get welcomeSubtitle =>
      'Hızlı ve sade kalori takibi.\nÜcretsiz barkod tarama. Gereksiz kalabalık yok.';

  @override
  String get onbSetGoalsTitle => 'Günlük hedeflerini belirle';

  @override
  String get onbSetGoalsSubtitle =>
      'Bunları istediğin zaman Hedefler bölümünden değiştirebilirsin.';

  @override
  String get onbStayOnTrackTitle => 'Düzenini koru';

  @override
  String get onbStayOnTrackBody =>
      'Öğünlerini kaydetmeyi hatırlatabilmemiz ve serini koruyabilmen için bildirimlere izin ver.';

  @override
  String get goalsDailyTargets => 'Günlük beslenme hedefleri';

  @override
  String get goalsChooseHow => 'Hedeflerini nasıl belirlemek istediğini seç.';

  @override
  String get goalsCalcTdee => 'TDEE / BMI ile hesapla';

  @override
  String get goalsSaveBtn => 'Hedefleri kaydet';

  @override
  String get goalsSavedSnack => 'Hedefler kaydedildi!';

  @override
  String get waterTrackingTitle => 'Su takibi';

  @override
  String get waterTrackingSubtitle =>
      'Günlük su tüketimini ana ekranda takip et.';

  @override
  String get waterShowTracker => 'Su takibini göster';

  @override
  String get waterShowTrackerSub => 'Bugün ekranında su kartını gösterir';

  @override
  String get waterDailyGoal => 'Günlük hedef';

  @override
  String get waterGlassesUnit => 'bardak';

  @override
  String get water => 'Su';

  @override
  String waterCount(int glasses, int goal) {
    return '$glasses / $goal bardak';
  }

  @override
  String get resetWaterTitle => 'Su sıfırlansın mı?';

  @override
  String get resetWaterBody => 'Bugünkü su sayısı 0\'a döndürülsün mü?';

  @override
  String get reminderTitle => 'Günlük hatırlatıcı';

  @override
  String get reminderSubtitle =>
      'Öğünlerini kaydetmen için günlük küçük bir hatırlatma al.';

  @override
  String get reminderEnable => 'Hatırlatıcıyı aç';

  @override
  String get reminderEnableSub => 'Günlük bildirim gönderir';

  @override
  String get reminderTimeLabel => 'Hatırlatma saati';

  @override
  String get feedbackTitle => 'Geri bildirim';

  @override
  String get feedbackBody =>
      'Ben bağımsız bir geliştiriciyim ve geri bildirimin PlateSimple\'ı daha iyi yapmama yardımcı oluyor. Bir dakikadan az sürer!';

  @override
  String get feedbackShare => 'Geri bildirim gönder';

  @override
  String get rateApp => 'PlateSimple\'ı değerlendir';

  @override
  String get rateAppSub =>
      'Bir yorum, başkalarının PlateSimple\'ı bulmasına yardımcı olur';

  @override
  String get dataExportTitle => 'Veri dışa aktarma';

  @override
  String get dataExportSubtitle =>
      'Yemek kaydını, kilo ve aktivite verilerini dışa aktar.';

  @override
  String get exportCsv => 'CSV olarak dışa aktar';

  @override
  String get exportCsvSub => 'Elektronik tabloyla uyumlu biçim';

  @override
  String get exportJson => 'JSON olarak dışa aktar';

  @override
  String get exportJsonSub => 'Tam veri yedeği';

  @override
  String get aboutTitle => 'PlateSimple hakkında';

  @override
  String get premiumBannerUpgradeTitle => 'Premium\'a geç';

  @override
  String get premiumBannerMemberTitle => 'Premium üyesisin';

  @override
  String get premiumBannerUpgradeSub =>
      'Haftalık analizler · Kilo trendi · Sağlık senkronu · Reklamsız';

  @override
  String get premiumBannerMemberSub =>
      'Haftalık analizler · Kilo trendi · Sağlık senkronu · Reklamsız';

  @override
  String get tdeeTitle => 'TDEE hesaplayıcı';

  @override
  String get tdeeSubtitle =>
      'Toplam Günlük Enerji Harcamanı (TDEE) hesaplamak ve kalori hedefini otomatik ayarlamak için bilgilerini gir.';

  @override
  String get sexMale => 'Erkek';

  @override
  String get sexFemale => 'Kadın';

  @override
  String get fieldAge => 'Yaş';

  @override
  String get fieldHeight => 'Boy';

  @override
  String get fieldWeight => 'Kilo';

  @override
  String get unitYears => 'yıl';

  @override
  String get activityLevelLabel => 'Aktivite düzeyi';

  @override
  String get goalLabel => 'Hedef';

  @override
  String get calculate => 'Hesapla';

  @override
  String get tdeeInvalid => 'Lütfen tüm alanlara geçerli değerler gir.';

  @override
  String get yourResults => 'Sonuçların';

  @override
  String get bmrLabel => 'BMR (bazal metabolizma hızı)';

  @override
  String get tdeeMaintenance => 'TDEE (koruma)';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get suggestedGoals => 'Önerilen hedefler';

  @override
  String get applyGoals => 'Bu hedefleri uygula';

  @override
  String get tdeeAppliedSnack => 'Hedefler TDEE hesaplayıcıdan güncellendi!';

  @override
  String get activitySedentary => 'Hareketsiz (az veya hiç egzersiz yok)';

  @override
  String get activityLight => 'Hafif aktif (haftada 1–3 gün)';

  @override
  String get activityModerate => 'Orta derecede aktif (haftada 3–5 gün)';

  @override
  String get activityVery => 'Çok aktif (haftada 6–7 gün)';

  @override
  String get activityExtra => 'Son derece aktif (fiziksel iş + antrenman)';

  @override
  String get goalLose => 'Kilo ver';

  @override
  String get goalMaintain => 'Kiloyu koru';

  @override
  String get goalGain => 'Kilo al';

  @override
  String get bmiUnderweight => 'Zayıf';

  @override
  String get bmiNormal => 'Normal kilo';

  @override
  String get bmiOverweight => 'Fazla kilolu';

  @override
  String get bmiObese => 'Obez';

  @override
  String get todayShareTooltip => 'Gününü paylaş';

  @override
  String get todayCopyTooltip => 'Dünkü öğünleri kopyala';

  @override
  String get logFood => 'Yemek kaydet';

  @override
  String get emptyTodayTitle => 'Bugün henüz bir şey kaydedilmedi';

  @override
  String get emptyTodayBody =>
      'Kalori ve makro takibine başlamak için ilk öğününü kaydet.';

  @override
  String get copyYesterdayTitle => 'Dün kopyalansın mı?';

  @override
  String copyYesterdayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dünden bugüne $count öğe kopyalansın mı?',
      one: 'Dünden bugüne 1 öğe kopyalansın mı?',
    );
    return '$_temp0';
  }

  @override
  String get copyYesterdayNone => 'Dün hiç kayıt yapılmadı.';

  @override
  String get copyAction => 'Kopyala';

  @override
  String copiedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dünden $count öğe kopyalandı.',
      one: 'Dünden 1 öğe kopyalandı.',
    );
    return '$_temp0';
  }

  @override
  String get kcalEaten => 'kcal alındı';

  @override
  String get netKcal => 'net kcal';

  @override
  String kcalLeft(int n) {
    return '$n kaldı';
  }

  @override
  String kcalOver(int n) {
    return '$n fazla';
  }

  @override
  String kcalBurnedLine(int n) {
    return '−$n yakıldı';
  }

  @override
  String get bodyWeight => 'Vücut kilosu';

  @override
  String get notLoggedToday => 'Bugün kaydedilmedi';

  @override
  String get logWeight => 'Kilo kaydet';

  @override
  String get weightInvalid => 'Geçerli bir kilo gir.';

  @override
  String weightSubtitleToday(String kg) {
    return '$kg  ·  bugün kaydedildi';
  }

  @override
  String weightSubtitleDate(String kg, String date) {
    return '$kg  ·  kaydedildi: $date';
  }

  @override
  String get healthSync => 'Sağlık senkronu';

  @override
  String get healthConnectApple =>
      'Yakılan kalorileri almak ve beslenme verilerini senkronize etmek için Apple Health\'i bağla.';

  @override
  String get healthConnectGoogle =>
      'Yakılan kalorileri almak ve beslenme verilerini senkronize etmek için Health Connect\'i bağla.';

  @override
  String get connectHealth => 'Sağlık\'ı bağla';

  @override
  String get healthDeniedIos =>
      'Erişim vermek için Ayarlar → Gizlilik ve Güvenlik → Sağlık → PlateSimple yolunu izle.';

  @override
  String get healthDeniedAndroid =>
      'Health Connect\'i açıp PlateSimple\'a izin ver.';

  @override
  String get statSteps => 'Adım';

  @override
  String get statBurned => 'Yakılan';

  @override
  String get syncNutrition => 'Beslenmeyi Sağlık\'a senkronize et';

  @override
  String get healthSynced => 'Beslenme verileri Sağlık\'a senkronize edildi!';

  @override
  String get healthWriteFailed => 'Sağlık\'a yazılamadı.';

  @override
  String get healthNotGranted =>
      'Sağlık erişimi verilmedi. İzinleri kontrol et.';

  @override
  String get activity => 'Aktivite';

  @override
  String get noActivityToday => 'Bugün aktivite kaydedilmedi.';

  @override
  String get addActivity => 'Aktivite ekle';

  @override
  String get logActivityTitle => 'Aktivite kaydet';

  @override
  String get presets => 'Hazır seçenekler';

  @override
  String get manual => 'Manuel';

  @override
  String get activityNameLabel => 'Aktivite adı';

  @override
  String get activityNameHint => 'ör. Futbol, Dans…';

  @override
  String get caloriesBurnedLabel => 'Yakılan kalori';

  @override
  String get durationLabel => 'Süre';

  @override
  String estimatedBurned(int n) {
    return 'Tahmini: ~$n kcal yakıldı';
  }

  @override
  String get enterValidDuration => 'Geçerli bir süre gir.';

  @override
  String get enterCaloriesBurned => 'Yakılan kaloriyi gir.';

  @override
  String get selectActivityFirst => 'Önce bir aktivite seç.';

  @override
  String get customActivity => 'Özel aktivite';

  @override
  String get actWalking => 'Yürüyüş';

  @override
  String get actRunning => 'Koşu';

  @override
  String get actCycling => 'Bisiklet';

  @override
  String get actSwimming => 'Yüzme';

  @override
  String get actWeightTraining => 'Ağırlık antrenmanı';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actHIIT => 'HIIT';

  @override
  String get actHiking => 'Doğa yürüyüşü';

  @override
  String get mealBreakfast => 'Kahvaltı';

  @override
  String get mealLunch => 'Öğle yemeği';

  @override
  String get mealDinner => 'Akşam yemeği';

  @override
  String get mealSnack => 'Ara öğün';

  @override
  String get deleteEntryTitle => 'Kayıt silinsin mi?';

  @override
  String deleteEntryBody(String name, String meal) {
    return '\"$name\" kaldırılsın mı? (Öğün: $meal)';
  }

  @override
  String get tapToEdit => 'düzenlemek için dokun';

  @override
  String get servingSizeLabel => 'Porsiyon boyutu';

  @override
  String get addFoodTitle => 'Yemek ekle';

  @override
  String get pickIngredientTitle => 'Malzeme seç';

  @override
  String get tabSearch => 'Ara';

  @override
  String get tabRecentFav => 'Son ve Favoriler';

  @override
  String get tabRecipes => 'Tarifler';

  @override
  String get tabMyFoods => 'Yemeklerim';

  @override
  String get searchHint => 'Yemek ara…';

  @override
  String get scanTooltip => 'Barkod tara';

  @override
  String get createCustomFood => 'Özel yemek oluştur';

  @override
  String get sectionFavourites => 'Favoriler ⭐';

  @override
  String get sectionRecent => 'Son kullanılanlar';

  @override
  String get noFoodsYet => 'Henüz yemek yok.';

  @override
  String get unlockScannerTitle => 'Barkod tarayıcının kilidini aç';

  @override
  String get unlockScannerBody =>
      'Barkod tarayıcının kilidini günün geri kalanı için açmak üzere kısa bir reklam izle.';

  @override
  String get watchAd => 'Reklam izle';

  @override
  String get adUnavailable =>
      'Reklam şu anda kullanılamıyor. Birazdan tekrar dene.';

  @override
  String get productNotFound => 'Ürün veritabanında bulunamadı.';

  @override
  String get createNewRecipe => 'Yeni tarif oluştur';

  @override
  String get noRecipesYet =>
      'Henüz tarif yok.\nBaşlamak için \"Yeni tarif oluştur\"a dokun.';

  @override
  String recipePerServing(int kcal, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porsiyon',
      one: '1 porsiyon',
    );
    return '$kcal kcal/porsiyon  ·  $_temp0';
  }

  @override
  String recipeKcalPerServing(int kcal) {
    return 'Porsiyon başına $kcal kcal';
  }

  @override
  String get servingsToLog => 'Kaydedilecek porsiyon';

  @override
  String get createRecipeTitle => 'Tarif oluştur';

  @override
  String get editRecipeTitle => 'Tarifi düzenle';

  @override
  String get recipeNameLabel => 'Tarif adı';

  @override
  String get recipeNameRequired => 'Tarif adı gerekli.';

  @override
  String get recipeDescLabel => 'Açıklama (isteğe bağlı)';

  @override
  String get servingsLabel => 'Porsiyon';

  @override
  String get ingredients => 'Malzemeler';

  @override
  String get addAtLeastOne => 'En az bir malzeme ekle.';

  @override
  String get noIngredientsYet => 'Henüz malzeme yok.';

  @override
  String get nutritionSummary => 'Besin özeti';

  @override
  String get total => 'Toplam';

  @override
  String get perServing => 'Porsiyon başına';

  @override
  String perServingCount(int count) {
    return 'Porsiyon başına ($count porsiyon)';
  }

  @override
  String get createCustomFoodTitle => 'Özel yemek oluştur';

  @override
  String get foodDetailsSection => 'Yemek bilgileri';

  @override
  String get valuesPer100 => 'Değerler 100 g / 100 ml başınadır.';

  @override
  String get foodNameLabel => 'Yemek adı';

  @override
  String get brandOptional => 'Marka (isteğe bağlı)';

  @override
  String get nutritionPer100 => '100 g başına besin değerleri';

  @override
  String get fieldRequired => 'Gerekli';

  @override
  String get enterValidNumber => 'Geçerli bir sayı gir';

  @override
  String get saveAndLog => 'Kaydet ve porsiyonu ekle';

  @override
  String get removeFavourite => 'Favorilerden kaldır';

  @override
  String get addToFavourites => 'Favorilere ekle';

  @override
  String get servingSizeG => 'Porsiyon boyutu (g)';

  @override
  String get unitGram => 'Gram';

  @override
  String get unitTablespoon => 'Yemek kaşığı';

  @override
  String get unitTeaspoon => 'Çay kaşığı';

  @override
  String get unitCup => 'Su bardağı';

  @override
  String get unitPiece => 'Adet';

  @override
  String approxGrams(int grams) {
    return '≈ $grams g';
  }

  @override
  String get addToLabel => 'Ekle:';

  @override
  String addToMeal(String meal) {
    return 'Ekle: $meal';
  }

  @override
  String get scanBarcodeTitle => 'Barkod tara';

  @override
  String get historyTitle => 'Geçmiş';

  @override
  String get noLoggedDays => 'Henüz kayıtlı gün yok.';

  @override
  String get noEntriesThatDay => 'Bu güne ait yemek kaydı yok.';

  @override
  String get today => 'Bugün';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe',
      one: '1 öğe',
    );
    return '$_temp0';
  }

  @override
  String get weeklyInsights => 'Haftalık Analizler';

  @override
  String get premiumFeature => 'Premium özellik';

  @override
  String get upgradeToPremium => 'Premium\'a geç';

  @override
  String get sevenDayAverage => '7 Günlük Ortalama';

  @override
  String kcalAvg(int n) {
    return 'ort. $n kcal';
  }

  @override
  String get kcalAvgEmpty => '— kcal ort.';

  @override
  String get weightTrend => 'Kilo trendi';

  @override
  String get prevMonth => 'Önceki ay';

  @override
  String get nextMonth => 'Sonraki ay';

  @override
  String get shareDayTitle => 'Gününü paylaş';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
      one: '1 gün',
    );
    return '$_temp0';
  }

  @override
  String get goalHit => 'Hedefe ulaşıldı!';

  @override
  String ofGoal(int n) {
    return 'hedef: $n';
  }

  @override
  String get trackedWith => 'PlateSimple ile takip edildi';

  @override
  String get preparing => 'Hazırlanıyor…';

  @override
  String get share => 'Paylaş';

  @override
  String shareText(String url) {
    return 'Bugünkü beslenmem — PlateSimple ile takip edildi 🥗\n$url';
  }

  @override
  String get premiumTitle => 'PlateSimple Premium';

  @override
  String get premiumSubtitle =>
      'Haftalık analizler · Kilo trendi · Sağlık senkronu · Reklamsız';

  @override
  String get featInsightsTitle => '7 günlük haftalık analizler';

  @override
  String get featInsightsSub =>
      'Kalori grafiğini ve 7 günlük ortalamayı tek bakışta gör.';

  @override
  String get featAdFreeTitle => 'Reklamsız deneyim';

  @override
  String get featAdFreeSub => 'Geçiş reklamı yok, ödüllü reklam yok. Asla.';

  @override
  String get featSupportTitle => 'Bağımsız bir geliştiriciyi destekle';

  @override
  String get featSupportSub =>
      'PlateSimple tek bir kişi tarafından geliştiriliyor ve sürdürülüyor. Aboneliğin onu ayakta tutuyor.';

  @override
  String get loadPricingError =>
      'Fiyatlar yüklenemedi.\nBağlantını kontrol edip tekrar dene.';

  @override
  String get choosePlan => 'Bir plan seç';

  @override
  String get alreadyPremium => 'Zaten Premium üyesisin ✓';

  @override
  String get subscribe => 'Abone ol';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfUse => 'Kullanım Koşulları';

  @override
  String get subsRenew =>
      'Abonelikler otomatik olarak yenilenir. İstediğin zaman cihaz ayarlarından iptal edebilirsin.';

  @override
  String get premiumRestored => 'Premium başarıyla geri yüklendi!';

  @override
  String get noSubFound => 'Aktif abonelik bulunamadı.';

  @override
  String get paymentPending =>
      'Ödeme bekleniyor. Ödeme yapıldığında Premium otomatik olarak açılır.';

  @override
  String get planYearly => 'Yıllık';

  @override
  String get planMonthly => 'Aylık';

  @override
  String get bestValue => 'EN AVANTAJLI';

  @override
  String get billedYearly => 'Yılda bir kez faturalandırılır';

  @override
  String get billedMonthly => 'Aylık faturalandırılır';

  @override
  String get freeTrial => 'Ücretsiz deneme';

  @override
  String get legendUnder => 'Altında';

  @override
  String get legendOnTarget => 'Hedefte';

  @override
  String get legendOver => 'Üstünde';

  @override
  String get notifTitle => 'Öğünlerini kaydetme zamanı 🥗';

  @override
  String get notifBody => 'Serini sürdür: bugün ne yediğini kaydet!';

  @override
  String get notifChannelName => 'Günlük hatırlatıcılar';

  @override
  String get notifChannelDesc => 'Her gün öğünlerini kaydetmeni hatırlatır';

  @override
  String get servingOne => '1 porsiyon';

  @override
  String servingMany(String count) {
    return '$count porsiyon';
  }

  @override
  String get gramsPerServingLabel => 'Porsiyon boyutu (g)';

  @override
  String get gramsPerServingHint =>
      'İsteğe bağlı. Miktarların porsiyon olarak gösterilmesini sağlar, ör. 100 g (2 porsiyon).';

  @override
  String get unlockWithAdToday => 'Bugün görmek için reklam izle';

  @override
  String get unlockedForToday => 'Bugün için açıldı';

  @override
  String get unlockAdUnavailable => 'Şu anda video yok. Birazdan tekrar dene.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get sectionYourFoods => 'Yemeklerin';

  @override
  String get sectionOpenFoodFacts => 'Open Food Facts';

  @override
  String get searchCachedLabel => 'Kayıtlı sonuçlar';

  @override
  String get searchOfflineCached => 'Çevrimdışı · kayıtlı sonuçlar';

  @override
  String get searchTypeMore => 'Yazdıkça Open Food Facts\'te aranıyor…';

  @override
  String get searchEmptyPrompt =>
      'Open Food Facts\'te ara veya bir barkod tara.\nKaydettiğin yemekler burada görünür.';

  @override
  String noMatchFor(String query) {
    return '\"$query\" için sonuç yok';
  }

  @override
  String get noMatchHint =>
      'Kendin ekle: birkaç saniye sürer ve sonra tekrar kullanabilirsin.';

  @override
  String get addAsCustomFood => 'Özel yemek olarak ekle';

  @override
  String get quickAddCalories => 'Hızlı kalori ekle';

  @override
  String get quickAddTitle => 'Hızlı ekle';

  @override
  String get quickAddNameLabel => 'Ad (isteğe bağlı)';

  @override
  String get optionalMacros => 'Makrolar (isteğe bağlı)';

  @override
  String get weightUnitTitle => 'Kilo birimi';

  @override
  String get weightUnitSub => 'Kayıt ve trend grafiği için.';

  @override
  String get goalsWeightSubtitle =>
      'Tartıldığın değeri buradan veya Bugün ekranından kaydet. Trend grafiği Geçmiş bölümünde.';

  @override
  String weightTrendDays(int n) {
    return '$n gün';
  }

  @override
  String weightTrendChange(String delta, int days) {
    return 'Son $days gün: $delta';
  }

  @override
  String get weightTrendNoChange =>
      'Değişimi görmek için birkaç gün sonra tekrar kaydet.';

  @override
  String get weightTrendNeedMore =>
      'Kilonu birkaç kez daha kaydet, trend burada görünsün.';

  @override
  String get weightTrendTeaserSub =>
      'Günlük dalgalanmaları yumuşatan 7 günlük ortalamalı 30 ve 90 günlük grafik.';

  @override
  String get weightTrendLoggedLegend => 'Kaydedilen';

  @override
  String get weightTrendAverageLegend => '7 günlük ortalama';

  @override
  String get healthSyncSettingApple => 'Apple Health ile senkronize et';

  @override
  String get healthSyncSettingGoogle => 'Health Connect ile senkronize et';

  @override
  String get healthSyncSettingSubtitle =>
      'Sağlık uygulamanı burada kaydettiklerinle uyumlu tut.';

  @override
  String get healthSyncExplainApple =>
      'Açıkken PlateSimple, kaydettiğin kalori, makro ve kiloyu Apple Health\'e yazar; adımlarını, aktif kalorilerini ve kilonu ondan okur. Neye izin vereceğini Sağlık izin ekranında tam olarak sen seçersin. Hiçbir şey başka bir yere gönderilmez.';

  @override
  String get healthSyncExplainGoogle =>
      'Açıkken PlateSimple, kaydettiğin kalori, makro ve kiloyu Health Connect\'e yazar; aktif kalorilerini ve kilonu ondan okur. Neye izin vereceğini Health Connect izin ekranında tam olarak sen seçersin. Hiçbir şey başka bir yere gönderilmez.';

  @override
  String get healthSyncPremiumOnly => 'Sağlık senkronu Premium\'a dahildir.';

  @override
  String get healthSyncTeaserSub =>
      'Kaydettiklerini Apple Health\'e veya Health Connect\'e gönder, adım ve kilo verilerini geri al.';

  @override
  String get statWeight => 'Kilo';

  @override
  String get healthWeightImported => 'Sağlık\'tan alınan kilo kaydına eklendi.';

  @override
  String healthAddWeightToLog(String weight) {
    return 'Kayda ekle: $weight';
  }

  @override
  String get featWeightTrendTitle => 'Kilo trendi';

  @override
  String get featWeightTrendSub =>
      '7 günlük ortalamalı 30 ve 90 günlük grafik ve dönem içindeki değişimin.';

  @override
  String get featHealthSyncTitle => 'Sağlık senkronu';

  @override
  String get featHealthSyncSub =>
      'Kaydedilen kalori ve kilo Apple Health\'e veya Health Connect\'e gider; adım ve kilo geri gelir.';

  @override
  String get privacyOptions => 'Gizlilik seçenekleri';

  @override
  String get privacyOptionsSubtitle =>
      'Kişiselleştirilmiş reklamlar için iznini değiştir';

  @override
  String get appearanceTitle => 'Görünüm';

  @override
  String get appearanceSubtitle =>
      'Telefonunun ayarını takip et ya da bir görünüm seç.';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get goalReachedToast => 'Bugün tam hedefte. Harika!';

  @override
  String get waterGoalToast => 'Su hedefine ulaşıldı. Şerefe!';

  @override
  String foodLoggedToast(String food, String meal) {
    return 'Eklendi: $food ($meal)';
  }

  @override
  String get greetingMorning => 'Günaydın';

  @override
  String get greetingAfternoon => 'İyi günler';

  @override
  String get greetingEvening => 'İyi akşamlar';

  @override
  String get searchStartTitle => 'Tabağında ne var?';

  @override
  String get mealEmptyHint => 'Henüz bir şey yok';

  @override
  String get scanHint => 'Barkodu çerçevenin içine hizala';

  @override
  String get torchTooltip => 'El feneri';

  @override
  String get waterAddGlass => 'Bir bardak ekle';

  @override
  String get waterRemoveGlass => 'Bir bardak çıkar';

  @override
  String get premiumTag => 'Premium';

  @override
  String get adNotReadyTitle => 'Şu anda video yok';

  @override
  String get adNotReadyPremiumHint =>
      'Premium bunu reklamsız olarak kalıcı şekilde açar.';

  @override
  String get shareFailed => 'Şu anda paylaşılamadı. Lütfen tekrar dene.';

  @override
  String get reminderPermissionDenied =>
      'PlateSimple için bildirimler kapalı. Hatırlatma almak için Ayarlar\'dan aç.';

  @override
  String get privacyPolicySubtitle => 'PlateSimple verilerini nasıl işler';
}
