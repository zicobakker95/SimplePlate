import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/l10n.dart';
import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../services/food_store.dart';
import '../ui/kit.dart';

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
  return showPtSheet<double>(
    context,
    title: context.l10n.quickAddTitle,
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
      showPtToast(
        context,
        l10n.enterValidNumber,
        icon: Icons.error_outline_rounded,
        tone: PtToastTone.warning,
      );
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

  Widget _field(
    String label,
    TextEditingController ctrl,
    String suffix, {
    bool autofocus = false,
    Color? dot,
  }) {
    return TextField(
      controller: ctrl,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: dot == null
            ? null
            : Icon(Icons.circle, size: 12, color: dot),
        prefixIconConstraints: const BoxConstraints(minWidth: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.quickAddNameLabel,
            prefixIcon: const Icon(Icons.restaurant_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _kcalCtrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: PtText.number(20, color: p.text),
          decoration: InputDecoration(
            labelText: l10n.fieldCalories,
            suffixText: 'kcal',
            prefixIcon: Icon(
              Icons.local_fire_department_rounded,
              color: p.fresh,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.optionalMacros.toUpperCase(),
          style: PtText.label(color: p.textMuted),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _field(
                l10n.macroProtein,
                _proteinCtrl,
                'g',
                dot: p.protein,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _field(l10n.macroCarbs, _carbsCtrl, 'g', dot: p.carbs),
            ),
            const SizedBox(width: 8),
            Expanded(child: _field(l10n.macroFat, _fatCtrl, 'g', dot: p.fat)),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in MealType.values)
              PtChoiceChip(
                label: m.localizedLabel(l10n),
                leading: m.emoji,
                selected: _meal == m,
                onTap: () => setState(() => _meal = m),
              ),
          ],
        ),
        const SizedBox(height: 20),
        PtButton(
          label: l10n.logAction,
          icon: Icons.bolt_rounded,
          expand: true,
          haptic: true,
          loading: _saving,
          onPressed: _saving ? null : _log,
        ),
      ],
    );
  }
}
