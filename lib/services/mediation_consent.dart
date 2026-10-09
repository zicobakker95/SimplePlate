// Consent forwarding for the AdMob bidding partners (Unity Ads and Liftoff
// Monetize). Same approach as Deadlight's mediation_consent.dart; see
// docs/ADMOB_BIDDING_SETUP.md.
//
// The UMP consent form writes the user's answers to the IAB keys in the
// platform's default preferences (Android: the app's default
// SharedPreferences, iOS: standard NSUserDefaults). What each partner does
// with them:
//
//   * Liftoff Monetize (adapter 1.1.0+) reads the GDPR/TCF answer on its own
//     ("automatically reads GDPR consent set by consent management
//     platforms"), so it gets no GDPR call from here.
//   * Unity Ads (adapter 1.3.0, SDK 4.13) does NOT read it. Automatic
//     forwarding only arrived in the native Unity adapter 4.19.0.1 (Flutter
//     adapter 1.10.0, which needs google_mobile_ads 9.x). So this file does
//     what that adapter does: look up Unity's Google Ad Tech Provider id in
//     the IABTCF_AddtlConsent string and pass the answer on with
//     GmaMediationUnity.setGDPRConsent.
//   * US state privacy laws (CCPA/CPRA and the other state laws): when the
//     AdMob "US state regulations" message has been shown, UMP stores the
//     answer as a GPP string. An explicit "opted out of sale/sharing" or
//     "did not opt out" in the US National (usnat) or California (usca)
//     section, or in a legacy IABUSPrivacy_String, is passed to both partners
//     (Unity setCCPAConsent, Liftoff setCCPAStatus). Google applies
//     restricted data processing for its own demand from the same signal.
//
// When an answer is unknown (no message shown, GDPR does not apply, no
// string yet) nothing is set, so each partner keeps its default behaviour.
// That is also what the newer adapters do. Must run before
// MobileAds.initialize() so the partners start with the right flags, and
// again after the privacy-options form so a changed answer is picked up.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gma_mediation_liftoffmonetize/gma_mediation_liftoffmonetize.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

/// Unity Ads' Google Ad Tech Provider id, from
/// https://storage.googleapis.com/tcfac/additional-consent-providers.csv
/// (the same constant the native Unity adapter uses).
const int kUnityAdTechProviderId = 3234;

/// A consent answer that may not have been given.
enum AcConsent { unknown, granted, denied }

/// Parses Google's Additional Consent string (`IABTCF_AddtlConsent`) for
/// [providerId]. Spec v1: `1~id.id.id` (consented only). Spec v2:
/// `2~id.id~dv.id.id` (consented, then disclosed). A vendor that was
/// disclosed but not consented was explicitly refused.
@visibleForTesting
AcConsent parseAdditionalConsent(String? ac, int providerId) {
  if (ac == null || ac.isEmpty) return AcConsent.unknown;
  final parts = ac.split('~');
  final version = int.tryParse(parts.first);
  if (version == null) return AcConsent.unknown;
  final id = providerId.toString();
  final consented = parts.length > 1 ? parts[1].split('.') : const <String>[];
  if (version == 1) {
    return consented.contains(id) ? AcConsent.granted : AcConsent.unknown;
  }
  if (parts.length < 3) return AcConsent.unknown;
  final disclosed = parts[2].split('.');
  if (disclosed.isEmpty || disclosed.first != 'dv') return AcConsent.unknown;
  if (consented.contains(id)) return AcConsent.granted;
  if (disclosed.contains(id)) return AcConsent.denied;
  return AcConsent.unknown;
}

/// US privacy: [AcConsent.granted] = the user did not opt out of the sale or
/// sharing of personal information, [AcConsent.denied] = opted out.
///
/// Reads, in order, the GPP US National section (id 7), the GPP California
/// section (id 8) and the legacy CCPA string. The first one that gives an
/// explicit answer wins.
@visibleForTesting
AcConsent parseUsPrivacy({
  String? usNat,
  String? usCa,
  String? usPrivacy,
}) {
  // usnat core segment: Version(6) SharingNotice(2) SaleOptOutNotice(2)
  // SharingOptOutNotice(2) TargetedAdvertisingOptOutNotice(2)
  // SensitiveDataProcessingOptOutNotice(2) SensitiveDataLimitUseNotice(2)
  // SaleOptOut(2) SharingOptOut(2) TargetedAdvertisingOptOut(2) ...
  final nat = _gppOptOut(usNat, saleBit: 18, otherBits: const [20, 22]);
  if (nat != AcConsent.unknown) return nat;
  // usca core segment: Version(6) SaleOptOutNotice(2) SharingOptOutNotice(2)
  // SensitiveDataLimitUseNotice(2) SaleOptOut(2) SharingOptOut(2) ...
  final ca = _gppOptOut(usCa, saleBit: 12, otherBits: const [14]);
  if (ca != AcConsent.unknown) return ca;
  // uspv1: "1YNN" = version, notice given, opted out of sale, LSPA.
  if (usPrivacy != null && usPrivacy.length >= 3 && usPrivacy[0] == '1') {
    switch (usPrivacy[2].toUpperCase()) {
      case 'Y':
        return AcConsent.denied;
      case 'N':
        return AcConsent.granted;
    }
  }
  return AcConsent.unknown;
}

