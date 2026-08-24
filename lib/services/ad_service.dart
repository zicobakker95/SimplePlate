import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'subscription_service.dart';

/// Manages AdMob interstitial (post-log, once per session) and
/// rewarded ad (barcode scanner unlock, once per day).
class AdService extends ChangeNotifier {
  AdService._();
  static final instance = AdService._();

  // ── Ad unit IDs ────────────────────────────────────────────────────────────
  static String get _interstitialId => Platform.isAndroid
      ? 'ca-app-pub-8031424661917979/3710657639'
      : 'ca-app-pub-8031424661917979/8579840934';

  static String get _rewardedId => Platform.isAndroid
      ? 'ca-app-pub-8031424661917979/2257975161'
      : 'ca-app-pub-8031424661917979/6253060492';

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
  bool _interstitialShownThisSession = false;

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    // Load unlock state up front so the UI can ask synchronously rather than
    // flashing a locked card while a Future resolves.
    final prefs = await SharedPreferences.getInstance();
    for (final key in const [scannerUnlockKey, insightsUnlockKey]) {
      final v = prefs.getString(key);
      if (v != null) _unlockExpiry[key] = v;
    }
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  // ── Interstitial ───────────────────────────────────────────────────────────
  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitial!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Shows the interstitial once per session after a food is logged.
  /// [onComplete] is always called regardless of whether the ad shows.
  /// Foods logged since the last post-log interstitial. Drives the
  /// every-Nth gate; the once-per-session cap is applied on top.
  int _logsSinceInterstitial = 0;

  Future<void> showPostLogInterstitial({required VoidCallback onComplete}) async {
    // Premium users never see ads.
    if (SubscriptionService.instance.isPremium || _interstitial == null) {
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
    _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        onComplete();
        _loadInterstitial(); // preload for next session
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        onComplete();
        _loadInterstitial();
      },
    );
    await _interstitial!.show();
  }

  // ── Rewarded (scanner unlock) ──────────────────────────────────────────────
  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (_) => _rewarded = null,
      ),
    );
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

  /// Unlocks the scanner for today by saving today's date.


  /// Shows the rewarded ad to unlock the scanner for the day.
  /// Calls [onUnlocked] if the user earns the reward.
  /// Calls [onCancelled] if they dismiss without watching.
  Future<void> showScannerRewardedAd({
    required VoidCallback onUnlocked,
    required VoidCallback onCancelled,
  }) =>
      showRewardedUnlock(
        key: scannerUnlockKey,
        days: AdConfig.instance.scannerUnlockDays,
        onUnlocked: onUnlocked,
        onCancelled: onCancelled,
      );

  /// Shows a rewarded ad and, if the user earns the reward, unlocks [key] for
  /// [days]. One flow for every day-unlock so a second placement cannot drift
  /// from the first — the scanner and the weekly insights share this.
  Future<void> showRewardedUnlock({
    required String key,
    required int days,
    required VoidCallback onUnlocked,
    required VoidCallback onCancelled,
  }) async {
    if (_rewarded == null) {
      // Ad not loaded yet — grant access gracefully
      await unlockFor(key, days);
      onUnlocked();
      return;
    }

    bool rewarded = false;

    _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
        if (rewarded) {
          onUnlocked();
        } else {
          onCancelled();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
        onCancelled();
      },
    );

    await _rewarded!.show(
      onUserEarnedReward: (_, reward) async {
        rewarded = true;
        await unlockFor(key, days);
      },
    );
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
