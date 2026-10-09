import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'analytics_service.dart';
import 'subscription_service.dart';
import 'consent_gate.dart';

/// How a rewarded-ad offer ended. Only [rewarded] unlocks anything.
enum RewardedOutcome {
  /// The user watched to the end: the unlock has been granted.
  rewarded,

  /// The ad showed but was closed before the reward.
  dismissed,

  /// No ad was ready, or it failed to show. Nothing was unlocked; the
  /// caller explains and offers a retry or Premium.
  unavailable,
}

/// Manages AdMob interstitial (post-log, once per session) and
/// rewarded ad (barcode scanner unlock, once per day).
class AdService extends ChangeNotifier {
  AdService._();
  static final instance = AdService._();

  // ── Ad unit IDs ────────────────────────────────────────────────────────────
  static String get _interstitialId => Platform.isAndroid
      ? (kDebugMode
          ? _testInterstitialAndroid
          : 'ca-app-pub-8031424661917979/3710657639')
      : (kDebugMode
          ? _testInterstitialIOS
          : 'ca-app-pub-8031424661917979/8579840934');

  static String get _rewardedId => Platform.isAndroid
      ? (kDebugMode
          ? _testRewardedAndroid
          : 'ca-app-pub-8031424661917979/2257975161')
      : (kDebugMode
          ? _testRewardedIOS
          : 'ca-app-pub-8031424661917979/6253060492');

  /// Anchored adaptive banner, shown only on reading screens.
  static String get bannerId => Platform.isAndroid
      ? (kDebugMode
          ? _testBannerAndroid
          : 'ca-app-pub-8031424661917979/1959849813')
      : (kDebugMode
          ? _testBannerIOS
          : 'ca-app-pub-8031424661917979/7131346093');

  /// Google's public test units. Development traffic against the production
  /// units is exactly what AdMob's invalid-traffic detection looks for, and
  /// the penalty lands on the account rather than the build. Test units also
  /// always fill, which is what makes a placement verifiable on an emulator.
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  /// Rewarded day-unlocks, keyed by feature. The stored value is the date the
  /// unlock EXPIRES (inclusive), so a multi-day unlock is expressible; the
  /// scanner key keeps its original name so existing unlocks survive the
  /// upgrade.
  static const scannerUnlockKey = 'sp.ads.scanner.unlock.date';
  static const insightsUnlockKey = 'sp.ads.insights.unlock.date';

  /// Cached in memory so the UI can ask synchronously while building.
  final Map<String, String> _unlockExpiry = {};

  // ── State ──────────────────────────────────────────────────────────────────
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  DateTime? _interstitialLoadedAt;
  DateTime? _rewardedLoadedAt;
  bool _interstitialLoading = false;
  bool _rewardedLoading = false;
  int _interstitialFailures = 0;
  int _rewardedFailures = 0;
  Timer? _interstitialRetry;
  Timer? _rewardedRetry;
  bool _interstitialShownThisSession = false;

  /// Set once MobileAds is initialised; nothing is requested before.
  bool _started = false;

  /// Completed by the rewarded load in flight, so a user's "Retry" can wait
  /// for its answer instead of guessing.
  Completer<bool>? _rewardedLoadDone;

  /// A loaded ad AdMob no longer pays for. Google's guidance is to show an
  /// interstitial or rewarded ad within an hour of loading it; after that it
  /// is thrown away and a fresh one is requested.
  static const adMaxAge = Duration(hours: 1);

  /// True when an ad loaded at [loadedAt] is too old to show at [now].
  @visibleForTesting
  static bool isExpired(DateTime? loadedAt, DateTime now) =>
      loadedAt == null || now.difference(loadedAt) >= adMaxAge;

  /// The wait before the next load after [failures] failures in a row:
  /// 10 s, 20 s, 40 s ... capped at 10 minutes.
  ///
  /// The old code never retried, so a single no-fill (common in the first
  /// seconds after MobileAds.initialize, and offline) meant no interstitial
  /// for the whole session and a free rewarded unlock every time. Backing
  /// off keeps a long no-fill streak from turning into a request storm.
  @visibleForTesting
  static Duration retryDelay(int failures) {
    if (failures <= 0) return Duration.zero;
    final shift = (failures - 1).clamp(0, 16);
    final seconds = 10 * (1 << shift);
    return Duration(seconds: seconds.clamp(10, 600));
  }

