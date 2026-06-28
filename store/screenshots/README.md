# Screenshots — automation

## Why there are no screenshots pre-generated here

Real device screenshots need a running **iOS Simulator** (macOS + Xcode) or
**Android emulator**. They can't be captured in a headless CI container — there's
no GPU surface / device to render to. So instead of shipping fake images, this
folder contains a **two-step automation pipeline** you run locally once, and it
produces store-ready, localized screenshots for every device size.

```
┌─ Step 1: capture raw app screens ─┐   ┌─ Step 2: frame + localize ────────┐
│ flutter drive (sim/emulator)      │ → │ frame_screenshots.py (any machine)│
│ → store/screenshots/raw/*.png     │   │ → store/screenshots/framed/...    │
└───────────────────────────────────┘   └───────────────────────────────────┘
```

---

## Step 1 — Capture raw screens

The harness (`integration_test/screenshot_test.dart`) seeds realistic sample data
(7-day streak, meals across breakfast/lunch/snack, water, goals) and captures the
**Today, History, Goals, and Add-food** screens.

### iOS (needs macOS + Xcode)
```bash
flutter pub get
open -a Simulator                 # boot any iPhone 15/16 Pro Max simulator
flutter drive \
  --driver=test_driver/screenshot_driver.dart \
  --target=integration_test/screenshot_test.dart \
  -d "iPhone 16 Pro Max"
```

### Android (emulator or device)
```bash
flutter emulators --launch <your_avd>
flutter drive \
  --driver=test_driver/screenshot_driver.dart \
  --target=integration_test/screenshot_test.dart \
  -d emulator-5554
```

Raw PNGs land in `store/screenshots/raw/` (`01_today.png` … `04_add_food.png`).

> Capturing at the **native resolution of a 6.7" iPhone simulator** gives the
> cleanest source. Step 2 rescales to every other required size.

---

## Step 2 — Frame + localize

```bash
python3 store/screenshots/frame_screenshots.py
# or target a subset:
python3 store/screenshots/frame_screenshots.py --locales en-US,nl-NL,ja-JP --devices ios_6_7,android_phone
```

This reads `raw/*.png` + `captions.json` and writes:
```
store/screenshots/framed/<device>/<locale>/01_today.png …
```
Each image is the **exact pixel size the store requires**, with a localized
caption banner and the branded green background.

### Device sizes produced
| Key | Pixels | Store requirement |
|-----|--------|-------------------|
| `ios_6_7` | 1290×2796 | **Required** (App Store, 6.7") |
| `ios_6_5` | 1242×2688 | Recommended (6.5") |
| `ios_5_5` | 1242×2208 | Optional (5.5") |
| `ipad_12_9` | 2048×2732 | Only if you ship iPad |
| `android_phone` | 1080×2340 | Google Play phone |

### Localized captions
Captions live in `captions.json`, keyed by locale (the same Tier-1 set as the
listings). Edit them there; the order maps to `01_today → 04_add_food`.

> ⚠️ **Japanese captions need a CJK font.** Install Noto Sans CJK
> (`apt install fonts-noto-cjk`, or it's built-in on macOS) before running, or
> the JP captions render as blank boxes. The script auto-detects common paths
> and warns if none is found.

---

## Notes & options
- **The app UI is English-only right now**, so raw captures show English text in
  every locale's screenshots — only the caption banner is localized. Once you add
  `flutter_localizations`, re-run Step 1 per locale (set the device language) for
  fully localized screens.
- **Want real device frames** (notch, bezel) instead of plain rounded corners?
  Swap `frame_screenshots.py`'s rounded-rect step for [`fastlane frameit`], or use
  `fastlane snapshot` (iOS) / `screengrab` (Android) end-to-end — the integration
  harness here is already compatible with both.
- Upload: App Store Connect → your app → each localization → Media Manager; and
  Google Play Console → Main store listing → Phone screenshots (per language).
