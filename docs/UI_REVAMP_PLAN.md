# PlateSimple UI revamp plan

Goal from the owner: *make the app feel alive with nice animations*, at the level of the
Word Waves and Deadlight overhauls: one coherent design system on every screen, snappy press
feedback, purposeful motion, a characterful mascot, polished empty states, nothing that looks
like stock Material.

This is a **UI revamp, not a logic rewrite**. Data, persistence (SharedPreferences + drift),
Health Connect / Apple Health flows, the reminder notification, the home-screen widget, AdMob
(banner, interstitial, rewarded unlocks, UMP consent), subscriptions, analytics events and the
debug-only tools keep working exactly as before.

## 1. Audit (before)

The app was dark-only stock Material 3 with an Inter text theme and a flat green accent.
`AppColors` constants were used directly in every file, so there was no light theme and no
shared component layer: each screen built its own cards, chips, dividers and buttons.

| Screen / surface | File | State before |
| --- | --- | --- |
| Home shell + nav | `screens/home/home_shell.dart` | Stock `NavigationBar`, banner above it. |
| Today | `screens/home/today_screen.dart` | `percent_indicator` ring in a bordered card, three thin macro bars, emoji empty card, stock FAB, stock chip for the streak. No motion beyond the ring tween. |
| Meal sections | `widgets/meal_section.dart` | Bordered card per meal, `ListTile` rows, red swipe-to-delete background. |
| Water | `widgets/water_card.dart` | Grid of blue squares, reset hidden behind long-press on an info icon. |
| Weight / Activity / Health | `widgets/weight_card.dart`, `activity_section.dart`, `health_card.dart` | Three different header styles, mixed text/outlined/filled buttons, `Colors.redAccent`/`Colors.orange` one-offs. |
| Add food (search / recents / recipes) | `screens/log/add_food_screen.dart` | Stock `TabBar`, plain `ListTile`s, text-only empty states, stock spinner. |
| Food detail | `screens/log/food_detail_screen.dart` | Form + macro rows, stock `ChoiceChip`s for meals. |
| Custom food / recipe builder | `create_custom_food_screen.dart`, `create_recipe_screen.dart` | Plain forms; ingredients appear with no feedback. |
| Barcode | `screens/log/barcode_screen.dart` | Static frame on the camera feed. |
| Quick add / edit entry / log activity / TDEE / share | sheets in `widgets/` and `screens/goals/` | Each sheet hand-rolls its own handle, padding, title and buttons. |
| Dialogs | copy-yesterday, delete entry, reset water, unlock scanner, log recipe | Stock `AlertDialog`. |
| History | `screens/history/history_screen.dart` | Weekly bars, locked teaser with a black veil, calendar heatmap, day cards, day sheet. |
| Weight trend | `widgets/weight_trend_card.dart` | Custom painter (good), stock `SegmentedButton`, black veil lock. |
| Goals / settings | `screens/goals/goals_screen.dart` | One long list of headed sections separated by dividers; purple premium banner unrelated to the brand. |
| Premium paywall | `screens/premium/premium_screen.dart` | Purple gradient header (off-brand), plan cards. |
| Onboarding | `screens/onboarding/onboarding_screen.dart` | Gradient square icon, form page, notification page. |
| Debug menu | `debug/debug_menu_screen.dart` | Debug builds only; uses theme defaults. |

## 2. Design direction: "Kitchen table"

The app icon is the brief: a white plate on a cream linen background, ringed by green, orange
and blue segments. The new identity takes the app *into* that icon.

* **Light theme (the hero):** warm linen background, plate-white cards with soft shadows,
  herb-green primary, the icon's orange and blue as the carb and protein colours, tomato for fat
  and for "over". Warm charcoal text instead of pure black.
* **Dark theme:** "kitchen at night" - warm espresso surfaces (not the old green-black), the same
  food colours brightened for contrast.
* Follows the system setting by default, with an **Appearance** switch (System / Light / Dark)
  under Goals. Previously the app was forced dark.

