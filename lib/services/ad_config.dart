import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Server-tunable ad settings, backed by Firebase Remote Config.
///
/// Ad load trades revenue against retention, and the only honest way to find
/// the right numbers is to change one and watch what happens. Baked into the
/// binary, every experiment cost a release, a review wait, and weeks before
/// enough people had updated. These change in the Firebase console and take
/// effect on the next launch, and Firebase A/B Testing can run two values
/// against each other using the analytics this app already sends.
///
/// Two rules hold throughout:
///
///  * **The defaults are the current shipped behaviour.** If Remote Config is
///    unreachable — offline first launch, fetch failure, Firebase down — the
///    app behaves exactly as it does today. Nothing is switched on by a value
///    the device never actually received.
///  * **Every value is clamped.** A typo in the console goes live to every
///    user at once. `ad_log_interstitial_every = 1` would mean a full-screen
///    ad after *every* logged meal, in the app's core loop, which is how you
///    lose a calorie tracker's daily users in a week.
class AdConfig {
  AdConfig._();
  static final AdConfig instance = AdConfig._();

  // ---- keys (must match the parameter names in the Firebase console) ------

  /// Foods logged between post-log interstitials. The shipped behaviour is
  /// "once per session", expressed here as a very large number so the session
  /// guard is what actually limits it; see [logInterstitialEvery].
  static const kLogInterstitialEvery = 'ad_log_interstitial_every';

  /// Whether the once-per-session cap still applies on top of the counter.
  /// True is today's behaviour: at most one interstitial per app session,
  /// however many meals get logged.
  static const kLogInterstitialOncePerSession =
      'ad_log_interstitial_once_per_session';

  static const kBannerEnabled = 'ad_banner_enabled';
  static const kScannerRewardedEnabled = 'ad_scanner_rewarded_enabled';

  /// Days a rewarded scanner unlock lasts. 1 = the rest of today.
  static const kScannerUnlockDays = 'ad_scanner_unlock_days';

  /// Shipped behaviour. Also what Remote Config falls back to.
  static const Map<String, dynamic> defaults = <String, dynamic>{
    kLogInterstitialEvery: 1,
    kLogInterstitialOncePerSession: true,
    kBannerEnabled: true,
    kScannerRewardedEnabled: true,
    kScannerUnlockDays: 1,
  };

  // ---- clamps -------------------------------------------------------------

  /// Logging a meal is the core loop of a calorie tracker. Even at the
  /// aggressive end, an ad every single time is not something to allow by
  /// typing a number into a web form.
  static const int minLogInterstitialEvery = 1;
  static const int maxLogInterstitialEvery = 50;

  static const int maxScannerUnlockDays = 30;

  FirebaseRemoteConfig? _rc;

  /// Loads defaults, then fetches. Safe when Firebase is unavailable — [_rc]
  /// stays null and every getter returns its default.
  Future<void> init() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setDefaults(defaults);
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          // Ad load is not a per-minute decision. An hour keeps the console
          // usable for experiments without hammering the network.
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );
      _rc = rc;
      // Activate whatever was fetched last run, then refresh in the background
      // for next launch. Startup never waits on the network.
      await rc.activate();
      unawaited(rc.fetchAndActivate());
    } catch (e) {
      debugPrint('[ad_config] Remote Config unavailable, using defaults: $e');
      _rc = null;
    }
  }

  int _int(String key) {
    final fallback = defaults[key] as int;
    final forced = debugOverrides?[key];
    if (forced is int) return forced;
    try {
      final v = _rc?.getInt(key);
      // getInt returns 0 for a missing or unparseable value, which for a
      // frequency would be catastrophic — treat it as "no answer".
      if (v == null || v == 0) return fallback;
      return v;
    } catch (_) {
      return fallback;
    }
  }

  bool _bool(String key) {
    final forced = debugOverrides?[key];
    if (forced is bool) return forced;
    try {
      return _rc?.getBool(key) ?? defaults[key] as bool;
    } catch (_) {
      return defaults[key] as bool;
    }
  }

  // ---- values -------------------------------------------------------------

  /// Show the post-log interstitial on every Nth logged food.
  int get logInterstitialEvery => _int(kLogInterstitialEvery)
      .clamp(minLogInterstitialEvery, maxLogInterstitialEvery);

  /// When true, at most one post-log interstitial per app session regardless
  /// of [logInterstitialEvery]. This is the shipped behaviour and the reason
  /// PlateSimple's impressions are low; turning it off is the single biggest
  /// lever, and also the riskiest.
  bool get logInterstitialOncePerSession =>
      _bool(kLogInterstitialOncePerSession);

  /// Kill switch for banners on the reading screens.
  bool get bannerEnabled => _bool(kBannerEnabled);

  bool get scannerRewardedEnabled => _bool(kScannerRewardedEnabled);

  int get scannerUnlockDays =>
      _int(kScannerUnlockDays).clamp(1, maxScannerUnlockDays);

  /// Everything currently in force, for the debug menu and for reading a
  /// session's numbers against the config it ran under.
  Map<String, Object> snapshot() => <String, Object>{
        kLogInterstitialEvery: logInterstitialEvery,
        kLogInterstitialOncePerSession: logInterstitialOncePerSession,
        kBannerEnabled: bannerEnabled,
        kScannerRewardedEnabled: scannerRewardedEnabled,
        kScannerUnlockDays: scannerUnlockDays,
      };

  /// Forces values without a Firebase project, so the clamps and fallbacks can
  /// be tested and the debug menu can preview a config. Consulted ahead of
  /// Remote Config; null means "ask the real thing".
  @visibleForTesting
  static Map<String, dynamic>? debugOverrides;
}
