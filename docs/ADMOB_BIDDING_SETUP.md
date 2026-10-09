# AdMob bidding mediation (Unity Ads + Liftoff Monetize)

Branch: `admob-bidding-mediation` (local, not pushed). Uses the same set as the
other ZiBa apps (Deadlight, MedMate, Klack Sort, Klack Bounce):
`google_mobile_ads ^9.1.0` + `gma_mediation_unity ^1.11.1` +
`gma_mediation_liftoffmonetize ^1.5.5`. There is no AppLovin and no Meta.

The AdMob side is already live (account pub-8031424661917979):
- Unity Ads and Liftoff Monetize are active bidding sources.
- PlateSimple's ad units are mapped for both networks.
- The shared "Bidding - Android/iOS - Interstitial / Rewarded / Banner"
  mediation groups contain PlateSimple's units.

Network IDs are in `Z:\Github\RecordingVideos\GoogleAds\mediation\NETWORK_IDS.md`.
**The groups only take effect in a build that contains the adapters**, so
nothing changes for users until this branch ships in a release.

## What changed

Bidding adapters get their Game ID, App ID and placement IDs from AdMob at
runtime. The app only needs the adapter SDKs, privacy forwarding and platform
config.

| Area | Change |
|---|---|
| `pubspec.yaml` | `google_mobile_ads` 5.3.1 → **9.1.0** (Android GMA SDK 25.4, iOS 13.7, UMP 4.0 / 3.1). The 5.x line pinned Android GMA 23.x, which has been deprecated since Feb 2026 and stops serving on 30 Jun 2027. Adds `gma_mediation_unity 1.11.1` and `gma_mediation_liftoffmonetize 1.5.5`, plus a direct `shared_preferences_android` import. |
| API fallout | One deprecation: `AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize` (`lib/widgets/ad_banner.dart`). It is **kept on purpose** with an `ignore` comment. The suggested `getLargeAnchoredAdaptiveBannerAdSize` returns a taller banner, which would change the layout of the reading screens. Nothing else needed a change. |
| `lib/services/mediation_consent.dart` | New (same file as Deadlight/Klack Sort). **GDPR needs no code.** Both adapters read UMP's TCF / Additional Consent strings themselves at these versions (Unity adapter 4.19.0.1+, Liftoff 1.1.0+). **US state privacy:** decodes the sale/sharing opt-out from the GPP string that UMP's "US state regulations" message stores (usnat / usca sections, legacy `IABUSPrivacy_String` as fallback). It forwards that with `GmaMediationUnity().setCCPAConsent` and `GmaMediationLiftoffmonetize().setCCPAStatus`. When there is no US signal, nothing is set. |
| `lib/services/consent_gate.dart` | Calls `forwardMediationConsent()` right before `MobileAds.instance.initialize()` (UMP consent is gathered first, as before). It calls it again after the consent form when ads were already running, and after the privacy-options form. |
| `test/services/mediation_consent_test.dart` | Unit tests for the GPP / US-privacy decoders. |
| `ios/Runner/Info.plist` | The app had **no `SKAdNetworkItems` at all**. Now: Google's 50 IDs + Unity's and Liftoff's official lists = 164 unique. Adds `AdNetworkIdentifiers` (AdAttributionKit, iOS 17.4+) with Liftoff's 6 entries. Sources (fetched 2026-10-09): `skan.mz.unity3d.com/v3/partner/skadnetworks.plist.json` and `vungle-static-assets.s3.amazonaws.com/dashboard/admin/prod/skadnetworkids.xml`. |
| `ios/Podfile` | No change: `platform :ios, '15.5'` is above the iOS 13.0 that Google Mobile Ads SDK 13.x and the adapters need. |
| Android | No change: minSdk 26 is above the adapters' 24 (GMA 25.x needs 23). **Release R8 stays ON** in this app: the Flutter Gradle plugin enables it, `build.gradle.kts` does not opt out, and the live 2.0.4+36 has a `mapping.txt`. `android/app/proguard-rules.pro` (added to the release build automatically by the plugin) carries keep rules for the adapters and both SDKs, which are loaded by class name. It also has `-dontwarn` for `org.conscrypt`, `org.bouncycastle.jsse` and `org.openjsse`: OkHttp, which comes in with the Vungle SDK, refers to these optional TLS classes, and R8 fails with "Missing class" without the rules (Klack Sort hit this). Local check on 2026-10-09: `flutter build apk --release` passed. R8's `configuration.txt` contains the rules, and `mapping.txt` keeps `UnityMediationAdapter` and `VungleMediationAdapter` unrenamed. The APK was deleted afterwards. |

Verified on Windows:
- `flutter analyze`: no new issues.
- Full `flutter test` suite passes.
- `flutter build apk --debug` succeeds, and the debug APK's dex contains
  `com.google.ads.mediation.unity.UnityMediationAdapter`,
  `com.google.ads.mediation.vungle.VungleMediationAdapter`, `com.unity3d.ads.UnityAds`
  and `com.vungle.ads.VungleAds`.

## Left for the Mac (iOS)

1. `cd ios && pod install --repo-update`, then commit `Podfile.lock`. Expect:
   - `Google-Mobile-Ads-SDK ~> 13.7`
   - `GoogleUserMessagingPlatform` 3.x
   - `GoogleMobileAdsMediationUnity ~> 4.20.1`
   - `GoogleMobileAdsMediationVungle ~> 7.7.7`

   If CocoaPods reports a conflict with the Firebase pods, run
   `pod repo update` first.
2. Build and run once on a device and check the Xcode log: both adapters
   should report that they initialised.
3. **No ATT prompt yet.** The app has no `NSUserTrackingUsageDescription` and
   no tracking request, so every iOS ad request (AdMob and both partners) goes
   out without the IDFA. That lowers bids. The cheapest fix is the plist key
   plus the UMP "IDFA explainer" message in AdMob Privacy & messaging. That is
   a separate change.

## Still to check in consoles (not code)

- **AdMob > Privacy & messaging > European regulations > Ad partners** is set
  to "Automatically include common ad partners". Check that Unity Ads and
  Liftoff are in that list, or they get no EEA/UK traffic.
- **AdMob > Privacy & messaging > US state regulations**: the US message must
  be published for the US-privacy forwarding to have a signal to pass on.
- **app-ads.txt on PlateSimple's developer domain** must contain the
  `unity.com` and `vungle.com` lines (the vungle line is live on
  zibaentertainment.com).
- **Privacy policy, Play Data safety and App Store privacy**: name Unity Ads
  and Liftoff Monetize as advertising partners.

## Test steps before release

Debug builds use Google's test ad units, which never mediate. Test mediation
with the production units on a registered test device:

1. **AdMob > Settings > Test devices**: add the phone (advertising ID on
   Android, IDFA on iOS) and set the Ad Inspector gesture (shake or flick).
2. Install a **release or profile build** (production units) on that device.
3. Open the app, wait for ads to start (after the consent form, if one shows),
   then make the gesture to open **Ad Inspector**.
   - Unity Ads and Liftoff Monetize should show "Adapter initialized".
   - Use **single ad source testing** for each format (interstitial,
     rewarded, banner): pick "Unity Ads (bidding)", load and show, then repeat
     for Liftoff Monetize.
4. Check that the banner on the reading screens is the same height as in the
   current release.
5. About 7 days after release, open **AdMob > Reports > Mediation**, grouped
   by ad source and country. Check match rate, eCPM, and each partner's bid
   response rate and win rate.