### Palette (`lib/ui/theme/plate_theme.dart`)

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| bg | `#F6F1E7` linen | `#15130F` | Scaffold |
| surface | `#FFFFFF` | `#211E19` | Cards, sheets |
| sunken | `#EFE8DB` | `#1B1915` | Tracks, inputs |
| primary | `#24894F` herb | `#4CC487` | Buttons, calories |
| fresh | `#3DB873` | `#5AD094` | Ring fill, success |
| protein | `#3F8FD6` | `#6AB0F0` | from the icon |
| carbs | `#E8962A` | `#F4B04E` | from the icon |
| fat | `#E2604E` tomato | `#F27F6D` | |
| honey | `#F2A93B` | `#F7BC55` | streak, stars |
| water | `#3BA8E0` | `#5CC0F2` | water tracker |
| premium | `#C9881C` saffron | `#E6A94A` | Premium accents (was off-brand purple) |

Text contrast was checked against the surfaces: body text >= 7:1, muted >= 4.5:1, white on
primary buttons >= 4.5:1.

### Type

**Rubik** (OFL, bundled under `assets/fonts/` instead of fetched at runtime by google_fonts):
rounded corners that read friendly and edible without being childish, and solid tabular figures
for numbers. Scale: display 30/700, title 22/700, headline 17/700, body 15/400, small 13,
label 12/700 caps, numbers 700 with tabular figures. Japanese falls back to the system CJK font.

### Shapes and spacing

4-pt spacing scale, 20 px page gutter. Radii 12 (chips, inputs), 18 (cards), 26 (sheets,
hero cards), pill buttons. Cards carry a two-layer warm shadow in light mode and a 1 px border
in dark mode (shadows disappear on dark).

### Motion principles

* **Fast and physical.** 120 / 240 / 420 ms, ease-out-cubic for movement, ease-out-back for
  things that land. Nothing blocks input while it animates.
* **Press feedback everywhere:** every tappable thing squishes to 0.95-0.98 on pointer-down and
  springs back (`Pressable`).
* **Entrances:** cards fade and rise in a 40 ms stagger the first time a screen builds.
* **Progress fills:** the plate ring, the macro rings, water glasses, bars and the calendar all
  animate to their new value; calorie and macro numbers count up.
* **Add / remove feedback:** a newly logged food pops into its meal (scale + highlight);
  deleting slides it out. Water glasses fill with a wave and splash.
* **Celebrations:** entering the calorie target window (85-110 % of goal) or reaching the water
  goal during a session fires a food-confetti burst (peas, leaves, crumbs) plus a toast and a
  happy mascot. Celebrations fire on the transition only, once per day per goal.
* **Page transitions:** fade + small rise for pushed screens; tab switches cross-fade.
* **Reduce motion:** `MediaQuery.disableAnimations` turns entrances, confetti, mascot idle
  and count-ups into instant state changes.
* **Idle screens do not repaint:** no endless tickers; the mascot blinks on a timer with a short
  animation and is otherwise static; confetti stops its ticker when the last particle dies.

### Mascot: Sprout

A small round pea-sprout drawn in code (no image assets, follows dark mode): green body,
two leaves, blush cheeks. Why a mascot here: calorie tracking is a chore people abandon, and a
character that is pleased when you log and sleepy when the plate is empty makes the empty states
and the goal moments feel warm instead of clinical. Kept small and optional in the layout so the
numbers stay the hero. Moods: `idle` (occasional blink), `happy` (bounce, ^ ^ eyes), `celebrate`
(jump, star eyes, wiggling leaves), `sleepy` (closed eyes, zzz - empty states), `hungry`
(round "o" mouth - empty plate / no results), `thinking` (searching).

Where: onboarding welcome + finish, Today empty state and celebration toast, empty search,
no recipes/foods, history empty, paywall header.

## 3. Shared kit (`lib/ui/`)

* `theme/plate_theme.dart` - palette (ThemeExtension, light + dark), spacing, radii, motion,
  shadows, type scale, `buildPlateTheme()` so stock widgets (time picker, switches, text fields,
  snackbars, menus) match.
