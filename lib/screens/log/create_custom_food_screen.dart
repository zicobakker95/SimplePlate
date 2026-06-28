import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/l10n.dart';
import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';
import 'food_detail_screen.dart';

/// Screen for creating a custom food item.
/// After saving, opens FoodDetailScreen so the user can log a serving immediately.
class CreateCustomFoodScreen extends StatefulWidget {
  const CreateCustomFoodScreen({super.key, required this.defaultMeal});
  final MealType defaultMeal;

  @override
  State<CreateCustomFoodScreen> createState() =>
      _CreateCustomFoodScreenState();
}

class _CreateCustomFoodScreenState extends State<CreateCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = FoodItem(
      id: 'custom-${const Uuid().v4()}',
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      caloriesPer100: double.parse(_calCtrl.text),
      proteinPer100: double.parse(_proteinCtrl.text),
      carbsPer100: double.parse(_carbCtrl.text),
      fatPer100: double.parse(_fatCtrl.text),
      isCustom: true,
    );

    await context.read<FoodStore>().addCustomFood(item);
    if (!mounted) return;
    setState(() => _saving = false);

    // Replace this screen with FoodDetailScreen so the user logs a serving
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) =>
            FoodDetailScreen(item: item, defaultMeal: widget.defaultMeal)));
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String suffix = '',
    bool required = true,
    int maxLength = 80,
    bool decimal = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        maxLength: maxLength,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix.isEmpty ? null : suffix,
          counterText: '',
        ),
        validator: required
            ? (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return context.l10n.fieldRequired;
                if (decimal && double.tryParse(s) == null) {
                  return context.l10n.enterValidNumber;
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createCustomFoodTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.foodDetailsSection,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(l10n.valuesPer100,
                style:
                    tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            _field(l10n.foodNameLabel, _nameCtrl, decimal: false),
            _field(l10n.brandOptional, _brandCtrl,
                required: false, decimal: false),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            Text(l10n.nutritionPer100,
                style: tt.titleSmall
                    ?.copyWith(color: AppColors.textSecondary)),
            _field(l10n.fieldCalories, _calCtrl,
                suffix: 'kcal', decimal: true),
            _field(l10n.fieldProtein, _proteinCtrl, suffix: 'g'),
            _field(l10n.fieldCarbohydrates, _carbCtrl, suffix: 'g'),
            _field(l10n.fieldFat, _fatCtrl, suffix: 'g'),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(l10n.saveAndLog),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
