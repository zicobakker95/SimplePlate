# PlateSimple — Store submission kit

Everything needed to publish PlateSimple to the **App Store** and **Google Play**,
localized for the Tier-1 language set (EN, NL, DE, FR, ES, IT, PT-BR, JA).

```
store/
├── listings/          ← copy-ready ASO metadata, one file per language
│   ├── README.md      ← field specs, char limits, ASO strategy, global metadata
│   ├── en.md  nl.md  de.md  fr.md  es.md  it.md  pt-BR.md  ja.md
├── assets/
│   ├── icons/
│   │   ├── ios_appstore_1024.png   ← 1024×1024, flattened (no alpha) — App Store
│   │   └── play_store_512.png      ← 512×512 — Google Play
│   └── graphics/
│       └── play_feature_graphic_1024x500.png  ← Play feature graphic
└── screenshots/
    ├── README.md           ← how to capture + frame screenshots
    ├── captions.json       ← localized caption banners
    └── frame_screenshots.py
```

## What's ready to upload right now
| Asset | Status | Path |
|-------|--------|------|
| Store text (8 languages × both stores) | ✅ Ready | `listings/*.md` |
| App Store icon (1024², no alpha) | ✅ Ready | `assets/icons/ios_appstore_1024.png` |
| Google Play icon (512²) | ✅ Ready | `assets/icons/play_store_512.png` |
| Play feature graphic (1024×500) | ✅ Ready | `assets/graphics/play_feature_graphic_1024x500.png` |
| Screenshots | ⚙️ Run the pipeline | `screenshots/README.md` |

> Screenshots can't be auto-captured in CI (no simulator/emulator). The
> `screenshots/` folder has a one-command pipeline to generate them locally,
> framed and localized, at every required device size.

## Before you submit — global (non-localized) checklist
- [ ] **Privacy Policy URL** (required by both stores)
- [ ] **Support URL / email** (required)
- [ ] **Copyright** — e.g. `© 2026 ZiBa Entertainment`
- [ ] **Primary category** Health & Fitness, **secondary** Food & Drink
- [ ] **Age rating** questionnaire (Apple) / **content rating** (Google)
- [ ] **App privacy** (iOS "nutrition label") + **Data safety** (Play): declare
      Open Food Facts network use, AdMob (ads + device identifiers), in-app
      purchases, and Apple Health / Health Connect read+write
- [ ] **In-app purchase** set up (Premium) in both consoles
- [ ] iOS: enable **HealthKit** capability on the App ID and regenerate the
      provisioning profile (the app already ships `Runner.entitlements`)
- [ ] Pricing & availability / countries

## ASO notes
- **Title + subtitle (iOS) / title + short description (Play)** carry the most
  search weight — each locale leads with its top local keyword.
- **iOS keywords field** is comma-separated, no spaces, no duplicates, and does
  not repeat words already in the app name/subtitle (Apple combines them).
- **Google Play has no keyword field** — keywords are woven naturally into the
  title, short description and full description.
- Re-validate character counts any time you edit:
  counts are annotated inline as `(N/limit)` in each listing file.