* `widgets/pressable.dart` - squish feedback.
* `widgets/pt_button.dart` - primary / soft / outline / ghost / danger buttons, loading state,
  48 dp minimum; round icon button.
* `widgets/pt_card.dart` - card, section header, list tile, switch tile, icon badge, pill/tag.
* `widgets/pt_sheet.dart` - one bottom sheet (handle, title, keyboard-aware padding) and one
  confirm dialog used by every popup.
* `widgets/pt_toast.dart` - floating toast with icon and tone.
* `widgets/motion.dart` - `FadeSlideIn` (stagger), `AnimatedCount`, `PopIn`.
* `widgets/rings.dart` - `PlateRing` (the hero), `MacroRing`, `FillBar`.
* `widgets/pt_segmented.dart` - segmented control with sliding thumb; choice chips.
* `widgets/confetti.dart` - food confetti layer.
* `widgets/empty_state.dart` - mascot + title + body + action.
* `mascot/sprout.dart` - Sprout.

## 4. Phases (each a local commit)

1. Plan (this doc).
2. Design system: tokens, font, theme, kit, Sprout, Appearance setting + strings, app shell and
   bottom navigation.
3. Today: plate ring, macro rings, meal sections, water, weight, activity, health card,
   empty state, celebrations, share sheet, copy-yesterday dialog.
4. Logging flow: add food (search / my foods / recipes), food detail, custom food, recipe
   builder, barcode, quick add, edit entry, log activity, all dialogs.
5. History, weekly insights, calendar, day sheet, weight trend; Premium paywall.
6. Goals / settings, TDEE sheet, health sync setting, onboarding.
7. Screenshot harness (`test/ui_shots_test.dart`, light + dark + 1.3x text), contact sheet
   `docs/ui_revamp/overview.png`, test updates.

## 5. Guard rails

* Keys, analytics event names, ad placements and the banner position (Scaffold
  `bottomNavigationBar`, never over content) are unchanged.
* `integration_test/` finds the nav by `Icons.calendar_month_outlined`, `Icons.flag_outlined`,
  `Icons.restaurant_menu_outlined` and the "Log food" label; the new nav keeps those icons.
* `lib/debug/` keeps its single guarded entry point (`debug_tools_isolation_test`).
* Every new string is added to all 8 ARB files (en, de, es, fr, it, ja, nl, pt).
* Text scaling checked at 1.3x; tap targets >= 48 dp; icon-only buttons have tooltips/semantics.

## 6. Status (done)

All phases landed as local commits. Visual proof: `docs/ui_revamp/overview.png`
(52 shots, light + dark + 1.3x text) and key shots in `docs/ui_revamp/shots/`.
Regenerate with:

```
flutter test --dart-define=UI_SHOTS=true test/ui_shots_test.dart
PYTHONIOENCODING=utf-8 python tool/ui_contact_sheet.py
```

Without the define the same test is a smoke test of every screen, sheet and
dialog. `test/widgets/kit_test.dart` covers the kit (tap targets, disabled and
loading buttons, reduce motion, appearance persistence) and the Today reactions
(new-entry toast, target-window celebration, no celebration on open).

Not restyled on purpose: the debug-only tools screen (`lib/debug/`, stripped
from release) inherits the new theme but keeps its plain developer layout; the
barcode camera screen cannot be rendered in a widget test, so it has no shot.

For the owner to decide / check on a device:

* Default theme is now **System** (was forced dark). Users on a light phone
  will see the light "kitchen table" look on first launch after the update.
* Celebration thresholds reuse the existing "on target" rule (85-110 % of the
  calorie goal) and the water goal; once per day each.
* Haptics: a selection click on logging actions (log buttons, meal/unit chips,
  water glasses).
* Check on a real phone: Rubik rendering, the barcode overlay cut-out, the
  sticky bottom buttons with the keyboard open, and frame rate of the plate
  ring + confetti on a low-end Android.
