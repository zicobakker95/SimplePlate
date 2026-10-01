import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/nutrition_goals.dart';
import '../../models/user_profile.dart';
import '../../services/food_store.dart';
import '../../ui/kit.dart';

/// Modal bottom sheet that collects biometric info, calculates TDEE via
/// Mifflin-St Jeor, and applies it to the user's nutrition goals.
class TdeeCalculatorSheet extends StatefulWidget {
  const TdeeCalculatorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

    if (age == null ||
        height == null ||
        weight == null ||
        age < 10 ||
        age > 120 ||
        height < 50 ||
        height > 280 ||
        weight < 20 ||
        weight > 500) {
      showPtToast(
        context,
        context.l10n.tdeeInvalid,
        icon: Icons.error_outline_rounded,
        tone: PtToastTone.warning,
      );
      return;
    }

    FocusScope.of(context).unfocus();
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
    await store.saveGoals(
      NutritionGoals(
        dailyCalories: profile.suggestedCalories,
        proteinGrams: profile.suggestedProtein,
        carbsGrams: profile.suggestedCarbs,
        fatGrams: profile.suggestedFat,
      ),
    );

    if (!mounted) return;
    // Capture the outer context before pop so the toast lands on the screen
    // underneath.
    final outer = Navigator.of(context).context;
    final msg = context.l10n.tdeeAppliedSnack;
    Navigator.pop(context);
    if (outer.mounted) {
      showPtToast(
        outer,
        msg,
        icon: Icons.check_circle_rounded,
        tone: PtToastTone.success,
      );
    }
  }

  Widget _numField(
    String label,
    TextEditingController ctrl,
    String suffix,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final bottomPad = MediaQuery.viewInsetsOf(context).bottom;
    final r = _result;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: EdgeInsets.fromLTRB(Pt.gutter, 0, Pt.gutter, 24 + bottomPad),
        children: [
          const PtGrabHandle(),
          Text(l10n.tdeeTitle, style: PtText.title(color: p.text)),
          const SizedBox(height: 4),
          Text(l10n.tdeeSubtitle, style: PtText.small(color: p.textMuted)),
          const SizedBox(height: 18),

          PtSegmented<BiologicalSex>(
            segments: [
              PtSegment(
                BiologicalSex.male,
                l10n.sexMale,
                icon: Icons.male_rounded,
              ),
              PtSegment(
                BiologicalSex.female,
                l10n.sexFemale,
                icon: Icons.female_rounded,
              ),
            ],
            selected: _sex,
            onChanged: (s) => setState(() {
              _sex = s;
              _showResults = false;
            }),
          ),
          const SizedBox(height: 8),

          _numField(
            l10n.fieldAge,
            _ageCtrl,
            l10n.unitYears,
            Icons.cake_outlined,
          ),
          _numField(l10n.fieldHeight, _heightCtrl, 'cm', Icons.height_rounded),
          _numField(
            l10n.fieldWeight,
            _weightCtrl,
            'kg',
            Icons.monitor_weight_outlined,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DropdownButtonFormField<ActivityLevel>(
              initialValue: _activityLevel,
              isExpanded: true,
              borderRadius: BorderRadius.circular(Pt.rSm),
              dropdownColor: p.surface,
              decoration: InputDecoration(
                labelText: l10n.activityLevelLabel,
                prefixIcon: const Icon(Icons.directions_run_rounded),
              ),
              items: [
                for (final v in ActivityLevel.values)
                  DropdownMenuItem(
                    value: v,
                    child: Text(
                      v.localizedLabel(l10n),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() {
                if (v != null) _activityLevel = v;
                _showResults = false;
              }),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            l10n.goalLabel.toUpperCase(),
            style: PtText.label(color: p.textMuted),
          ),
          const SizedBox(height: 8),
          PtSegmented<WeightGoal>(
            segments: [
              for (final g in WeightGoal.values)
                PtSegment(g, g.localizedLabel(l10n)),
            ],
            selected: _weightGoal,
            onChanged: (g) => setState(() {
              _weightGoal = g;
              _showResults = false;
            }),
          ),

          const SizedBox(height: 20),
          PtButton(
            label: l10n.calculate,
            icon: Icons.calculate_rounded,
            tone: _showResults ? PtButtonTone.soft : PtButtonTone.primary,
            expand: true,
            onPressed: _calculate,
          ),

          AnimatedSize(
            duration: Pt.slow,
            curve: Pt.ease,
            alignment: Alignment.topCenter,
            child: !_showResults || r == null
                ? const SizedBox(width: double.infinity)
                : PopIn(
                    key: ValueKey(r),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.yourResults.toUpperCase(),
                            style: PtText.label(color: p.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _Metric(
                                l10n.bmrLabel,
                                '${r.bmr.round()}',
                                'kcal',
                                p.textMuted,
                              ),
                              const SizedBox(width: 8),
                              _Metric(
                                l10n.tdeeMaintenance,
                                '${r.tdee.round()}',
                                'kcal',
                                p.primary,
                              ),
                              const SizedBox(width: 8),
                              _Metric(
                                l10n.bmiLabel,
                                r.bmi.toStringAsFixed(1),
                                localizedBmiCategory(l10n, r.bmi),
                                p.proteinInk,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          PtCard(
                            color: p.freshSoft,
                            shadow: false,
                            child: Row(
                              children: [
                                MacroSplitRing(
                                  protein: r.suggestedProtein.toDouble(),
                                  carbs: r.suggestedCarbs.toDouble(),
                                  fat: r.suggestedFat.toDouble(),
                                  size: 84,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedCount(
                                        value: r.suggestedCalories.toDouble(),
                                        style: PtText.number(17, color: p.text),
                                      ),
                                      Text(
                                        'kcal',
                                        style: PtText.tiny(color: p.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.suggestedGoals,
                                        style: PtText.headline(
                                          color: p.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          PtTag(
                                            label:
                                                '${l10n.macroProtein} ${r.suggestedProtein} g',
                                            color: p.proteinInk,
                                          ),
                                          PtTag(
                                            label:
                                                '${l10n.macroCarbs} ${r.suggestedCarbs} g',
                                            color: p.carbsInk,
                                          ),
                                          PtTag(
                                            label:
                                                '${l10n.macroFat} ${r.suggestedFat} g',
                                            color: p.fatInk,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          PtButton(
                            label: l10n.applyGoals,
                            icon: Icons.check_rounded,
                            expand: true,
                            haptic: true,
                            onPressed: _applyGoals,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.unit, this.color);
  final String label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: p.sunken,
          borderRadius: BorderRadius.circular(Pt.rSm),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: PtText.number(19, color: color)),
            ),
            Text(
              unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PtText.tiny(color: p.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: PtText.tiny(color: p.text, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
