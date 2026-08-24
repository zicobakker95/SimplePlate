# PlateSimple — ad settings in Firebase Remote Config

Ad frequency is no longer baked into the binary. These parameters live in
**Firebase console → Remote Config** for project `platesimple-ziba`, and take
effect on the next app launch, so tuning and A/B tests cost no release.

The console is under the **bollibol95@gmail.com** account, which is `u/2` in
the Firebase console URLs — an unqualified console.firebase.google.com link
lands on an account with no projects and reports that the project does not
exist.

## Status

**Published (Remote Config version 1).** All five parameters exist with the
defaults below, which are the values the app already ships, so publishing them
changed no behaviour.

No *released* build reads them yet — `firebase_remote_config` was added in the
same change that introduced this file. Until a build carrying it ships,
editing these values affects nobody.

## Parameters

| Parameter | Type | Default | What it does |
|---|---|---|---|
| `ad_log_interstitial_once_per_session` | Boolean | `true` | At most one post-log interstitial per app session, whatever the counter says. **This is the ceiling on impressions.** |
| `ad_log_interstitial_every` | Number | `1` | Show the post-log interstitial on every Nth logged food. Only bites once the flag above is `false`. Clamped to 1–50. |
| `ad_banner_enabled` | Boolean | `true` | Banners on the reading screens. Needs a build carrying a banner ad unit — see below. |
| `ad_scanner_rewarded_enabled` | Boolean | `true` | Rewarded ad that unlocks the barcode scanner for free users. |
| `ad_scanner_unlock_days` | Number | `1` | How long that unlock lasts. 1 = the rest of today. Clamped to 1–30. |

Names must match exactly — the app looks them up by string.

## Read the clamps before running an experiment

A console value is live for every user at once, so every parameter is clamped
in `ad_config.dart`. `ad_log_interstitial_every = 0` does **not** mean "every
time"; it is treated as no answer and falls back to the default. This matters
more here than in a game: logging a meal is the core loop of a calorie
tracker, and an interstitial on every single log is how you lose daily users
in a week.

`ad_config_test.dart` pins the defaults and every clamp.

## Where the impressions actually are

Measured against the code, not guessed:

* **`ad_log_interstitial_once_per_session` is the binding constraint.** A
  calorie tracker gets opened several times a day — once per meal — and each
  of those sessions can show exactly one interstitial, and only if the user
  logs something. Everything else is noise next to this flag.
* **There are no banners at all.** History, Goals and the food-search screen
  are all pure reading surfaces where a bottom banner costs nothing in the
  logging flow. This is the same gap Deadlight had.
* **One rewarded placement.** The scanner unlock is a good pattern — opt-in,
  so no retention cost — and `goals_screen` and `history_screen` both already
  have `isPremium` gates that could offer the same day-unlock deal.

### Suggested order

1. **Banners on the reading screens.** Additive, no effect on the logging
   loop, and the app is opened many times a day. Blocked on an ad unit (below).
2. **More rewarded day-unlocks**, mirroring the scanner: same opt-in shape,
   and it doubles as a Premium trial that sells itself.
3. **Only then** relax `ad_log_interstitial_once_per_session`, one step at a
   time, watching D1/D7 rather than impressions. Impressions rise by
   construction; they answer nothing on their own.

## Blocked: there is no banner ad unit

`ad_service.dart` carries an interstitial and a rewarded unit. There is no
banner unit for PlateSimple in AdMob, so `ad_banner_enabled` currently has
nothing to switch on. Creating one in AdMob and adding the Android + iOS ids
is the one manual step before banners can ship.
