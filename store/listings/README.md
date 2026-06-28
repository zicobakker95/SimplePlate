# PlateSimple — Store Listings

Copy-ready App Store Connect (iOS) and Google Play Console (Android) metadata,
written per language and optimised for ASO.

- **App:** PlateSimple — Calorie & macro tracker by ZiBa Entertainment
- **Android package:** `com.zibaentertainment.simple_plate`
- **iOS bundle ID:** `com.zibaentertainment.simplePlate`
- **Primary category:** Health & Fitness
- **Current version:** 1.0.3 (build 4)

## Languages in this folder (Tier-1 set)

| File | Locale | App Store locale code | Google Play locale code |
|------|--------|-----------------------|-------------------------|
| [`en.md`](en.md)    | English (US)        | `en-US` | `en-US` |
| [`nl.md`](nl.md)    | Dutch               | `nl-NL` | `nl-NL` |
| [`de.md`](de.md)    | German              | `de-DE` | `de-DE` |
| [`fr.md`](fr.md)    | French              | `fr-FR` | `fr-FR` |
| [`es.md`](es.md)    | Spanish             | `es-ES` | `es-ES` |
| [`it.md`](it.md)    | Italian             | `it`    | `it-IT` |
| [`pt-BR.md`](pt-BR.md) | Portuguese (Brazil) | `pt-BR` | `pt-BR` |
| [`ja.md`](ja.md)    | Japanese            | `ja`    | `ja-JP` |

> ⚠️ **The app UI is currently English-only.** These localized listings improve
> store discovery, but until the app itself is localized (`flutter_localizations`
> + ARB files), users in these markets will still see an English interface.
> Apple and Google both allow localized store listings without a localized binary,
> but conversion and retention are best when the app language matches the listing.

---

## Field reference & character limits

### Google Play Console → Main store listing
| Field | Limit | Localizable | Notes |
|-------|-------|-------------|-------|
| App name | **30** | ✅ | Most important ASO field. Include your top keyword. |
| Short description | **80** | ✅ | Shown above the fold; high keyword weight. |
| Full description | **4000** | ✅ | Google indexes this for search — use keywords naturally. |
| App icon | 512×512 PNG, 32-bit (alpha OK) | ❌ global | → `../assets/icons/play_store_512.png` |
| Feature graphic | 1024×500 PNG/JPG (no alpha) | ✅ (can reuse) | → `../assets/graphics/play_feature_graphic_1024x500.png` |
| Phone screenshots | 2–8, min 320 px, 16:9 or 9:16 | ✅ | See `../screenshots/`. |
| 7-inch / 10-inch tablet screenshots | optional | ✅ | Only if you market on tablets. |

> Google Play has **no separate keyword field** — keywords live in the title,
> short description and full description. Avoid keyword stuffing (policy risk);
> aim for natural density.

### App Store Connect → App information / Version
| Field | Limit | Localizable | Notes |
|-------|-------|-------------|-------|
| App name | **30** | ✅ | Highest keyword weight. |
| Subtitle | **30** | ✅ | Second-highest weight; don't repeat the name. |
| Keywords | **100** | ✅ | Comma-separated, **no spaces**, no plurals/duplicates, don't repeat name/subtitle words, don't use competitor brand names. |
| Promotional text | **170** | ✅ | Editable without a new build — use for campaigns. |
| Description | **4000** | ✅ | Not indexed for keywords on iOS, but drives conversion. |
| What's New (release notes) | **4000** | ✅ | Per version. |
| App Store icon | 1024×1024 PNG, **no alpha/transparency**, flat RGB | ❌ global | → `../assets/icons/ios_appstore_1024.png` |
| 6.7" iPhone screenshots | 1290×2796 (portrait) | ✅ | **Required.** 2–10 images. |
| 6.5" iPhone screenshots | 1242×2688 or 1284×2778 | ✅ | Required if not auto-scaled from 6.7". |
| 5.5" iPhone screenshots | 1242×2208 | ✅ | Optional but recommended for older device coverage. |
| 12.9" iPad Pro screenshots | 2048×2732 | ✅ | Required only if the app supports iPad. |

### Global (set once, not per-language)
- **Privacy Policy URL** (required by both stores)
- **Support URL** / support email (required)
- **Marketing URL** (optional, iOS)
- **Copyright** (e.g. `© 2026 ZiBa Entertainment`)
- **Primary & secondary category** (Health & Fitness / Food & Drink)
- **Age rating / content rating questionnaire**
- **Pricing & availability**
- **Data safety form (Play)** / **App Privacy "nutrition label" (iOS)** — declare:
  Open Food Facts network calls, AdMob (ads/device ID), in-app purchases,
  Apple Health / Health Connect read+write, no account/login.

---

## How to use these files
1. Open the file for the locale you're filling in.
2. Each file has two sections: **Google Play** and **Apple App Store**.
3. Copy each labelled field straight into the matching console field.
4. Character counts shown in `(NN/limit)` are pre-validated.

## Assets in this bundle
- `../assets/icons/ios_appstore_1024.png` — App Store icon (flattened, no alpha)
- `../assets/icons/play_store_512.png` — Play Store icon
- `../assets/graphics/play_feature_graphic_1024x500.png` — Play feature graphic
- `../screenshots/` — screenshot automation (see its README; device screenshots
  can't be captured in CI without a simulator/emulator).
