import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/food_entry.dart';
import '../services/food_store.dart';
import '../theme/app_colors.dart';

/// Collapsible meal section card (Breakfast / Lunch / Dinner / Snack).
class MealSection extends StatelessWidget {
  const MealSection({
    super.key,
    required this.meal,
    required this.entries,
    required this.onAdd,
    required this.onDelete,
  });

  final MealType meal;
  final List<FoodEntry> entries;
  final VoidCallback onAdd;
  final void Function(String entryId) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cals = entries.fold<double>(0, (s, e) => s + e.calories);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Column(
          children: [
            // Header row
            InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              onTap: onAdd,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(meal.emoji,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(meal.localizedLabel(l10n),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    if (cals > 0)
                      Text('${cals.round()} kcal',
                          style: const TextStyle(
                              color: AppColors.calories,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    const SizedBox(width: 8),
                    const Icon(Icons.add_circle_outline_rounded,
                        size: 20, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            // Entries
            if (entries.isNotEmpty)
              const Divider(height: 1, color: AppColors.border),
            for (final entry in entries)
              Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                  ),
                  child: const Icon(Icons.delete_rounded,
                      color: Colors.white),
                ),
                confirmDismiss: (_) => showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.deleteEntryTitle),
                    content: Text(l10n.deleteEntryBody(
                        entry.foodName, entry.meal.localizedLabel(l10n))),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.danger),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                ),
                onDismissed: (_) => onDelete(entry.id),
                child: ListTile(
                  dense: true,
                  onLongPress: () => _showEditSheet(context, entry),
                  title: Text(entry.foodName,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${entry.servingGrams.round()} g'
                    '  ·  P ${entry.protein.toStringAsFixed(1)}g'
                    '  C ${entry.carbs.toStringAsFixed(1)}g'
                    '  F ${entry.fat.toStringAsFixed(1)}g',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${entry.calories.round()} kcal',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.calories,
                              fontWeight: FontWeight.w600)),
                      Text(l10n.holdToEdit,
                          style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted)),
                    ],
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void _showEditSheet(BuildContext context, FoodEntry entry) {
  final l10n = context.l10n;
  final ctrl =
      TextEditingController(text: entry.servingGrams.round().toString());

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.foodName,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (entry.foodBrand.isNotEmpty)
            Text(entry.foodBrand,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.servingSizeLabel,
              suffixText: 'g',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final grams = double.tryParse(ctrl.text);
                    if (grams != null && grams > 0) {
                      context
                          .read<FoodStore>()
                          .updateEntryServing(entry.id, grams);
                      Navigator.pop(sheetCtx);
                    }
                  },
                  child: Text(l10n.update),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
