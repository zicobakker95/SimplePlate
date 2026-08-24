import '../l10n/app_localizations.dart';

/// Formats an amount as grams, plus the serving equivalent when the food
/// declares one: `100 g (2 servings)`.
///
/// Requested by a user who was happy entering grams but could not tell what
/// that meant in servings. Grams stay the primary unit everywhere — the
/// serving count is only ever an addition in brackets, never a replacement,
/// because most foods have no declared serving size and a screen that
/// sometimes says grams and sometimes says servings is worse than one that
/// always says grams.
String gramsWithServings(
  AppLocalizations l10n,
  double grams,
  double? servingSizeGrams,
) {
  final base = '${grams.round()} g';
  final servings = servingLabel(l10n, grams, servingSizeGrams);
  return servings == null ? base : '$base ($servings)';
}

/// "2 servings" / "1 serving", localized, or null when the food declares no
/// serving size — which is the common case, so every caller must handle null.
String? servingLabel(
  AppLocalizations l10n,
  double grams,
  double? servingSizeGrams,
) {
  if (servingSizeGrams == null || servingSizeGrams <= 0) return null;
  final n = grams / servingSizeGrams;
  if (!n.isFinite || n <= 0) return null;
  final text = formatServings(n);
  return text == '1' ? l10n.servingOne : l10n.servingMany(text);
}

/// One decimal place, with a trailing `.0` stripped: 2, 1.5, 0.5.
///
/// Kept as a string so "2" never renders as "2.0" and 1.5 never becomes
/// "1.500000".
String formatServings(double n) {
  final rounded = (n * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) return rounded.round().toString();
  return rounded.toStringAsFixed(1);
}
