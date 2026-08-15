# Health Connect declaration — PlateSimple

Copy-paste source for the Play Console **Health apps declaration**
(App content → Health apps). Rewritten 2026-08-15 after the
"Insufficient Information to Determine App Functionality" rejection.

Two rules that decided everything below: name the *feature the user
sees*, not the abstract benefit; and request nothing the feature does
not need. Reviewers reject "to give users insights" — it describes an
intention, not a function.

---

## Core functionality (paste into the app-description / functionality box)

```
PlateSimple is a food and calorie diary. The user logs the meals they
eat by searching a food database, scanning a barcode, or entering a
custom food, and the app adds up calories, protein, carbohydrates and
fat for each day against a daily goal the user sets.

Health Connect is used for one screen: the "Today" screen shows
calories eaten (from the user's own food log) next to calories burned
through activity (read from Health Connect), so the user can see
whether they ate more or less than they spent. Nothing else in the app
reads health data.
```

## READ — ActiveCaloriesBurned

```
Used by the "Calories burned" figure on the Today screen and in the
weekly summary.

PlateSimple records what the user eats but does not track activity
itself — it has no pedometer, no workout tracking and no sensor access.
Without this permission the app knows calories in but not calories out,
and the energy-balance view that the app exists to provide cannot be
shown. Reading active calories burned from Health Connect lets a
figure the user's fitness tracker already recorded appear next to the
food they logged, instead of asking them to type it in a second time.

Only today's and the current week's totals are read, only while the
user has the Today or Summary screen open. The value is displayed and
used for that day's arithmetic; it is not stored on any server. The
app has no accounts and no backend — all data stays on the device.
```

## WRITE — Nutrition

```
Used by the "Sync to Health Connect" toggle in Settings.

When the user turns it on, the calories, protein, carbohydrates and
fat from the meals they logged in PlateSimple are written to Health
Connect once per day, so their nutrition appears alongside data from
their other health apps. Only food the user entered themselves is
written. Nothing is written when the toggle is off.
```

---

## What changed in the app (state this in the appeal/resubmission note)

`TotalCaloriesBurned` has been **removed from the manifest** in
**1.0.10+26**. Total calories = active + basal, and basal energy is
the body at rest, which a food diary cannot act on. Active calories
alone are what the energy-balance screen needs.

The remaining Health Connect permissions are exactly two:

| Permission | Direction | Feature |
|---|---|---|
| `READ_ACTIVE_CALORIES_BURNED` | read | "Calories burned" on Today + weekly summary |
| `WRITE_NUTRITION` | write | "Sync to Health Connect" toggle in Settings |

History of narrowing, if the reviewer asks:

- **1.0.8+24** — dropped the Android `Steps` read after the first review.
- **1.0.10+26** — dropped `TotalCaloriesBurned` after this review.

## Order of operations

The declaration is checked against the **manifest of the build under
review**. Uploading the declaration while a build that still contains
`READ_TOTAL_CALORIES_BURNED` is the active artifact will fail again on
the same point.

1. Build and upload **1.0.10+26**.
2. Roll it out (or at least make it the artifact in review — see
   [[play-console-draft-vs-rollout]]: an uploaded-but-Draft release is
   not the active artifact).
3. Then submit the Health apps declaration with the text above.
