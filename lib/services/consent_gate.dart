import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// GDPR consent through Google's UMP, before any ad is requested.
///
/// AdMob refuses to serve personalised ads in the EEA, UK and Switzerland
/// without a TCF consent string on the request, and flags apps in the Policy
/// Centre that request ads without asking. Outside those regions UMP reports
/// consent as not required and ads start immediately.
///
/// Usage: call [gather] once at start-up, fire-and-forget, with the work that
/// starts ads (MobileAds.initialize and the first loads). Anything that
/// requests an ad later -- a banner being built -- checks [canRequestAds]
/// first and listens to it, so it loads the moment consent arrives.
class ConsentGate {
  ConsentGate._();
  static final ConsentGate instance = ConsentGate._();

  /// True once ads may be requested. Starts false; flips true either straight
  /// away (a previous answer or a region where consent is not required) or
  /// when the player answers the form.
  final ValueNotifier<bool> canRequestAds = ValueNotifier(false);

  /// Whether the settings screen must offer "Privacy options". Required by
  /// Google's policy wherever the form was required.
  final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier(false);

  bool _started = false;
  Future<void> Function()? _onCanRequestAds;

  /// Runs the consent flow. [onCanRequestAds] runs once, as soon as ads are
  /// allowed: immediately when a stored answer already allows them, otherwise
  /// the moment the player answers the form -- however long that takes. The
  /// 20-second wait only stops start-up hanging on the form; it never decides
  /// anything. (Deadlight's first version checked once after that wait and
  /// never again, so a player who read the form for longer got no ads for
  /// the whole session.) Never throws.
  Future<void> gather({required Future<void> Function() onCanRequestAds}) async {
    _onCanRequestAds = onCanRequestAds;
    await _startIfAllowed();

    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) async {
            if (error != null) {
              debugPrint('[consent] form: ${error.errorCode} ${error.message}');
            }
            await _startIfAllowed();
            await _refreshPrivacyOptions();
            finish();
          });
        },
        (FormError error) async {
          // Offline, say. A stored answer still counts; no answer means no ads.
          debugPrint('[consent] update: ${error.errorCode} ${error.message}');
          await _startIfAllowed();
          finish();
        },
      );
    } catch (e) {
      debugPrint('[consent] request failed: $e');
      finish();
    }
    await done.future.timeout(const Duration(seconds: 20), onTimeout: () {});
  }

  /// Re-opens the consent form from settings so the player can change or
  /// withdraw consent.
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    try {
      ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (error != null) {
          debugPrint('[consent] privacy options: ${error.errorCode} ${error.message}');
        }
        if (!done.isCompleted) done.complete();
      });
    } catch (e) {
      debugPrint('[consent] privacy options failed: $e');
      if (!done.isCompleted) done.complete();
    }
    await done.future.timeout(const Duration(seconds: 60), onTimeout: () {});
    await _startIfAllowed();
    await _refreshPrivacyOptions();
  }

  Future<void> _startIfAllowed() async {
    if (_started) return;
    bool allowed;
    try {
      allowed = await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      debugPrint('[consent] canRequestAds failed: $e');
      allowed = false;
    }
    if (!allowed || _started) return;
    _started = true;
    try {
      await _onCanRequestAds?.call();
    } catch (e) {
      debugPrint('[consent] starting ads failed: $e');
    }
    canRequestAds.value = true;
  }

  Future<void> _refreshPrivacyOptions() async {
    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      privacyOptionsRequired.value =
          status == PrivacyOptionsRequirementStatus.required;
    } catch (e) {
      debugPrint('[consent] privacy options status failed: $e');
    }
  }
}
