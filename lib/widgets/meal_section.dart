import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/food_entry.dart';
import '../ui/kit.dart';
import '../utils/serving_format.dart';
import 'edit_entry_sheet.dart';

/// One meal of the day (Breakfast / Lunch / Dinner / Snack): a header with
/// the meal's total and an add button, then its entries. New entries pop in;
/// swiping one left deletes it after a confirmation.
class MealSection extends StatelessWidget {
  const MealSection({
    super.key,
    required this.meal,
    required this.entries,
    required this.onAdd,
    required this.onDelete,
    this.fresh = const {},
  });

  final MealType meal;
  final List<FoodEntry> entries;
  final VoidCallback onAdd;
  final void Function(String entryId) onDelete;

  /// Ids logged while the screen was open; they animate in.
  final Set<String> fresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final cals = entries.fold<double>(0, (s, e) => s + e.calories);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PtCard(
        padding: EdgeInsets.zero,
        clip: true,
        child: Column(
          children: [
            // Header: the whole row adds to this meal.
            Pressable(
              onTap: onAdd,
              pressedScale: 0.98,
              semanticLabel: '${meal.localizedLabel(l10n)}, ${l10n.add}',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _tint(p),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        meal.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.localizedLabel(l10n),
                            style: PtText.headline(
                              color: p.text,
                            ).copyWith(fontSize: 16),
                          ),
                          Text(
                            entries.isEmpty
                                ? l10n.mealEmptyHint
                                : l10n.itemsCount(entries.length),
                            style: PtText.tiny(color: p.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (cals > 0)
                      AnimatedCount(
                        value: cals,
                        format: (v) => '${v.round()} kcal',
                        style: PtText.number(14, color: p.primary),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: p.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: p.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (entries.isNotEmpty) PtDivider(indent: 0),
            for (final entry in entries)
              PopIn(
                key: ValueKey('pop-${entry.id}'),
                enabled: fresh.contains(entry.id),
                child: EntryRow(
                  entry: entry,
                  highlight: fresh.contains(entry.id),
                  onDelete: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _tint(PlatePalette p) => switch (meal) {
    MealType.breakfast => p.honeySoft,
    MealType.lunch => p.freshSoft,
    MealType.dinner => p.protein.withValues(alpha: 0.16),
    MealType.snack => p.dangerSoft,
  };
}

/// One logged food: name, amount, macro dots and calories. Tap edits,
/// swipe left deletes (after a confirmation). Shared with the history day
/// sheet so an entry behaves the same wherever it is found.
class EntryRow extends StatelessWidget {
  const EntryRow({
    super.key,
    required this.entry,
    required this.onDelete,
    this.highlight = false,
  });

  final FoodEntry entry;
  final void Function(String entryId) onDelete;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        color: p.danger,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => confirmDeleteEntry(context, entry),
      onDismissed: (_) => onDelete(entry.id),
      child: TweenAnimationBuilder<double>(
        // A just-logged row glows green and fades back to the card.
        tween: Tween(begin: highlight ? 1 : 0, end: 0),
        duration: const Duration(milliseconds: 1600),
        curve: Curves.easeOut,
        builder: (context, glow, child) => Container(
          color: Color.lerp(p.surface, p.freshSoft, glow),
          child: child,
        ),
        child: PtTile(
          // Tap as well as long-press. Editing a past entry was already
          // possible but only on long-press, with nothing to suggest it --
          // a user emailed twice to ask for a feature the app already had.
          onTap: () => showEditEntrySheet(context, entry),
          onLongPress: () => showEditEntrySheet(context, entry),
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
          title: entry.foodName,
          titleMaxLines: 1,
          subtitle: gramsWithServings(
            l10n,
            entry.servingGrams,
            entry.servingSizeGrams,
          ),
          subtitleMaxLines: 1,
          below: MacroDots(
            protein: entry.protein,
            carbs: entry.carbs,
            fat: entry.fat,
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.calories.round()} kcal',
                style: PtText.number(14, color: p.text),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tapToEdit,
                style: PtText.tiny(color: p.textMuted).copyWith(fontSize: 9.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "P 12 · C 30 · F 4" with each letter in its macro colour.
class MacroDots extends StatelessWidget {
  const MacroDots({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double protein, carbs, fat;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    TextSpan part(String k, double v, Color c) => TextSpan(
      children: [
        TextSpan(
          text: k,
          style: TextStyle(color: c, fontWeight: FontWeight.w700),
        ),
        TextSpan(text: ' ${v.toStringAsFixed(1)}g'),
      ],
    );
    return Text.rich(
      TextSpan(
        style: PtText.tiny(color: p.textMuted),
        children: [
          part('P', protein, p.proteinInk),
          const TextSpan(text: '  '),
          part('C', carbs, p.carbsInk),
          const TextSpan(text: '  '),
          part('F', fat, p.fatInk),
        ],
      ),
      maxLines: 1,
    );
  }
}
