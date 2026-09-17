import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/l10n.dart';
import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../services/food_store.dart';
import '../theme/app_colors.dart';

/// Logs a calorie figure straight into a meal, with optional macros — for
/// the restaurant plate and the friend's cooking that no database will ever
/// have. Returns the logged [FoodEntry]'s calories, or null when dismissed.
///
/// The entry is stored as a 100 g serving of a food whose per-100 g values
/// are the typed totals, so the arithmetic everywhere else stays untouched.
Future<double?> showQuickAddSheet(
  BuildContext context, {
  required MealType defaultMeal,
  String? initialName,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) =>
        _QuickAddSheet(defaultMeal: defaultMeal, initialName: initialName),
  );
}

class _QuickAddSheet extends StatefulWidget {
  const _QuickAddSheet({required this.defaultMeal, this.initialName});
  final MealType defaultMeal;
  final String? initialName;

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  late final _nameCtrl = TextEditingController(text: widget.initialName ?? '');
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  late MealType _meal = widget.defaultMeal;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kcalCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  Future<void> _log() async {
    final l10n = context.l10n;
    final kcal = _num(_kcalCtrl);
    if (kcal <= 0 || kcal > 20000) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.enterValidNumber)));
      return;
    }
    setState(() => _saving = true);
    final name = _nameCtrl.text.trim();
    final item = FoodItem(
      id: 'quick-${const Uuid().v4()}',
      name: name.isEmpty ? l10n.quickAddTitle : name,
      caloriesPer100: kcal,
      proteinPer100: _num(_proteinCtrl),
      carbsPer100: _num(_carbsCtrl),
      fatPer100: _num(_fatCtrl),
      isCustom: true,
    );
    await context.read<FoodStore>().logFood(item, 100, _meal);
    if (!mounted) return;
    Navigator.of(context).pop(kcal);
  }

  Widget _field(String label, TextEditingController ctrl, String suffix,
      {bool autofocus = false}) {
    return TextField(
      controller: ctrl,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.quickAddTitle,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.quickAddNameLabel),
            ),
            const SizedBox(height: 12),
            _field(l10n.fieldCalories, _kcalCtrl, 'kcal', autofocus: true),
            const SizedBox(height: 16),
            Text(l10n.optionalMacros,
                style: tt.labelLarge?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _field(l10n.macroProtein, _proteinCtrl, 'g')),
                const SizedBox(width: 8),
                Expanded(child: _field(l10n.macroCarbs, _carbsCtrl, 'g')),
                const SizedBox(width: 8),
                Expanded(child: _field(l10n.macroFat, _fatCtrl, 'g')),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: MealType.values
                  .map((m) => ChoiceChip(
                        label: Text('${m.emoji} ${m.localizedLabel(l10n)}'),
                        selected: _meal == m,
                        onSelected: (_) => setState(() => _meal = m),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceAlt,
                        labelStyle: TextStyle(
                            color: _meal == m
                                ? Colors.white
                                : AppColors.textSecondary),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _log,
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: Text(l10n.logAction),
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
