import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/food_entry.dart';
import '../services/food_store.dart';
import '../theme/app_colors.dart';
import '../utils/serving_format.dart';

/// Bottom sheet for changing the serving size of an existing [FoodEntry].
///
/// Shared by the Today screen and the history day sheet so editing behaves
/// identically wherever the user finds the entry.
Future<void> showEditEntrySheet(BuildContext context, FoodEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _EditEntrySheet(entry: entry),
  );
}

/// Confirmation dialog shown before an entry is removed.
Future<bool?> confirmDeleteEntry(BuildContext context, FoodEntry entry) {
  final l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteEntryTitle),
      content: Text(
          l10n.deleteEntryBody(entry.foodName, entry.meal.localizedLabel(l10n))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
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
        text: widget.entry.servingGrams.round().toString());
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
    final e = widget.entry;
    final grams = _grams ?? e.servingGrams;
    final factor = grams / 100;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.foodName,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (e.foodBrand.isNotEmpty)
            Text(e.foodBrand,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 14),
          // Live preview of what this serving works out to.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Preview(l10n.macroCalories,
                  (e.caloriesPer100 * factor).round().toString(), 'kcal',
                  AppColors.calories),
              _Preview(
                  l10n.macroProtein,
                  (e.proteinPer100 * factor).toStringAsFixed(1),
                  'g',
                  AppColors.protein),
              _Preview(l10n.macroCarbs,
                  (e.carbsPer100 * factor).toStringAsFixed(1), 'g',
                  AppColors.carbs),
              _Preview(l10n.macroFat,
                  (e.fatPer100 * factor).toStringAsFixed(1), 'g', AppColors.fat),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _grams == null
                      ? null
                      : () {
                          context
                              .read<FoodStore>()
                              .updateEntryServing(e.id, _grams!);
                          Navigator.pop(context);
                        },
                  child: Text(l10n.update),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview(this.label, this.value, this.unit, this.color);
  final String label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: color, fontSize: 16)),
        Text(unit,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}
