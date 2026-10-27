# Turkish (tr) glossary and style guide

## Tone
- Friendly, concise, informal "sen" form (as Yazio, Fitbit TR and most Turkish health apps use). Never mix with "siz".
- Buttons and menu actions: bare imperative or noun ("Kaydet", "Ekle", "Hesapla", "Paylaş").
- Questions/confirmations: passive "-sın mı?" ("Kayıt silinsin mi?").
- Sentences speaking to the user use "sen" possessives (hedeflerini, öğünlerini).
- Exclamations only where English has them.

## Suffix rule for placeholders
Turkish suffixes depend on vowel harmony, so no suffix may follow a placeholder ({meal}, {food}, {name}, {n}, {kg}, {date}, {weight}, {sum}).
Use colon / parenthesis structures instead: "Ekle: {meal}", "Eklendi: {food} ({meal})", "hedef: {n}", "Son {days} gün: {delta}".
A number placeholder may be followed by a separate unit word ("{n} gün", "{count} porsiyon"). Turkish uses a singular noun after numerals, so plural branches are identical except for the number.
Percent is written as prefix: "%100", "%{sum}".

## Terms
| English | Turkish |
|---|---|
| calories / kcal | kalori / kcal |
| protein | protein |
| carbohydrate / carbs | karbonhidrat / karb. (short label only) |
| fat | yağ |
| macros | makrolar |
| serving / portion | porsiyon |
| recipe | tarif |
| ingredient | malzeme |
| streak | seri |
| favourites | favoriler |
| recent | son kullanılanlar |
| meal / breakfast / lunch / dinner / snack | öğün / kahvaltı / öğle yemeği / akşam yemeği / ara öğün |
| log (verb) | kaydet |
| goals | hedefler |
| history | geçmiş |
| weight (body) | kilo |
| weight trend | kilo trendi |
| water / glass | su / bardak |
| activity | aktivite |
| burned | yakılan |
| ad / ad-free | reklam / reklamsız |
| weekly insights | haftalık analizler |
| Health sync | Sağlık senkronu |
| barcode | barkod |
| custom food | özel yemek |
| TDEE, BMR, BMI | kept as-is (TDEE, BMR, BMI); TDEE explained once in tdeeSubtitle |
| Premium | Premium |
| Free trial | Ücretsiz deneme |
| Sprout (mascot) | Sprout |

## Brand names untouched
PlateSimple, Open Food Facts, Apple Health, Health Connect, Premium, HIIT, TDEE.
Apple's generic system app inside sentences ("Health prompt") is rendered "Sağlık" where it refers to the iOS Health app generically.
"PlateSimple'ı / PlateSimple'a" uses an apostrophe suffix after the fixed brand (not a placeholder), which is fine.

## Formatting
- Units exact: g, ml, kcal, %, "100 g", "7 günlük", "30 ve 90 günlük".
- Symbols kept: → ✓ ⭐ 🥗 · − ≈ … ★. Numbers unchanged. \n line breaks kept.
- Subscription/paywall copy stays legally literal: auto-renew, cancel anytime in device settings, no extra claims.

## Native-speaker check list
- "Karb." as the short macro label (macroCarbs) in tight UI.
- "Sağlık senkronu" and "Sağlık" as a generic name for the iOS Health app (connectHealth, healthSynced).
- "unitCup" = "Su bardağı" (Turkish measuring cup convention, about 200 ml) vs "Bardak".
- "activityExtra" = "Aşırı aktif"; "bmiObese" = "Obez" (clinical wording, same as English).
- "greetingAfternoon" = "İyi günler".
- "waterGoalToast" = "Şerefe!" (toast reference; confirm tone for water).
- "logAction" = "Kaydet" duplicates "save"; fine in context but check UI.
- Store keywords: oruç, zayıflama, barkod.