  /// Ads are only requested once consent allows it (MobileAds is started
  /// from the consent callback), and never for Premium.
  bool get _mayLoad => _started && !SubscriptionService.instance.isPremium;

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    // Load unlock state up front so the UI can ask synchronously rather than
    // flashing a locked card while a Future resolves.
    final prefs = await SharedPreferences.getInstance();
    for (final key in const [scannerUnlockKey, insightsUnlockKey]) {
      final v = prefs.getString(key);
      if (v != null) _unlockExpiry[key] = v;
    }
    // Nothing is requested until GDPR consent allows it -- see ConsentGate.
    // Not awaited: the consent form, when one is needed, never holds the
    // first frame; the SDK starts the moment the player answers.
    unawaited(ConsentGate.instance.gather(onCanRequestAds: () async {
      await MobileAds.instance.initialize();
      _started = true;
      _loadInterstitial();
      _loadRewarded();
    }));
  }

  // ── Interstitial ───────────────────────────────────────────────────────────
  void _loadInterstitial() {
    if (_interstitialLoading || _interstitial != null || !_mayLoad) return;
    _interstitialRetry?.cancel();
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitialFailures = 0;
          ad.setImmersiveMode(true);
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) =>
              logPaidEvent(
                ad: ad,
                format: 'interstitial',
                valueMicros: valueMicros,
                currencyCode: currencyCode,
              );
          _interstitial = ad;
          _interstitialLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          _interstitial = null;
          _interstitialFailures += 1;
          debugPrint('[ads] interstitial failed to load (${error.code}); '
              'retry #$_interstitialFailures');
          _interstitialRetry = Timer(
            retryDelay(_interstitialFailures),
            _loadInterstitial,
          );
        },
      ),
    );
  }

  /// The loaded interstitial, or null. An expired one is dropped and a fresh
  /// load started, so a stale ad is never shown.
  InterstitialAd? _freshInterstitial() {
    final ad = _interstitial;
    if (ad != null && isExpired(_interstitialLoadedAt, DateTime.now())) {
      ad.dispose();
      _interstitial = null;
      _loadInterstitial();
      return null;
    }
    if (ad == null) _loadInterstitial();
    return ad;
  }

  /// Foods logged since the last post-log interstitial. Drives the
  /// every-Nth gate; the once-per-session cap is applied on top.
  int _logsSinceInterstitial = 0;

  /// Whether the next [showPostLogInterstitial] would actually show an ad.
  /// The log flow uses it to keep the review prompt off a tap that is about
  /// to open a full-screen ad: two system overlays at once read as spam.
  bool get postLogInterstitialDue {
    if (SubscriptionService.instance.isPremium) return false;
    if (_interstitial == null ||
        isExpired(_interstitialLoadedAt, DateTime.now())) {
      return false;
    }
    final cfg = AdConfig.instance;
    if (cfg.logInterstitialOncePerSession && _interstitialShownThisSession) {
      return false;
    }
    return _logsSinceInterstitial + 1 >= cfg.logInterstitialEvery;
  }

  /// Shows the interstitial after a food is logged, within the Remote Config
  /// frequency rules. [onComplete] is always called, whether or not an ad
  /// shows.
  Future<void> showPostLogInterstitial({required VoidCallback onComplete}) async {
    // Premium users never see ads.
    if (SubscriptionService.instance.isPremium) {
      onComplete();
      return;
    }
    final interstitial = _freshInterstitial();
    if (interstitial == null) {
      onComplete();
      return;
    }

    final cfg = AdConfig.instance;
    // The shipped behaviour, and the reason impressions are low: one
    // interstitial per app session no matter how many meals get logged. It is
    // now a Remote Config flag so it can be relaxed and measured rather than
    // guessed at.
    if (cfg.logInterstitialOncePerSession && _interstitialShownThisSession) {
      onComplete();
      return;
    }

    _logsSinceInterstitial += 1;
    if (_logsSinceInterstitial < cfg.logInterstitialEvery) {
      onComplete();
      return;
    }
    _logsSinceInterstitial = 0;
    _interstitialShownThisSession = true;
    _interstitial = null;
    interstitial.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onComplete();
        _loadInterstitial(); // preload for the next one
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        onComplete();
        _loadInterstitial();
      },
    );
    try {
      await interstitial.show();
    } catch (e) {
      debugPrint('[ads] interstitial show failed: $e');
      interstitial.dispose();
      onComplete();
      _loadInterstitial();
    }
  }

  // ── Rewarded (scanner / insights unlock) ───────────────────────────────────
  void _loadRewarded() {
    if (_rewardedLoading || _rewarded != null || !_mayLoad) return;
    _rewardedRetry?.cancel();
    _rewardedLoading = true;
    final done = _rewardedLoadDone = Completer<bool>();
    void finish(bool ok) {
      if (!done.isCompleted) done.complete(ok);
    }

    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoading = false;
          _rewardedFailures = 0;
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) =>
              logPaidEvent(
                ad: ad,
                format: 'rewarded',
                valueMicros: valueMicros,
                currencyCode: currencyCode,
              );
          _rewarded = ad;
          _rewardedLoadedAt = DateTime.now();
          finish(true);
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          _rewarded = null;
          _rewardedFailures += 1;
          debugPrint('[ads] rewarded failed to load (${error.code}); '
              'retry #$_rewardedFailures');
          _rewardedRetry = Timer(retryDelay(_rewardedFailures), _loadRewarded);
          finish(false);
        },
      ),
    );
  }

  /// The loaded rewarded ad, or null; an expired one is dropped and
  /// replaced in the background.
  RewardedAd? _freshRewarded() {
    final ad = _rewarded;
    if (ad != null && isExpired(_rewardedLoadedAt, DateTime.now())) {
      ad.dispose();
      _rewarded = null;
      _loadRewarded();
      return null;
    }
    return ad;
  }

  /// Whether a rewarded ad is ready to show right now.
  bool get rewardedReady => _freshRewarded() != null;

  /// The user asked to try again: request a rewarded ad now, skipping the
  /// back-off wait, and resolve with whether one is ready within [timeout].
  Future<bool> retryRewarded({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (rewardedReady) return true;
    if (!_mayLoad) return false;
    if (!_rewardedLoading) {
      _rewardedRetry?.cancel();
      _loadRewarded();
    }
    final pending = _rewardedLoadDone;
    if (pending == null) return rewardedReady;
    try {
      await pending.future.timeout(timeout);
    } on TimeoutException {
      return false;
    }
    return rewardedReady;
  }

  /// Returns true if the user has already unlocked the scanner today.
  Future<bool> isScannerUnlockedToday() async =>
      isUnlocked(scannerUnlockKey);

  /// True while [key] is unlocked. Premium unlocks everything.
  ///
  /// Dates are stored as YYYY-MM-DD, so a lexicographic compare is also a
  /// chronological one — no parsing, and no timezone arithmetic to get wrong.
  bool isUnlocked(String key) {
    if (SubscriptionService.instance.isPremium) return true;
    final expiry = _unlockExpiry[key];
    if (expiry == null) return false;
    return expiry.compareTo(_dateKey(DateTime.now())) >= 0;
  }

  /// Unlocks [key] for [days] days, inclusive of today. days = 1 means the
  /// rest of today, which is what the scanner always did.
  Future<void> unlockFor(String key, int days) async {
    final until = DateTime.now().add(Duration(days: days - 1));
    final value = _dateKey(until);
    _unlockExpiry[key] = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      // The in-memory grant still stands for this session; only persistence
      // failed, and the user has already watched the ad.
      debugPrint('[ads] could not persist unlock for $key: $e');
    }
  }

  /// Shows a rewarded ad and unlocks [key] for [days] when, and only when,
  /// the SDK reports the reward (onUserEarnedReward). One flow for every
  /// day-unlock so a second placement cannot drift from the first: the
  /// scanner and the weekly insights share this.
  ///
  /// With no ad ready it resolves [RewardedOutcome.unavailable] and unlocks
  /// nothing. It used to grant the unlock for free in that case, so a single
  /// no-fill (and the old code never retried) made every rewarded placement
  /// free for the rest of the session.
  Future<RewardedOutcome> showRewardedUnlock({
    required String key,
    required int days,
  }) async {
    final ad = _freshRewarded();
    if (ad == null) {
      _loadRewarded();
      return RewardedOutcome.unavailable;
    }
    _rewarded = null;

    final result = Completer<RewardedOutcome>();
    var earned = false;
    Future<void>? granting;
    void finish(RewardedOutcome outcome) {
      if (!result.isCompleted) result.complete(outcome);
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        _loadRewarded();
        // The reward callback lands just before the dismissal; let its
        // unlock finish so the caller reads the new state.
        await granting;
        finish(earned ? RewardedOutcome.rewarded : RewardedOutcome.dismissed);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewarded();
        finish(RewardedOutcome.unavailable);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (_, reward) {
          earned = true;
          granting = unlockFor(key, days);
        },
      );
    } catch (e) {
      debugPrint('[ads] rewarded show failed: $e');
      ad.dispose();
      _loadRewarded();
      finish(RewardedOutcome.unavailable);
    }
    return result.future;
  }

  // ── Ad revenue ─────────────────────────────────────────────────────────────

  /// Reports one paid impression as GA4's standard `ad_impression` event,
  /// which Google Ads can use for value-based (tROAS) bidding. Every format
  /// the app shows calls this from its onPaidEvent.
  static void logPaidEvent({
    required Ad ad,
    required String format,
    required double valueMicros,
    required String currencyCode,
  }) {
    final source = ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName;
    unawaited(AnalyticsService.instance.logAdImpression(
      format: format,
      adUnitName: ad.adUnitId,
      adSource: source,
      valueMicros: valueMicros,
      currency: currencyCode,
    ));
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