/// GPP opt-out fields are 2 bits: 0 = not applicable, 1 = opted out,
/// 2 = did not opt out. Any opt-out ([saleBit] or one of [otherBits]) counts
/// as an opt-out; "did not opt out" needs the sale field itself.
AcConsent _gppOptOut(
  String? section, {
  required int saleBit,
  required List<int> otherBits,
}) {
  final bits = _base64UrlBits(section);
  if (bits == null) return AcConsent.unknown;
  int? field(int at) =>
      at + 2 <= bits.length ? (bits[at] << 1) | bits[at + 1] : null;
  final sale = field(saleBit);
  if (sale == null) return AcConsent.unknown;
  if (sale == 1 || otherBits.any((b) => field(b) == 1)) {
    return AcConsent.denied;
  }
  return sale == 2 ? AcConsent.granted : AcConsent.unknown;
}

/// Decodes the core segment (before any '.') of a GPP section string, which
/// is unpadded base64url, into a list of bits.
List<int>? _base64UrlBits(String? s) {
  if (s == null || s.isEmpty) return null;
  const alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  final core = s.split('.').first;
  final bits = <int>[];
  for (final ch in core.split('')) {
    final v = alphabet.indexOf(ch);
    if (v < 0) return null;
    for (var i = 5; i >= 0; i--) {
      bits.add((v >> i) & 1);
    }
  }
  return bits.isEmpty ? null : bits;
}

/// The IAB keys UMP stores live in the default preferences, not in the
/// "flutter."-prefixed file the app's own settings use.
SharedPreferencesAsync _iabPrefs() {
  if (Platform.isAndroid) {
    return SharedPreferencesAsync(
      options: const SharedPreferencesAsyncAndroidOptions(
        backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
        // fileName null = PreferenceManager.getDefaultSharedPreferences.
        originalSharedPreferencesOptions: AndroidSharedPreferencesStoreOptions(),
      ),
    );
  }
  return SharedPreferencesAsync();
}

Future<String?> _readString(SharedPreferencesAsync prefs, String key) async {
  try {
    return await prefs.getString(key);
  } catch (_) {
    // A CMP that stored the key with another type; treat it as absent.
    return null;
  }
}

/// Pushes the current UMP answers to the partners that need them pushed.
/// Never throws; safe to call any number of times.
Future<void> forwardMediationConsent() async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
  try {
    final prefs = _iabPrefs();

    // GDPR. Only a collected answer counts: "notRequired" (outside the
    // EEA/UK/CH) leaves Unity on its default behaviour.
    final status = await ConsentInformation.instance.getConsentStatus();
    if (status == ConsentStatus.obtained) {
      final unity = parseAdditionalConsent(
        await _readString(prefs, 'IABTCF_AddtlConsent'),
        kUnityAdTechProviderId,
      );
      if (unity != AcConsent.unknown) {
        await GmaMediationUnity().setGDPRConsent(unity == AcConsent.granted);
      }
    }

    // US state privacy laws.
    final us = parseUsPrivacy(
      usNat: await _readString(prefs, 'IABGPP_7_String'),
      usCa: await _readString(prefs, 'IABGPP_8_String'),
      usPrivacy: await _readString(prefs, 'IABUSPrivacy_String'),
    );
    if (us != AcConsent.unknown) {
      final optedIn = us == AcConsent.granted;
      await GmaMediationUnity().setCCPAConsent(optedIn);
      await GmaMediationLiftoffmonetize().setCCPAStatus(optedIn);
    }
  } catch (e) {
    debugPrint('[ads] mediation consent forwarding failed: $e');
  }
}
