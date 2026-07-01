import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../models/serving_unit.dart';
import '../../services/ad_service.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.item,
    required this.defaultMeal,
  });
  final FoodItem item;
  final MealType defaultMeal;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late MealType _meal = widget.defaultMeal;
  ServingUnit _unit = ServingUnit.grams;
  final _qtyCtrl = TextEditingController(text: '100');

  /// Serving amount resolved to grams (macros always compute from grams).
  double get _grams {
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '.')) ?? 0;
    return qty * _unit.gramsPerUnit;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _onUnitChanged(ServingUnit? u) {
    if (u == null || u == _unit) return;
    setState(() {
      _unit = u;
      // Reset to a sensible default for the new unit (100 g, or 1 of anything else).
      _qtyCtrl.text = u.defaultQuantity == u.defaultQuantity.roundToDouble()
          ? u.defaultQuantity.round().toString()
          : u.defaultQuantity.toString();
    });
  }

  double get _calories => widget.item.caloriesPer100 * _grams / 100;
  double get _protein => widget.item.proteinPer100 * _grams / 100;
  double get _carbs => widget.item.carbsPer100 * _grams / 100;
  double get _fat => widget.item.fatPer100 * _grams / 100;

  Future<void> _log() async {
    final store = context.read<FoodStore>();
    await store.logFood(widget.item, _grams, _meal);
    if (!mounted) return;

    // Pop navigation first, then show interstitial (once per session).
    Navigator.of(context)
      ..pop() // detail
      ..pop(); // add food

    await AdService.instance.showPostLogInterstitial(onComplete: () {});
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isFav = store.isFavourite(widget.item.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav ? Colors.amber : null),
            onPressed: () => store.toggleFavourite(widget.item),
            tooltip: isFav ? l10n.removeFavourite : l10n.addToFavourites,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.item.brand.isNotEmpty)
            Text(widget.item.brand,
                style: tt.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          // Serving size — quantity + unit (grams, tablespoon, cup, …).
          Text(l10n.servingSizeLabel,
              style: tt.labelLarge
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    suffixText: _unit == ServingUnit.grams ? 'g' : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<ServingUnit>(
                  value: _unit,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  onChanged: _onUnitChanged,
                  items: ServingUnit.values
                      .map((u) => DropdownMenuItem(
                            value: u,
                            child: Text(u.localizedLabel(l10n),
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          if (_unit.isApproximate) ...[
            const SizedBox(height: 6),
            Text(l10n.approxGrams(_grams.round()),
                style: tt.bodySmall?.copyWith(color: AppColors.textMuted)),
          ],
          const SizedBox(height: 24),

          // Macros card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _MacroRow(l10n.macroCalories, _calories, 'kcal',
                      AppColors.calories, bold: true),
                  const Divider(height: 20, color: AppColors.border),
                  _MacroRow(
                      l10n.macroProtein, _protein, 'g', AppColors.protein),
                  _MacroRow(l10n.macroCarbs, _carbs, 'g', AppColors.carbs),
                  _MacroRow(l10n.macroFat, _fat, 'g', AppColors.fat),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Meal picker
          Text(l10n.addToLabel,
              style: tt.labelLarge
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
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
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _log,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addToMeal(_meal.localizedLabel(l10n))),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow(this.label, this.value, this.unit, this.color,
      {this.bold = false});
  final String label, unit;
  final double value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontWeight:
                          bold ? FontWeight.w700 : FontWeight.normal))),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? color : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
