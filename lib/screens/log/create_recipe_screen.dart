import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/food_item.dart';
import '../../models/recipe.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';
import 'add_food_screen.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key, this.existing});

  final Recipe? existing;

  static Route<void> route({Recipe? existing}) => MaterialPageRoute(
        builder: (_) => CreateRecipeScreen(existing: existing),
      );

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
      _ingredients.addAll(r.ingredients
          .map((i) => _EditableIngredient(
                item: i.item,
                gramsCtrl:
                    TextEditingController(text: i.grams.round().toString()),
              )));
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

  double get _totalCalories => _ingredients.fold(
      0,
      (s, i) =>
          s + i.item.caloriesPer100 * (double.tryParse(i.gramsCtrl.text) ?? 0) / 100);
  double get _totalProtein => _ingredients.fold(
      0,
      (s, i) =>
          s + i.item.proteinPer100 * (double.tryParse(i.gramsCtrl.text) ?? 0) / 100);
  double get _totalCarbs => _ingredients.fold(
      0,
      (s, i) =>
          s + i.item.carbsPer100 * (double.tryParse(i.gramsCtrl.text) ?? 0) / 100);
  double get _totalFat => _ingredients.fold(
      0,
      (s, i) =>
          s + i.item.fatPer100 * (double.tryParse(i.gramsCtrl.text) ?? 0) / 100);

  int get _servings => int.tryParse(_servingsCtrl.text) ?? 1;

  Future<void> _pickIngredient() async {
    final item = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(
          builder: (_) => const AddFoodScreen(pickMode: true)),
    );
    if (item == null) return;
    setState(() {
      _ingredients.add(_EditableIngredient(
        item: item,
        gramsCtrl: TextEditingController(text: '100'),
      ));
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe name is required.')));
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one ingredient.')));
      return;
    }

    final recipe = Recipe(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: name,
      description: _descCtrl.text.trim(),
      servings: _servings.clamp(1, 99),
      ingredients: _ingredients
          .map((i) => RecipeIngredient(
                item: i.item,
                grams: double.tryParse(i.gramsCtrl.text) ?? 100,
              ))
          .toList(),
    );

    setState(() => _saving = true);
    await context.read<FoodStore>().saveRecipe(recipe);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final s = _servings.clamp(1, 99);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Create recipe' : 'Edit recipe'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : const Text('Save',
                    style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Recipe name'),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
                labelText: 'Description (optional)'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _servingsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Servings'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Ingredients',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
                onPressed: _pickIngredient,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
            ],
          ),
          if (_ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No ingredients yet.',
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.textMuted)),
            ),
          ...List.generate(_ingredients.length, (idx) {
            final ing = _ingredients[idx];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ing.item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          if (ing.item.brand.isNotEmpty)
                            Text(ing.item.brand,
                                style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 72,
                      child: TextField(
                        controller: ing.gramsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          suffixText: 'g',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.textMuted,
                      onPressed: () {
                        setState(() {
                          ing.gramsCtrl.dispose();
                          _ingredients.removeAt(idx);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_ingredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            Text('Nutrition summary',
                style: tt.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _SummaryRow('Total', _totalCalories, _totalProtein,
                _totalCarbs, _totalFat),
            _SummaryRow(
              'Per serving${s > 1 ? ' ($s servings)' : ''}',
              _totalCalories / s,
              _totalProtein / s,
              _totalCarbs / s,
              _totalFat / s,
              isPerServing: true,
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _EditableIngredient {
  _EditableIngredient({required this.item, required this.gramsCtrl});
  final FoodItem item;
  final TextEditingController gramsCtrl;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
      this.label, this.cal, this.pro, this.carb, this.fat,
      {this.isPerServing = false});

  final String label;
  final double cal, pro, carb, fat;
  final bool isPerServing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    color: isPerServing
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isPerServing ? FontWeight.w600 : FontWeight.normal)),
          ),
          _Chip('${cal.round()} kcal', AppColors.calories),
          const SizedBox(width: 4),
          _Chip('P ${pro.round()}g', AppColors.protein),
          const SizedBox(width: 4),
          _Chip('C ${carb.round()}g', AppColors.carbs),
          const SizedBox(width: 4),
          _Chip('F ${fat.round()}g', AppColors.fat),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
