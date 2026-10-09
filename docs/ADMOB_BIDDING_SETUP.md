# AdMob bidding mediation (Unity Ads + Liftoff Monetize)

Branch: `admob-bidding-mediation` (local, not pushed). Same approach as
Deadlight's branch of the same name, without AppLovin and Meta.

The AdMob side is already live (account pub-8031424661917979): Unity Ads and
Liftoff Monetize are active bidding sources, PlateSimple's ad units are mapped
for both networks, and the shared "Bidding - Android/iOS - Interstitial /
Rewarded / Banner" mediation groups contain PlateSimple's units. Network IDs:
`Z:\Github\RecordingVideos\GoogleAds\mediation\NETWORK_IDS.md`.
**Those groups only take effect in a build that contains the adapters**, so
nothing changes for users until this branch ships in a release.

## What the app needs and what was added

Bidding adapters get their Game ID, App ID and placement IDs from AdMob at
runtime. The app only needs the adapter SDKs, consent forwarding and platform
config.

| Area | Change |
|---|---|
| `pubspec.yaml` | `gma_mediation_unity ^1.3.0` (Unity Ads SDK 4.13), `gma_mediation_liftoffmonetize ^1.1.0` (Vungle SDK 7.4), `shared_preferences_android` (direct import). These are the last adapter releases for `google_mobile_ads` 5.x, which the app stays on (5.3.1). |
| `lib/services/mediation_consent.dart` | New. `forwardMediationConsent()` passes UMP answers to the partners that need them pushed. GDPR: Liftoff reads the TCF string itself; Unity does not, so the app reads Unity's entry (Google ATP id 3234) in `IABTCF_AddtlConsent` and calls `GmaMediationUnity.setGDPRConsent`. US states: reads the GPP US National / California sections (or a legacy `IABUSPrivacy_String`) that UMP's US-states message stores, and forwards an explicit opt-out / no opt-out to Unity (`setCCPAConsent`) and Liftoff (`setCCPAStatus`). Unknown answers are never forwarded. |
| `lib/services/consent_gate.dart` | Calls `forwardMediationConsent()` right before `MobileAds.instance.initialize()` (UMP consent is already gathered first) and again after the privacy-options form. |
| `test/services/mediation_consent_test.dart` | Unit tests for the AC-string and GPP/USP parsers. |
| `ios/Runner/Info.plist` | The app had **no `SKAdNetworkItems` at all**. Added Google's list (same 50 as the other ZiBa apps) plus the official Unity and Liftoff lists (111 unique IDs, fetched 2026-10-09 from skan.mz.unity3d.com and vungle.com / liftoff.ai). |
| `ios/Podfile` | No change: `platform :ios, '15.5'` is above the adapters' minimum (iOS 12). |
| `android/app/proguard-rules.pro` | Keep rules for the adapters and both SDKs. **Release R8 is ON in this app** (the Flutter Gradle plugin enables minify for release, `build.gradle.kts` does not opt out, and the 2.0.4+36 build has a `mapping.txt`). Adapters are loaded by class name, so R8 must not strip them. |
| Android manifest / minSdk | No change needed. minSdk 26 is above the adapters' minimum (21); the SDKs merge their own activities and permissions. |

## Left for the Mac (iOS)

1. `cd ios && pod install --repo-update`. It pulls `GoogleMobileAdsMediationUnity ~> 4.13.1` and `GoogleMobileAdsMediationVungle ~> 7.4.4`. Commit `Podfile.lock`.
2. Build and run once on a device and check the Xcode log for `GADMobileAds` adapter initialisation (Unity and Liftoff should report "ready").
3. **No ATT prompt yet.** The app has no `NSUserTrackingUsageDescription` and no tracking request, so on iOS every ad request (AdMob and both partners) goes out without the IDFA. That lowers bids. Adding `app_tracking_transparency` (asked after the UMP form, as La Famiglia does) is a separate change.

## Still to check in consoles (not code)

- **AdMob > Privacy & messaging > European regulations > Ad partners**: set to "Automatically include common ad partners". Check that Unity Ads and Liftoff are in that list. If not, add them, or they get no EEA/UK traffic.
- **app-ads.txt on PlateSimple's developer domain**: must contain the `unity.com` and `vungle.com` lines (the vungle line is live on zibaentertainment.com).
- **Privacy policy + Play Data safety + App Store privacy**: name Unity Ads and Liftoff Monetize as advertising partners.

## Test steps before release

Debug builds use Google's test ad units, which never mediate. Test mediation
with the production units on a registered test device:

1. **AdMob > Settings > Test devices**: add the phone (advertising ID on
   Android, IDFA on iOS) and set the Ad Inspector gesture (shake or flick).
2. Install a **release or profile build** (production units) on that device.
   Do not build an AAB for this; `flutter run --release` is enough.
3. Open the app, wait for ads to initialise, then make the gesture: **Ad
   Inspector** opens.
   - Check that Unity Ads and Liftoff Monetize show as "Adapter initialized".
   - Use **single ad source testing**: pick an ad unit (interstitial,
     rewarded, banner), choose "Unity Ads (bidding)", load and show. Repeat
     for Liftoff Monetize.
4. Optional: with the device in EEA debug geography, accept or refuse Unity in
   the consent form and check logcat for no `[ads] mediation consent
   forwarding failed` line.
5. After release, wait about 7 days, then open **AdMob > Reports >
   Mediation**, grouped by ad source and country. Check match rate, eCPM, and
   each partner's bid response rate and win rate. Liftoff and Unity only
   appear once their adapters are in users' hands.

## Follow-up (not a blocker)

`google_mobile_ads` 5.x uses the Android Google Mobile Ads SDK 23.x, which has
been deprecated since Feb 2026 and **stops serving on 30 Jun 2027**. Plan an
upgrade to 9.x (Flutter adapters `gma_mediation_unity` 1.11+ and
`gma_mediation_liftoffmonetize` 1.5+) before then. From Unity adapter 1.10.0
the native adapter forwards GDPR consent itself, so the GDPR half of
`mediation_consent.dart` can go then.
