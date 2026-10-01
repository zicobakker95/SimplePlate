import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/l10n.dart';
import '../../models/food_item.dart';
import '../../models/recipe.dart';
import '../../services/food_store.dart';
import '../../ui/kit.dart';
import 'add_food_screen.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key, this.existing});

  final Recipe? existing;

  static Route<void> route({Recipe? existing}) =>
      MaterialPageRoute(builder: (_) => CreateRecipeScreen(existing: existing));

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '1');

  final List<_EditableIngredient> _ingredients = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    if (r != null) {
      _nameCtrl.text = r.name;
      _descCtrl.text = r.description;
      _servingsCtrl.text = r.servings.toString();
      _ingredients.addAll(
        r.ingredients.map(
          (i) => _EditableIngredient(
            item: i.item,
            gramsCtrl: TextEditingController(text: i.grams.round().toString()),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _servingsCtrl.dispose();
    for (final i in _ingredients) {
      i.gramsCtrl.dispose();
    }
    super.dispose();
  }

  double _sum(double Function(FoodItem) per100) => _ingredients.fold(
    0,
    (s, i) =>
        s + per100(i.item) * (double.tryParse(i.gramsCtrl.text) ?? 0) / 100,
  );

  double get _totalCalories => _sum((f) => f.caloriesPer100);
  double get _totalProtein => _sum((f) => f.proteinPer100);
  double get _totalCarbs => _sum((f) => f.carbsPer100);
  double get _totalFat => _sum((f) => f.fatPer100);

  int get _servings => int.tryParse(_servingsCtrl.text) ?? 1;

  void _stepServings(int delta) {
    final next = (_servings + delta).clamp(1, 99);
    setState(() => _servingsCtrl.text = '$next');
  }

  Future<void> _pickIngredient() async {
    final item = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(builder: (_) => const AddFoodScreen(pickMode: true)),
    );
    if (item == null) return;
    setState(() {
      _ingredients.add(
        _EditableIngredient(
          item: item,
          gramsCtrl: TextEditingController(text: '100'),
          isNew: true,
        ),
      );
    });
  }

  void _warn(String message) => showPtToast(
    context,
    message,
    icon: Icons.error_outline_rounded,
    tone: PtToastTone.warning,
  );

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _warn(context.l10n.recipeNameRequired);
      return;
    }
    if (_ingredients.isEmpty) {
      _warn(context.l10n.addAtLeastOne);
      return;
    }

    final recipe = Recipe(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: name,
      description: _descCtrl.text.trim(),
      servings: _servings.clamp(1, 99),
      ingredients: _ingredients
          .map(
            (i) => RecipeIngredient(
              item: i.item,
              grams: double.tryParse(i.gramsCtrl.text) ?? 100,
            ),
          )
          .toList(),
    );

    setState(() => _saving = true);
    await context.read<FoodStore>().saveRecipe(recipe);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final s = _servings.clamp(1, 99);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null
              ? l10n.createRecipeTitle
              : l10n.editRecipeTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Pt.gutter, 4, Pt.gutter, 24),
        children: [
          FadeSlideIn(
            child: PtCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.recipeNameLabel,
                      prefixIcon: const Icon(Icons.restaurant_menu_rounded),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.recipeDescLabel,
                      prefixIcon: const Icon(Icons.notes_rounded),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _servingsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.servingsLabel,
                            prefixIcon: const Icon(
                              Icons.people_outline_rounded,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 6),
                      PtIconButton(
                        icon: Icons.remove_rounded,
                        tooltip: '−1',
                        background: p.sunken,
                        onPressed: s > 1 ? () => _stepServings(-1) : null,
                      ),
                      PtIconButton(
                        icon: Icons.add_rounded,
                        tooltip: '+1',
                        background: p.primarySoft,
                        color: p.primary,
                        onPressed: s < 99 ? () => _stepServings(1) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PtSectionHeader(
            l10n.ingredients,
            trailing: PtButton(
              label: l10n.add,
              icon: Icons.add_rounded,
              tone: PtButtonTone.soft,
              compact: true,
              onPressed: _pickIngredient,
            ),
          ),
          if (_ingredients.isEmpty)
            PtCard(
              child: PtEmptyState(
                mood: SproutMood.hungry,
                mascotSize: 72,
                padding: const EdgeInsets.symmetric(vertical: 8),
                title: l10n.noIngredientsYet,
              ),
            ),
          for (var idx = 0; idx < _ingredients.length; idx++)
            PopIn(
              key: ObjectKey(_ingredients[idx]),
              enabled: _ingredients[idx].isNew,
              child: _IngredientRow(
                ing: _ingredients[idx],
                onChanged: () => setState(() {}),
                onRemove: () {
                  setState(() {
                    final ing = _ingredients.removeAt(idx);
                    ing.gramsCtrl.dispose();
                  });
                },
              ),
            ),
          if (_ingredients.isNotEmpty) ...[
            PtSectionHeader(l10n.nutritionSummary),
            PtCard(
              child: Row(
                children: [
                  MacroSplitRing(
                    protein: _totalProtein,
                    carbs: _totalCarbs,
                    fat: _totalFat,
                    size: 86,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedCount(
                          value: _totalCalories / s,
                          duration: const Duration(milliseconds: 350),
                          style: PtText.number(18, color: p.text),
                        ),
                        Text('kcal', style: PtText.tiny(color: p.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryRow(
                          l10n.total,
                          _totalCalories,
                          _totalProtein,
                          _totalCarbs,
                          _totalFat,
                        ),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          s > 1 ? l10n.perServingCount(s) : l10n.perServing,
                          _totalCalories / s,
                          _totalProtein / s,
                          _totalCarbs / s,
                          _totalFat / s,
                          isPerServing: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Pt.gutter, 8, Pt.gutter, 12),
          child: PtButton(
            label: l10n.save,
            icon: Icons.check_rounded,
            expand: true,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ),
      ),
    );
  }
}

class _EditableIngredient {
  _EditableIngredient({
    required this.item,
    required this.gramsCtrl,
    this.isNew = false,
  });
  final FoodItem item;
  final TextEditingController gramsCtrl;

  /// Added during this edit, so it pops in.
  final bool isNew;
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.ing,
    required this.onChanged,
    required this.onRemove,
  });

  final _EditableIngredient ing;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PtCard(
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        child: Row(
          children: [
            MacroSplitRing(
              protein: ing.item.proteinPer100,
              carbs: ing.item.carbsPer100,
              fat: ing.item.fatPer100,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ing.item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PtText.tile(
                      color: p.text,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (ing.item.brand.isNotEmpty)
                    Text(
                      ing.item.brand,
                      style: PtText.tiny(color: p.textMuted),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 84,
              child: TextField(
                controller: ing.gramsCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.end,
                style: PtText.number(15, color: p.text),
                decoration: const InputDecoration(
                  suffixText: 'g',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            PtIconButton(
              icon: Icons.close_rounded,
              tooltip: context.l10n.remove,
              background: Colors.transparent,
              color: p.textMuted,
              size: 36,
              iconSize: 20,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.cal,
    this.pro,
    this.carb,
    this.fat, {
    this.isPerServing = false,
  });

  final String label;
  final double cal, pro, carb, fat;
  final bool isPerServing;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PtText.small(
            color: isPerServing ? p.text : p.textMuted,
            weight: isPerServing ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            PtTag(label: '${cal.round()} kcal', color: p.primary),
            PtTag(label: 'P ${pro.round()}g', color: p.proteinInk),
            PtTag(label: 'C ${carb.round()}g', color: p.carbsInk),
            PtTag(label: 'F ${fat.round()}g', color: p.fatInk),
          ],
        ),
      ],
    );
  }
}
