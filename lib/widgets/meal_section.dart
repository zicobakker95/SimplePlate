import 'package:flutter/material.dart';

import '../models/food_entry.dart';
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
                    Text(meal.label,
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
                onDismissed: (_) => onDelete(entry.id),
                child: ListTile(
                  dense: true,
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
                  trailing: Text('${entry.calories.round()} kcal',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.calories,
                          fontWeight: FontWeight.w600)),
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
