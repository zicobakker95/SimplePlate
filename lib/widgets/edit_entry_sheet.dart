import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/food_entry.dart';
import '../services/food_store.dart';
import '../ui/kit.dart';
import '../utils/serving_format.dart';

/// Bottom sheet for changing the serving size of an existing [FoodEntry].
///
/// Shared by the Today screen and the history day sheet so editing behaves
/// identically wherever the user finds the entry.
Future<void> showEditEntrySheet(BuildContext context, FoodEntry entry) {
  return showPtSheet<void>(
    context,
    builder: (_) => _EditEntrySheet(entry: entry),
  );
}

/// Confirmation dialog shown before an entry is removed.
Future<bool?> confirmDeleteEntry(BuildContext context, FoodEntry entry) {
  final l10n = context.l10n;
  return showPtConfirm(
    context,
    title: l10n.deleteEntryTitle,
    body: l10n.deleteEntryBody(entry.foodName, entry.meal.localizedLabel(l10n)),
    confirmLabel: l10n.delete,
    cancelLabel: l10n.cancel,
    icon: Icons.delete_outline_rounded,
    destructive: true,
  );
}

class _EditEntrySheet extends StatefulWidget {
  const _EditEntrySheet({required this.entry});
  final FoodEntry entry;

  @override
  State<_EditEntrySheet> createState() => _EditEntrySheetState();
}

class _EditEntrySheetState extends State<_EditEntrySheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.entry.servingGrams.round().toString(),
    );
    // Live-preview the recalculated totals as the user types.
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double? get _grams {
    final g = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    return (g != null && g > 0) ? g : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final e = widget.entry;
    final grams = _grams ?? e.servingGrams;
    final factor = grams / 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.sunken,
                shape: BoxShape.circle,
              ),
              child: Text(e.meal.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.foodName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PtText.headline(color: p.text),
                  ),
                  if (e.foodBrand.isNotEmpty)
                    Text(e.foodBrand, style: PtText.small(color: p.textMuted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: PtText.number(20, color: p.text),
          decoration: InputDecoration(
            labelText: l10n.servingSizeLabel,
            suffixText: 'g',
          ),
        ),
        // Same serving equivalent the log screen shows, so editing an entry
        // reads the same way as creating one. Uses the size snapshotted on
        // the entry, not the food, so an old entry keeps its own meaning.
        if (servingLabel(l10n, grams, e.servingSizeGrams) != null) ...[
          const SizedBox(height: 8),
          Text(
            gramsWithServings(l10n, grams, e.servingSizeGrams),
            style: PtText.small(color: p.textMuted),
          ),
        ],
        const SizedBox(height: 16),
        // Live preview of what this serving works out to.
        NutrientRow(
          calories: e.caloriesPer100 * factor,
          protein: e.proteinPer100 * factor,
          carbs: e.carbsPer100 * factor,
          fat: e.fatPer100 * factor,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: PtButton(
                label: l10n.cancel,
                tone: PtButtonTone.outline,
                expand: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PtButton(
                label: l10n.update,
                expand: true,
                haptic: true,
                onPressed: _grams == null
                    ? null
                    : () {
                        context.read<FoodStore>().updateEntryServing(
                          e.id,
                          _grams!,
                        );
                        Navigator.pop(context);
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Calories + the three macros as four soft tiles; numbers count as they
/// change. Used wherever a serving is previewed.
class NutrientRow extends StatelessWidget {
  const NutrientRow({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double calories, protein, carbs, fat;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l10n = context.l10n;
    Widget tile(
      String label,
      double v,
      String unit,
      Color color,
      Color ink, {
      bool decimals = true,
    }) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: p.isDark ? 0.16 : 0.12),
          borderRadius: BorderRadius.circular(Pt.rSm),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedCount(
                value: v,
                duration: const Duration(milliseconds: 350),
                format: (x) =>
                    decimals ? x.toStringAsFixed(1) : x.round().toString(),
                style: PtText.number(18, color: ink),
              ),
            ),
            Text(unit, style: PtText.tiny(color: p.textMuted)),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PtText.tiny(color: p.text, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
    return Row(
      children: [
        tile(
          l10n.macroCalories,
          calories,
          'kcal',
          p.fresh,
          p.primary,
          decimals: false,
        ),
        tile(l10n.macroProtein, protein, 'g', p.protein, p.proteinInk),
        tile(l10n.macroCarbs, carbs, 'g', p.carbs, p.carbsInk),
        tile(l10n.macroFat, fat, 'g', p.fat, p.fatInk),
      ],
    );
  }
}
