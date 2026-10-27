# PlateSimple – Polish (pl) glossary and style guide

## Tone
- Friendly, concise, modern. Address the user informally ("Ty"), with lowercase-initial possessives except the capitalised "Twój/Twoje" used in UI strings, as in Fitatu/Yazio PL.
- Buttons and actions: imperative ("Dodaj", "Zapisz", "Skanuj"). Confirm questions: infinitive ("Usunąć wpis?").
- Avoid gendered wording about the user (no "zjadłeś/zjadłaś", "aktywny/aktywna"); use imperative, impersonal or noun forms ("Wysoka aktywność", "Zapisano dziś").
- Never put a case-inflected noun after a placeholder: use colon structures ("Dodaj do: {meal}", "Dodano: {food} · {meal}", "Usunąć \"{name}\" z: {meal}?").

## Terms
| English | Polish |
|---|---|
| calories / kcal | kalorie / kcal |
| protein | białko |
| carbs / carbohydrates | węglowodany (short: Węglow.) |
| fat | tłuszcz |
| macros | makroskładniki / makro (short) |
| serving | porcja |
| recipe | przepis |
| ingredients | składniki |
| streak | seria |
| favourites | ulubione |
| goal | cel |
| weight (tracking) / body weight | waga / masa ciała |
| log (verb) | zapisz / dodaj |
| History / Today / Goals | Historia / Dziś / Cele |
| weekly insights | tygodniowe podsumowania |
| weight trend | trend wagi |
| health sync | synchronizacja zdrowia |
| ad / ad-free | reklama / bez reklam |
| barcode | kod kreskowy |
| custom food | własny produkt |
| Breakfast / Lunch / Dinner / Snack | Śniadanie / Obiad / Kolacja / Przekąska |
| subscription / cancel anytime | subskrypcja / anuluj w dowolnym momencie |
| free trial | bezpłatny okres próbny |
| Privacy Policy / Terms of Use | Polityka prywatności / Warunki korzystania |

## Untouched brand / technical names
PlateSimple, Open Food Facts, Apple Health, Health Connect, Premium, TDEE, BMI, BMR, HIIT, CSV, JSON, Sprout.

## Formatting
- Units exact: g, ml, kcal, %, "100 g", "7 dni", "30 i 90 dni".
- Numbers and symbols unchanged (→ ✓ ⭐ 🥗 · − ≈ …). Decimal comma in prose only if the source has none to keep (values come from code).
- Plurals: ICU `=1 / few / many / other` (few = 2-4, many = 5+, other repeats many).
- Quotes: Polish „…” in prose; ASCII \"…\" kept where the source uses an escaped quote around a placeholder.
