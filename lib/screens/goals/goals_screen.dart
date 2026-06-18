import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nutrition_goals.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late TextEditingController _calCtrl;
  late TextEditingController _proCtrl;
  late TextEditingController _carbCtrl;
  late TextEditingController _fatCtrl;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final g = context.read<FoodStore>().goals;
    _calCtrl = TextEditingController(text: g.dailyCalories.toString());
    _proCtrl = TextEditingController(text: g.proteinGrams.toString());
    _carbCtrl = TextEditingController(text: g.carbsGrams.toString());
    _fatCtrl = TextEditingController(text: g.fatGrams.toString());
  }

  @override
  void dispose() {
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final goals = NutritionGoals(
      dailyCalories: int.tryParse(_calCtrl.text) ?? 2000,
      proteinGrams: int.tryParse(_proCtrl.text) ?? 150,
      carbsGrams: int.tryParse(_carbCtrl.text) ?? 200,
      fatGrams: int.tryParse(_fatCtrl.text) ?? 65,
    );
    setState(() => _saving = true);
    await context.read<FoodStore>().saveGoals(goals);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Goals saved!')));
  }

  Widget _field(String label, TextEditingController ctrl, Color accent,
      String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accent),
          suffixText: suffix,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Daily nutrition targets',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Set your daily calorie and macro goals.',
              style:
                  tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _field('Calories', _calCtrl, AppColors.calories, 'kcal'),
          _field('Protein', _proCtrl, AppColors.protein, 'g'),
          _field('Carbohydrates', _carbCtrl, AppColors.carbs, 'g'),
          _field('Fat', _fatCtrl, AppColors.fat, 'g'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save goals'),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Text('About PlateSimple',
              style: tt.labelLarge
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0\n'
            'Food data provided by Open Food Facts (openfoodfacts.org) — '
            'open database, open data, made by everyone.',
            style:
                tt.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.6),
          ),
        ],
      ),
    );
  }
}
