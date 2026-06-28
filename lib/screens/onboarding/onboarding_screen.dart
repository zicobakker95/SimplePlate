import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/nutrition_goals.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';
import '../home/home_shell.dart';

enum _GoalMode { manual, percentages, macrosToCalories }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  // Goal inputs — updated by _GoalsPage via callback
  int _calories = 2000;
  int _protein = 150;
  int _carbs = 200;
  int _fat = 65;

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final store = context.read<FoodStore>();
    await store.saveGoals(NutritionGoals(
      dailyCalories: _calories,
      proteinGrams: _protein,
      carbsGrams: _carbs,
      fatGrams: _fat,
    ));
    await store.markOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(onNext: _next),
                  _GoalsPage(
                    onChanged: (c, p, carbs, f) => setState(() {
                      _calories = c;
                      _protein = p;
                      _carbs = carbs;
                      _fat = f;
                    }),
                    onNext: _next,
                  ),
                  _PermissionsPage(onFinish: _finish),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.restaurant_menu_rounded,
                color: Colors.white, size: 52),
          ),
          const SizedBox(height: 32),
          Text(l10n.welcomeTitle,
              style: tt.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            l10n.welcomeSubtitle,
            style: tt.bodyLarge
                ?.copyWith(color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: onNext, child: Text(l10n.getStarted)),
          ),
        ],
      ),
    );
  }
}

class _GoalsPage extends StatefulWidget {
  const _GoalsPage({required this.onChanged, required this.onNext});
  final void Function(int c, int p, int carbs, int f) onChanged;
  final VoidCallback onNext;

