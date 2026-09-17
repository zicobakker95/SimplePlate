# PlateSimple — user acquisition drafts (Sept 2026)

Prepared after the July–Sept test: **€40.36 for 224 LATAM Android installs at
€0.18, and not one measured in-app action**. The account measures installs
only — six conversion actions, all "(Android) installs", all worth €0.00 — so
a campaign optimising on that buys the cheapest install on earth. The app now
sends the Firebase standard `purchase` event with the store's price and
currency (commit 466f548), which is what these campaigns should eventually
bid toward.

## Both drafts

| | iOS draft | Android draft |
|---|---|---|
| Markets | NL, BE, DE | NL, BE, DE |
| Languages | Dutch, German, English | Dutch, German, English |
| Budget | €10/day | €8/day |
| Bidding | Target cost per install | Target cost per install |
| Expected CPI | €2–4 (Deadlight iOS ES/MX/AR ran €1.18; EU is dearer) | €0.60–1.50 (LATAM was €0.18 and worthless) |
| Status at creation | **Paused** | **Paused** |

Why these markets: Open Food Facts, the food database behind search, is
strongest in Europe and thinnest in LATAM — the miss rate in the first
session is what a calorie tracker lives or dies on. It is also where a
subscription is priced for local income. iOS goes first because the iOS
listing carries no ratings at all, while the Play listing sits at 3.3.

Do not raise budgets or switch to a purchase-based bid until the `purchase`
conversion has been imported and has collected roughly 30 events.

## Ad copy

Headlines are capped at 30 characters, descriptions at 90.

### English

Headlines
- Calorie tracking, simple
- Scan a barcode, log a meal
- Track calories in seconds
- Your macros at a glance
- Log food, see progress

Descriptions
- Scan barcodes, search foods and log meals in seconds. Calories and macros at a glance.
- Set your goal with the built-in TDEE calculator, then watch the calorie ring close.
- Build a recipe once and log it with one tap. Tracking simple enough to keep up.
- Calories, protein, carbs and fat, without the clutter of a full nutrition app.

### Dutch (NL, BE)

Headlines
- Calorieën tellen, simpel
- Scan een streepjescode
- Log een maaltijd in tellen
- Je macro's in één blik
- Eet bewust, zie vooruitgang

Descriptions
- Scan streepjescodes, zoek producten en log maaltijden in tellen. Calorieën in één blik.
- Stel je doel in met de TDEE-calculator en zie je caloriering elke dag dichtgaan.
- Maak een recept één keer aan en log het met één tik. Simpel genoeg om vol te houden.
- Calorieën, eiwit, koolhydraten en vet, zonder de rommel van een grote voedings-app.

### German (DE)

Headlines
- Kalorien zählen, einfach
- Barcode scannen, fertig
- Mahlzeit in Sekunden
- Deine Makros auf einen Blick
- Iss bewusst, sieh Fortschritt

Descriptions
- Barcode scannen, Lebensmittel suchen, Mahlzeit in Sekunden loggen. Kalorien auf einen Blick.
- Setz dein Ziel mit dem TDEE-Rechner und sieh zu, wie sich der Kalorienring schließt.
- Rezept einmal anlegen, mit einem Tipp loggen. Einfach genug, um dranzubleiben.
- Kalorien, Eiweiß, Kohlenhydrate und Fett, ohne den Ballast großer Ernährungs-Apps.

## Before anything goes live

1. Ship 1.1 (the search fix) — the first session decides everything after it.
2. Import the `purchase` event as a conversion with value, both platforms.
3. Complete advertiser verification (due 13 Oct) or ads get limited.
4. Then unpause iOS first, two weeks, and read cost per install against
   subscribers rather than installs.
