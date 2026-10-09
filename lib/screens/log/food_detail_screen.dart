import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../models/serving_unit.dart';
import '../../services/ad_service.dart';
import '../../services/food_store.dart';
import '../../ui/kit.dart';
import '../../utils/serving_format.dart';
import '../../widgets/edit_entry_sheet.dart';

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
  bool _logging = false;

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
    setState(() => _logging = true);
    final store = context.read<FoodStore>();
    // Never ask for a review on the tap that opens an interstitial.
    await store.logFood(
      widget.item,
      _grams,
      _meal,
      promptReview: !AdService.instance.postLogInterstitialDue,
    );
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
    final l10n = context.l10n;
    final p = context.pal;
    final item = widget.item;
    final isFav = store.isFavourite(item.id);

    var i = 0;
    Widget enter(Widget child) => FadeSlideIn(index: i++, child: child);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Bump(
            trigger: isFav,
            child: PtIconButton(
              icon: isFav ? Icons.star_rounded : Icons.star_border_rounded,
              tooltip: isFav ? l10n.removeFavourite : l10n.addToFavourites,
              background: Colors.transparent,
              color: isFav ? p.honey : p.text,
              onPressed: () => store.toggleFavourite(item),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Pt.gutter, 4, Pt.gutter, 24),
        children: [
          // Hero: where the calories come from, and what this amount costs.
          enter(
            PtCard(
              radius: Pt.rLg,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  MacroSplitRing(
                    protein: item.proteinPer100,
                    carbs: item.carbsPer100,
                    fat: item.fatPer100,
                    size: 104,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedCount(
                          value: _calories,
                          duration: const Duration(milliseconds: 350),
                          style: PtText.number(24, color: p.text),
                        ),
                        Text('kcal', style: PtText.tiny(color: p.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: PtText.headline(color: p.text),
                        ),
                        if (item.brand.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.brand,
                            style: PtText.small(color: p.textMuted),
                          ),
                        ],
                        const SizedBox(height: 10),
                        PtTag(
                          label: '${item.caloriesPer100.round()} kcal / 100 g',
                          color: p.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Serving size — quantity + unit (grams, tablespoon, cup, …).
          PtSectionHeader(l10n.servingSizeLabel),
          enter(
            TextField(
              controller: _qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: PtText.number(22, color: p.text),
              decoration: InputDecoration(
                suffixText: _unit == ServingUnit.grams
                    ? 'g'
                    : _unit.localizedLabel(l10n),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 10),
          enter(
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final u in ServingUnit.values)
                  PtChoiceChip(
                    label: u.localizedLabel(l10n),
                    selected: _unit == u,
                    onTap: () => _onUnitChanged(u),
                  ),
              ],
            ),
          ),
          // What the typed amount works out to in servings, when the food
          // declares a serving size. Grams remain the number you enter; this
          // only says what it means. It replaces the approximate-grams line
          // rather than stacking under it, so there is never a second gram
          // figure directly beneath the first.
          if (servingLabel(l10n, _grams, item.servingSizeGrams) != null) ...[
            const SizedBox(height: 8),
            Text(
              gramsWithServings(l10n, _grams, item.servingSizeGrams),
              style: PtText.small(color: p.textMuted),
            ),
          ] else if (_unit.isApproximate) ...[
            const SizedBox(height: 8),
            Text(
              l10n.approxGrams(_grams.round()),
              style: PtText.small(color: p.textMuted),
            ),
          ],
          const SizedBox(height: 16),

          // Live macros for this amount.
          enter(
            NutrientRow(
              calories: _calories,
              protein: _protein,
              carbs: _carbs,
              fat: _fat,
            ),
          ),

          // Meal picker
          PtSectionHeader(l10n.addToLabel),
          enter(
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
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Pt.gutter, 8, Pt.gutter, 12),
          child: PtButton(
            label: l10n.addToMeal(_meal.localizedLabel(l10n)),
            icon: Icons.add_rounded,
            expand: true,
            haptic: true,
            loading: _logging,
            onPressed: _logging ? null : _log,
          ),
        ),
      ),
    );
  }
}
