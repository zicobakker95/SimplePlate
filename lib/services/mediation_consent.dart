// Privacy forwarding for the AdMob bidding partners (Unity Ads, Liftoff
// Monetize).
//
// GDPR (EEA / UK / CH) needs no code here. The UMP consent form writes the
// IAB TCF keys (IABTCF_TCString, IABTCF_AddtlConsent, ...) to the platform's
// default preferences, and both adapters read them on their own:
//
//   * Unity Ads: native adapter 4.19.0.1+ (gma_mediation_unity 1.10.0+)
//     forwards Unity's entry in IABTCF_AddtlConsent to the Unity SDK when
//     GDPR applies.
//   * Liftoff Monetize: gma_mediation_liftoffmonetize 1.1.0+ reads the
//     CMP's TCF consent itself.
//
// Calling the adapters' GDPR setters on top would only risk overriding that
// with a coarser flag, so this file deliberately does not.
//
// US state privacy laws are different: Google cannot apply restricted data
// processing to third-party bidders, and both Google's adapter guides ask the
// app to pass the user's "do not sell / share" choice with
// GmaMediationUnity.setCCPAConsent / GmaMediationLiftoffmonetize
// .setCCPAStatus before ads are requested. The UMP "US state regulations"
// message stores that choice as an IAB GPP string; this file decodes the
// sale / sharing opt-out from it (or from a legacy IAB US Privacy string) and
// forwards it. When no US signal exists (non-US user, or no US message
// configured) nothing is set and the networks keep their defaults.
//
// Must run before MobileAds.initialize() so the partners start with the right
// flag, and again after the consent / privacy-options form so a changed
// answer is picked up.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gma_mediation_liftoffmonetize/gma_mediation_liftoffmonetize.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

/// The user's US-privacy answer as far as the bidders are concerned.
enum UsPrivacyChoice {
  /// No US privacy signal (non-US user, or no US message shown yet).
  unknown,

  /// Shown the notice and did not opt out of sale / sharing.
  allowed,

  /// Opted out of the sale or sharing of personal information.
  optedOut,
}

/// GPP section ids (IAB GPP "Section Information").
const int _kGppUsNat = 7; // US national (MSPA), what UMP writes
const int _kGppUsCa = 8; // California state section

/// Decodes the sale / sharing opt-out from a US GPP section string.
///
/// [sectionId] 7 (usnat) core segment: Version(6), six 2-bit notice fields,
/// then SaleOptOut(2), SharingOptOut(2). [sectionId] 8 (usca): Version(6),
/// three 2-bit notice fields, then SaleOptOut(2), SharingOptOut(2).
/// Opt-out values: 0 not applicable, 1 opted out, 2 did not opt out.
@visibleForTesting
UsPrivacyChoice decodeUsGppSection(int sectionId, String? section) {
  if (section == null || section.isEmpty) return UsPrivacyChoice.unknown;
  final int saleBit;
  if (sectionId == _kGppUsNat) {
    saleBit = 6 + 6 * 2;
  } else if (sectionId == _kGppUsCa) {
    saleBit = 6 + 3 * 2;
  } else {
    return UsPrivacyChoice.unknown;
  }
  final bits = _base64UrlBits(section.split('.').first);
  if (bits == null || bits.length < saleBit + 4) return UsPrivacyChoice.unknown;
  final sale = _int(bits, saleBit, 2);
  final sharing = _int(bits, saleBit + 2, 2);
  if (sale == 1 || sharing == 1) return UsPrivacyChoice.optedOut;
  if (sale == 2 || sharing == 2) return UsPrivacyChoice.allowed;
  return UsPrivacyChoice.unknown;
}

/// Picks the US section out of a full GPP string. [sids] is
/// `IABGPP_GppSID` (ids joined by "_"); the string's sections follow the
/// header in ascending id order.
@visibleForTesting
UsPrivacyChoice decodeUsGpp(String? gpp, String? sids) {
  if (gpp == null || gpp.isEmpty || sids == null || sids.isEmpty) {
    return UsPrivacyChoice.unknown;
  }
  final ids = sids
      .split(RegExp(r'[_,]'))
      .map((s) => int.tryParse(s.trim()))
      .whereType<int>()
      .toList()
    ..sort();
  final sections = gpp.split('~');
  if (sections.length != ids.length + 1) return UsPrivacyChoice.unknown;
  for (final id in const [_kGppUsNat, _kGppUsCa]) {
    final i = ids.indexOf(id);
    if (i < 0) continue;
    final choice = decodeUsGppSection(id, sections[i + 1]);
    if (choice != UsPrivacyChoice.unknown) return choice;
  }
  return UsPrivacyChoice.unknown;
}

/// Legacy IAB US Privacy string ("1YNN"): 3rd char is the sale opt-out.
@visibleForTesting
UsPrivacyChoice decodeUsPrivacyString(String? usp) {
  if (usp == null || usp.length != 4 || usp[0] != '1') {
    return UsPrivacyChoice.unknown;
  }
  switch (usp[2]) {
    case 'Y':
      return UsPrivacyChoice.optedOut;
    case 'N':
      return UsPrivacyChoice.allowed;
    default:
      return UsPrivacyChoice.unknown;
  }
}

List<int>? _base64UrlBits(String s) {
  const alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  final bits = <int>[];
  for (final ch in s.replaceAll('=', '').split('')) {
    final v = alphabet.indexOf(ch);
    if (v < 0) return null;
    for (var b = 5; b >= 0; b--) {
      bits.add((v >> b) & 1);
    }
  }
  return bits;
}

int _int(List<int> bits, int start, int length) {
  var v = 0;
  for (var i = start; i < start + length; i++) {
    v = (v << 1) | bits[i];
  }
  return v;
}

/// The preferences store UMP writes the IAB keys to. Android: the default
/// SharedPreferences file (not the "flutter."-prefixed one the app's own
/// settings live in). iOS: standard NSUserDefaults.
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
    return null; // stored with another type, or not readable
  }
}

Future<UsPrivacyChoice> _readUsPrivacyChoice() async {
  final prefs = _iabPrefs();
  for (final id in const [_kGppUsNat, _kGppUsCa]) {
    final choice = decodeUsGppSection(
      id,
      await _readString(prefs, 'IABGPP_${id}_String'),
    );
    if (choice != UsPrivacyChoice.unknown) return choice;
  }
  final fromGpp = decodeUsGpp(
    await _readString(prefs, 'IABGPP_HDR_GppString'),
    await _readString(prefs, 'IABGPP_GppSID'),
  );
  if (fromGpp != UsPrivacyChoice.unknown) return fromGpp;
  return decodeUsPrivacyString(
    await _readString(prefs, 'IABUSPrivacy_String'),
  );
}

/// Pushes the current US-privacy answer to the bidders that need it pushed.
/// Never throws; safe to call any number of times.
Future<void> forwardMediationConsent() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  try {
    final choice = await _readUsPrivacyChoice();
    if (choice == UsPrivacyChoice.unknown) return;
    final allowed = choice == UsPrivacyChoice.allowed;
    await GmaMediationUnity().setCCPAConsent(allowed);
    await GmaMediationLiftoffmonetize().setCCPAStatus(allowed);
  } catch (e) {
    debugPrint('[ads] mediation privacy forwarding failed: $e');
  }
}
