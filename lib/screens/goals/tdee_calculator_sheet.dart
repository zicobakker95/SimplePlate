import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nutrition_goals.dart';
import '../../models/user_profile.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';

/// Modal bottom sheet that collects biometric info, calculates TDEE via
/// Mifflin-St Jeor, and applies it to the user's nutrition goals.
class TdeeCalculatorSheet extends StatefulWidget {
  const TdeeCalculatorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const TdeeCalculatorSheet(),
    );
  }

  @override
  State<TdeeCalculatorSheet> createState() => _TdeeCalculatorSheetState();
}

class _TdeeCalculatorSheetState extends State<TdeeCalculatorSheet> {
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  BiologicalSex _sex = BiologicalSex.male;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  WeightGoal _weightGoal = WeightGoal.maintain;

  bool _showResults = false;
  UserProfile? _result;

  @override
  void initState() {
    super.initState();
    final existing = context.read<FoodStore>().userProfile;
    if (existing != null) {
      _ageCtrl.text = existing.age.toString();
      _heightCtrl.text = existing.heightCm.toString();
      _weightCtrl.text = existing.weightKg.toString();
      _sex = existing.sex;
      _activityLevel = existing.activityLevel;
      _weightGoal = existing.weightGoal;
    }
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final age = int.tryParse(_ageCtrl.text);
    final height = double.tryParse(_heightCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);

    if (age == null || height == null || weight == null ||
        age < 10 || age > 120 || height < 50 || height > 280 ||
        weight < 20 || weight > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values for all fields.')),
      );
      return;
    }

    setState(() {
      _result = UserProfile(
        age: age,
        sex: _sex,
        heightCm: height,
        weightKg: weight,
        activityLevel: _activityLevel,
        weightGoal: _weightGoal,
      );
      _showResults = true;
    });
  }

  Future<void> _applyGoals() async {
    final profile = _result;
    if (profile == null) return;

    final store = context.read<FoodStore>();
    await store.saveUserProfile(profile);
    await store.saveGoals(NutritionGoals(
      dailyCalories: profile.suggestedCalories,
      proteinGrams: profile.suggestedProtein,
      carbsGrams: profile.suggestedCarbs,
      fatGrams: profile.suggestedFat,
    ));

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goals updated from TDEE calculator!')),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) labelOf,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(labelText: label),
        dropdownColor: AppColors.surfaceAlt,
        items: values
            .map((v) => DropdownMenuItem(value: v, child: Text(labelOf(v))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _numField(String label, TextEditingController ctrl, String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPad),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('TDEE Calculator',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Enter your stats to calculate Total Daily Energy Expenditure and auto-set your calorie goal.',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Sex toggle
          SegmentedButton<BiologicalSex>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary.withOpacity(0.2),
              selectedForegroundColor: AppColors.primary,
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
            ),
            segments: const [
              ButtonSegment(
                  value: BiologicalSex.male,
                  icon: Icon(Icons.male_rounded, size: 18),
                  label: Text('Male')),
              ButtonSegment(
                  value: BiologicalSex.female,
                  icon: Icon(Icons.female_rounded, size: 18),
                  label: Text('Female')),
            ],
            selected: {_sex},
            onSelectionChanged: (s) => setState(() {
              _sex = s.first;
              _showResults = false;
            }),
          ),
          const SizedBox(height: 4),

          _numField('Age', _ageCtrl, 'years'),
          _numField('Height', _heightCtrl, 'cm'),
          _numField('Weight', _weightCtrl, 'kg'),

          _dropdownField<ActivityLevel>(
            label: 'Activity level',
            value: _activityLevel,
            values: ActivityLevel.values,
            labelOf: (v) => v.label,
            onChanged: (v) => setState(() {
              if (v != null) _activityLevel = v;
              _showResults = false;
            }),
          ),

          _dropdownField<WeightGoal>(
            label: 'Goal',
            value: _weightGoal,
            values: WeightGoal.values,
            labelOf: (v) => v.label,
            onChanged: (v) => setState(() {
              if (v != null) _weightGoal = v;
              _showResults = false;
            }),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
          ),

          if (_showResults && _result != null) ...[
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            Text('Your Results',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _ResultRow('BMR (base metabolic rate)',
                '${_result!.bmr.round()} kcal', AppColors.textSecondary),
            _ResultRow('TDEE (maintenance)',
                '${_result!.tdee.round()} kcal', AppColors.calories),
            _ResultRow('BMI', _result!.bmi.toStringAsFixed(1),
                AppColors.textSecondary,
                subtitle: _result!.bmiCategory),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suggested goals',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _GoalPreviewRow(
                      'Calories', '${_result!.suggestedCalories} kcal',
                      AppColors.calories),
                  _GoalPreviewRow(
                      'Protein', '${_result!.suggestedProtein} g',
                      AppColors.protein),
                  _GoalPreviewRow(
                      'Carbs', '${_result!.suggestedCarbs} g',
                      AppColors.carbs),
                  _GoalPreviewRow(
                      'Fat', '${_result!.suggestedFat} g',
                      AppColors.fat),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Apply these goals'),
                onPressed: _applyGoals,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value, this.color, {this.subtitle});
  final String label, value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

class _GoalPreviewRow extends StatelessWidget {
  const _GoalPreviewRow(this.label, this.value, this.color);
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