  @override
  State<_GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<_GoalsPage> {
  _GoalMode _mode = _GoalMode.manual;

  // Manual
  final _calCtrl = TextEditingController(text: '2000');
  final _proCtrl = TextEditingController(text: '150');
  final _carbCtrl = TextEditingController(text: '200');
  final _fatCtrl = TextEditingController(text: '65');

  // Percentage mode
  final _calPctCtrl = TextEditingController(text: '2000');
  final _proPctCtrl = TextEditingController(text: '30');
  final _carbPctCtrl = TextEditingController(text: '40');
  final _fatPctCtrl = TextEditingController(text: '30');

  // Macros → calories
  final _proGCtrl = TextEditingController(text: '150');
  final _carbGCtrl = TextEditingController(text: '200');
  final _fatGCtrl = TextEditingController(text: '65');

  @override
  void initState() {
    super.initState();
    for (final c in [
      _calPctCtrl, _proPctCtrl, _carbPctCtrl, _fatPctCtrl,
      _proGCtrl, _carbGCtrl, _fatGCtrl,
      _calCtrl, _proCtrl, _carbCtrl, _fatCtrl,
    ]) {
      c.addListener(() => setState(() => _notify()));
    }
    _notify();
  }

  @override
  void dispose() {
    for (final c in [
      _calCtrl, _proCtrl, _carbCtrl, _fatCtrl,
      _calPctCtrl, _proPctCtrl, _carbPctCtrl, _fatPctCtrl,
      _proGCtrl, _carbGCtrl, _fatGCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Derived ─────────────────────────────────────────────────────────────────
  int get _pctCalories => int.tryParse(_calPctCtrl.text) ?? 0;
  double get _proPct => double.tryParse(_proPctCtrl.text) ?? 0;
  double get _carbPct => double.tryParse(_carbPctCtrl.text) ?? 0;
  double get _fatPct => double.tryParse(_fatPctCtrl.text) ?? 0;
  double get _pctSum => _proPct + _carbPct + _fatPct;

  int get _calcProteinG => ((_pctCalories * _proPct / 100) / 4).round();
  int get _calcCarbsG => ((_pctCalories * _carbPct / 100) / 4).round();
  int get _calcFatG => ((_pctCalories * _fatPct / 100) / 9).round();

  int get _macroProteinG => int.tryParse(_proGCtrl.text) ?? 0;
  int get _macroCarbsG => int.tryParse(_carbGCtrl.text) ?? 0;
  int get _macroFatG => int.tryParse(_fatGCtrl.text) ?? 0;
  int get _calcCalories => _macroProteinG * 4 + _macroCarbsG * 4 + _macroFatG * 9;

  void _notify() {
    switch (_mode) {
      case _GoalMode.manual:
        widget.onChanged(
          int.tryParse(_calCtrl.text) ?? 2000,
          int.tryParse(_proCtrl.text) ?? 150,
          int.tryParse(_carbCtrl.text) ?? 200,
          int.tryParse(_fatCtrl.text) ?? 65,
        );
      case _GoalMode.percentages:
        widget.onChanged(_pctCalories, _calcProteinG, _calcCarbsG, _calcFatG);
      case _GoalMode.macrosToCalories:
        widget.onChanged(_calcCalories, _macroProteinG, _macroCarbsG, _macroFatG);
    }
  }

  // ── Widgets ─────────────────────────────────────────────────────────────────
  Widget _field(String label, TextEditingController ctrl, Color accent,
      [String suffix = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accent),
          suffixText: suffix.isEmpty ? null : suffix,
          isDense: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _readonlyCard(String label, String value, Color accent) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: accent, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _pctHint(String text, Color color) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 2),
        child: Text(text,
            style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      );

  Widget _pctSumIndicator() {
    final l10n = context.l10n;
    final sum = _pctSum.round();
    final ok = sum == 100;
    final color = ok ? AppColors.primary : AppColors.fat;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Icon(
            ok
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            color: color,
            size: 16),
        const SizedBox(width: 8),
        Text(
          ok ? l10n.pctTotalOk : l10n.pctTotalOff(sum),
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(l10n.onbSetGoalsTitle,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(l10n.onbSetGoalsSubtitle,
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Mode toggle
          SegmentedButton<_GoalMode>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary.withOpacity(0.2),
              selectedForegroundColor: AppColors.primary,
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              textStyle: const TextStyle(fontSize: 11),
            ),
            segments: [
              ButtonSegment(
                  value: _GoalMode.manual,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: Text(l10n.goalModeManual)),
              ButtonSegment(
                  value: _GoalMode.percentages,
                  icon: const Icon(Icons.percent, size: 14),
                  label: Text(l10n.goalModePercent)),
              ButtonSegment(
                  value: _GoalMode.macrosToCalories,
                  icon: const Icon(Icons.calculate_outlined, size: 14),
                  label: Text(l10n.goalModeMacros)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) =>
                setState(() { _mode = s.first; _notify(); }),
          ),
          const SizedBox(height: 4),
          Text(
            switch (_mode) {
              _GoalMode.manual => l10n.goalModeManualDesc,
              _GoalMode.percentages => l10n.goalModePercentDesc,
              _GoalMode.macrosToCalories => l10n.goalModeMacrosDesc,
            },
            style: tt.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          // Mode content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: KeyedSubtree(
              key: ValueKey(_mode),
              child: switch (_mode) {
                _GoalMode.manual => Column(children: [
                    _field(l10n.fieldCalories, _calCtrl, AppColors.calories,
                        'kcal'),
                    _field(l10n.fieldProtein, _proCtrl, AppColors.protein, 'g'),
                    _field(l10n.fieldCarbohydrates, _carbCtrl, AppColors.carbs,
                        'g'),
                    _field(l10n.fieldFat, _fatCtrl, AppColors.fat, 'g'),
                  ]),
                _GoalMode.percentages => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(l10n.fieldDailyCalories, _calPctCtrl,
                          AppColors.calories, 'kcal'),
                      _field(l10n.fieldProteinPct, _proPctCtrl,
                          AppColors.protein, '%'),
                      _pctHint(l10n.pctHintProtein(_calcProteinG),
                          AppColors.protein),
                      _field(l10n.fieldCarbsPct, _carbPctCtrl, AppColors.carbs,
                          '%'),
                      _pctHint(
                          l10n.pctHintCarbs(_calcCarbsG), AppColors.carbs),
                      _field(l10n.fieldFatPct, _fatPctCtrl, AppColors.fat, '%'),
                      _pctHint(l10n.pctHintFat(_calcFatG), AppColors.fat),
                      _pctSumIndicator(),
                    ]),
                _GoalMode.macrosToCalories => Column(children: [
                    _field(l10n.fieldProtein, _proGCtrl, AppColors.protein,
                        'g'),
                    _field(l10n.fieldCarbohydrates, _carbGCtrl, AppColors.carbs,
                        'g'),
                    _field(l10n.fieldFat, _fatGCtrl, AppColors.fat, 'g'),
                    _readonlyCard(l10n.calculatedCalories,
                        '$_calcCalories kcal', AppColors.calories),
                  ]),
              },
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: widget.onNext, child: Text(l10n.continueLabel)),
          ),
        ],
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage({required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active_rounded,
              size: 72, color: AppColors.primary),
          const SizedBox(height: 32),
          Text(l10n.onbStayOnTrackTitle,
              style: tt.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text(
            l10n.onbStayOnTrackBody,
            style: tt.bodyLarge
                ?.copyWith(color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: onFinish,
                child: Text(l10n.letsGo)),
          ),
          const SizedBox(height: 12),
          TextButton(
              onPressed: onFinish, child: Text(l10n.skipForNow)),
        ],
      ),
    );
  }
}
