import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'subscription_service.dart';

/// Manages AdMob interstitial (post-log, once per session) and
/// rewarded ad (barcode scanner unlock, once per day).
class AdService {
  AdService._();
  static final instance = AdService._();

  // ── Ad unit IDs ────────────────────────────────────────────────────────────
  static String get _interstitialId => Platform.isAndroid
      ? 'ca-app-pub-8031424661917979/3710657639'
      : 'ca-app-pub-8031424661917979/8579840934';

  static String get _rewardedId => Platform.isAndroid
      ? 'ca-app-pub-8031424661917979/2257975161'
      : 'ca-app-pub-8031424661917979/6253060492';

  static const _kScannerUnlockDate = 'sp.ads.scanner.unlock.date';

  // ── State ──────────────────────────────────────────────────────────────────
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _interstitialShownThisSession = false;

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
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
  Future<void> showPostLogInterstitial({required VoidCallback onComplete}) async {
    // Premium users never see ads.
    if (SubscriptionService.instance.isPremium ||
        _interstitialShownThisSession ||
        _interstitial == null) {
      onComplete();
      return;
    }
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
  Future<bool> isScannerUnlockedToday() async {
    // Premium users always have the scanner unlocked.
    if (SubscriptionService.instance.isPremium) return true;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kScannerUnlockDate);
    final today = _dateKey(DateTime.now());
    return stored == today;
  }

  /// Unlocks the scanner for today by saving today's date.
  Future<void> _unlockScannerToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kScannerUnlockDate, _dateKey(DateTime.now()));
  }

  /// Shows the rewarded ad to unlock the scanner for the day.
  /// Calls [onUnlocked] if the user earns the reward.
  /// Calls [onCancelled] if they dismiss without watching.
  Future<void> showScannerRewardedAd({
    required VoidCallback onUnlocked,
    required VoidCallback onCancelled,
  }) async {
    if (_rewarded == null) {
      // Ad not loaded yet — grant access gracefully
      await _unlockScannerToday();
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
        await _unlockScannerToday();
      },
    );
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
