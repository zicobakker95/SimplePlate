import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper over Firebase Analytics for marketing / user-acquisition
/// event logging.
///
/// Every call is fire-and-forget and never throws, so analytics cannot crash
/// the app. Firebase also auto-collects `first_open`, `app_open`,
/// `session_start`, and (via [observer]) screen views.
///
/// The handle is resolved lazily and guarded rather than being a field
/// initialiser. `final _fa = FirebaseAnalytics.instance` runs the moment the
/// singleton is first touched and throws outright if Firebase has not come up,
/// which would make the "never throws" promise above untrue on any device
/// where init fails — no Play Services, bad config, offline first run — and
/// would take the first screen build down with it.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _cached;
  bool _tried = false;

  /// The Firebase handle, or null when Firebase is unavailable.
  FirebaseAnalytics? get _fa {
    if (_tried) return _cached;
    _tried = true;
    try {
      _cached = FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('Analytics unavailable: $e');
      _cached = null;
    }
    return _cached;
  }

  /// True when events are actually going somewhere.
  bool get isAvailable => _fa != null;

  /// Navigator observer that auto-logs `screen_view`, or null when Firebase is
  /// unavailable. Callers should spread it: `navigatorObservers: [?observer]`.
  FirebaseAnalyticsObserver? get observer {
    final fa = _fa;
    return fa == null ? null : FirebaseAnalyticsObserver(analytics: fa);
  }

  /// Log a custom event. Parameter values must be String or num.
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    try {
      await _fa?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics "$name" failed: $e');
    }
  }

  /// Set a user property used to segment reports. Values must be strings.
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _fa?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics property "$name" failed: $e');
    }
  }
}
