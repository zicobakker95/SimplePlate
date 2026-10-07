import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/nutrition_goals.dart';
import '../../services/food_store.dart';
import '../../ui/kit.dart';
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      // With animations off, jump: nextPage() with Duration.zero finishes
      // inside DrivenScrollActivity's constructor and throws a
      // LateInitializationError on '_controller' (crashed on OnePlus phones
      // with "Remove animations" on).
      if (context.reduceMotion) {
        _pageController.jumpToPage(_page + 1);
      } else {
        _pageController.nextPage(duration: Pt.slow, curve: Pt.ease);
      }
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final store = context.read<FoodStore>();
    await store.saveGoals(
      NutritionGoals(
        dailyCalories: _calories,
        proteinGrams: _protein,
        carbsGrams: _carbs,
        fatGrams: _fat,
      ),
    );
    await store.markOnboardingDone();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
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
              padding: const EdgeInsets.only(bottom: 20, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                    duration: Pt.base,
                    curve: Pt.spring,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? p.primary : p.border,
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
    final l10n = context.l10n;
    final p = context.pal;
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const _PlatingHero(),
              const SizedBox(height: 28),
              FadeSlideIn(
                index: 3,
                child: Text(
                  l10n.welcomeTitle,
                  style: PtText.display(color: p.text),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(
                index: 4,
                child: Text(
                  l10n.welcomeSubtitle,
                  style: PtText.body(color: p.textMuted).copyWith(height: 1.55),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),
              FadeSlideIn(
                index: 5,
                child: PtButton(
                  label: l10n.getStarted,
                  icon: Icons.arrow_forward_rounded,
                  expand: true,
                  haptic: true,
                  onPressed: onNext,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// The welcome picture: the plate fills like the Today ring, Sprout pops up
/// in the middle and a few ingredients hop in around it.
class _PlatingHero extends StatelessWidget {
  const _PlatingHero();

  static const _foods = ['🥑', '🍓', '🥕', '🍞', '🥚', '🫐'];

  @override
  Widget build(BuildContext context) {
    const size = 220.0;
    return SizedBox(
      width: size + 70,
      height: size + 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const PlateRing(
            value: 0.72,
            size: size,
            stroke: 16,
            child: PopIn(
              delay: Duration(milliseconds: 300),
              child: Sprout(mood: SproutMood.happy, size: 96),
            ),
          ),
          for (var i = 0; i < _foods.length; i++)
            Align(
              alignment: Alignment(
                math.cos(-math.pi / 2 + i * math.pi / 3 + 0.5) * 1.0,
                math.sin(-math.pi / 2 + i * math.pi / 3 + 0.5) * 1.0,
              ),
              child: PopIn(
                delay: Duration(milliseconds: 450 + i * 110),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.pal.surface,
                    shape: BoxShape.circle,
                    boxShadow: Pt.shadow(context.pal, 0.6),
                  ),
                  child: Text(_foods[i], style: const TextStyle(fontSize: 22)),
                ),
              ),
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
      _calPctCtrl,
      _proPctCtrl,
      _carbPctCtrl,
      _fatPctCtrl,
      _proGCtrl,
      _carbGCtrl,
      _fatGCtrl,
      _calCtrl,
      _proCtrl,
      _carbCtrl,
      _fatCtrl,
    ]) {
      c.addListener(() => setState(() => _notify()));
    }
    // _notify() calls widget.onChanged, which is the parent's setState. This
    // runs inside initState — i.e. during the parent's build — and a
    // descendant marking an ancestor dirty mid-build throws
    // "setState() or markNeedsBuild() called during build". The assert is
    // compiled out of release, so users never saw the red screen, but
    // onboarding was unusable in a debug build. Push the first notify to
    // after the frame; the listeners above are fine, they fire on input.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notify();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _calCtrl,
      _proCtrl,
      _carbCtrl,
      _fatCtrl,
      _calPctCtrl,
      _proPctCtrl,
      _carbPctCtrl,
      _fatPctCtrl,
      _proGCtrl,
      _carbGCtrl,
      _fatGCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Derived ─────────────────────────────────────────────────────────────
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
  int get _calcCalories =>
      _macroProteinG * 4 + _macroCarbsG * 4 + _macroFatG * 9;

  /// The four numbers the current mode resolves to.
  (int, int, int, int) get _values => switch (_mode) {
    _GoalMode.manual => (
      int.tryParse(_calCtrl.text) ?? 2000,
      int.tryParse(_proCtrl.text) ?? 150,
      int.tryParse(_carbCtrl.text) ?? 200,
      int.tryParse(_fatCtrl.text) ?? 65,
    ),
    _GoalMode.percentages => (
      _pctCalories,
      _calcProteinG,
      _calcCarbsG,
      _calcFatG,
    ),
    _GoalMode.macrosToCalories => (
      _calcCalories,
      _macroProteinG,
      _macroCarbsG,
      _macroFatG,
    ),
  };

  void _notify() {
    final (c, p, carbs, f) = _values;
    widget.onChanged(c, p, carbs, f);
  }

  // ── Widgets ─────────────────────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl,
    Color accent, [
    String suffix = '',
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix.isEmpty ? null : suffix,
          isDense: true,
          prefixIcon: Icon(Icons.circle, size: 12, color: accent),
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
        ),
      ),
    );
  }

  Widget _readonlyCard(String label, String value, Color accent) {
    final p = context.pal;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: p.freshSoft,
        borderRadius: BorderRadius.circular(Pt.rSm + 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: PtText.small(color: p.text, weight: FontWeight.w600),
            ),
          ),
          Text(value, style: PtText.number(18, color: accent)),
        ],
      ),
    );
  }

  Widget _pctHint(String text, Color color) => Padding(
    padding: const EdgeInsets.only(left: 12, bottom: 2),
    child: Text(text, style: PtText.tiny(color: color)),
  );

  Widget _pctSumIndicator() {
    final l10n = context.l10n;
    final p = context.pal;
    final sum = _pctSum.round();
    final ok = sum == 100;
    final color = ok ? p.primary : p.dangerInk;
    return AnimatedContainer(
      duration: Pt.base,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ok ? p.freshSoft : p.dangerSoft,
        borderRadius: BorderRadius.circular(Pt.rSm),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok ? l10n.pctTotalOk : l10n.pctTotalOff(sum),
              style: PtText.small(color: color, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final (cal, pro, carb, fat) = _values;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.onbSetGoalsTitle,
                      style: PtText.title(color: p.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.onbSetGoalsSubtitle,
                      style: PtText.small(color: p.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Live preview of the plate being set.
              MacroSplitRing(
                protein: pro.toDouble(),
                carbs: carb.toDouble(),
                fat: fat.toDouble(),
                size: 76,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      child: Text(
                        '$cal',
                        style: PtText.number(16, color: p.text),
                      ),
                    ),
                    Text('kcal', style: PtText.tiny(color: p.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Mode toggle
          PtSegmented<_GoalMode>(
            segments: [
              PtSegment(_GoalMode.manual, l10n.goalModeManual),
              PtSegment(_GoalMode.percentages, l10n.goalModePercent),
              PtSegment(_GoalMode.macrosToCalories, l10n.goalModeMacros),
            ],
            selected: _mode,
            onChanged: (m) => setState(() {
              _mode = m;
              _notify();
            }),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: Pt.base,
            child: Text(
              switch (_mode) {
                _GoalMode.manual => l10n.goalModeManualDesc,
                _GoalMode.percentages => l10n.goalModePercentDesc,
                _GoalMode.macrosToCalories => l10n.goalModeMacrosDesc,
              },
              key: ValueKey(_mode),
              style: PtText.small(color: p.textMuted),
            ),
          ),
          const SizedBox(height: 10),

          // Mode content
          AnimatedSize(
            duration: Pt.base,
            curve: Pt.ease,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: Pt.base,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: KeyedSubtree(
                key: ValueKey(_mode),
                child: switch (_mode) {
                  _GoalMode.manual => Column(
                    children: [
                      _field(l10n.fieldCalories, _calCtrl, p.fresh, 'kcal'),
                      _field(l10n.fieldProtein, _proCtrl, p.protein, 'g'),
                      _field(l10n.fieldCarbohydrates, _carbCtrl, p.carbs, 'g'),
                      _field(l10n.fieldFat, _fatCtrl, p.fat, 'g'),
                    ],
                  ),
                  _GoalMode.percentages => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(
                        l10n.fieldDailyCalories,
                        _calPctCtrl,
                        p.fresh,
                        'kcal',
                      ),
                      _field(l10n.fieldProteinPct, _proPctCtrl, p.protein, '%'),
                      _pctHint(
                        l10n.pctHintProtein(_calcProteinG),
                        p.proteinInk,
                      ),
                      _field(l10n.fieldCarbsPct, _carbPctCtrl, p.carbs, '%'),
                      _pctHint(l10n.pctHintCarbs(_calcCarbsG), p.carbsInk),
                      _field(l10n.fieldFatPct, _fatPctCtrl, p.fat, '%'),
                      _pctHint(l10n.pctHintFat(_calcFatG), p.fatInk),
                      _pctSumIndicator(),
                    ],
                  ),
                  _GoalMode.macrosToCalories => Column(
                    children: [
                      _field(l10n.fieldProtein, _proGCtrl, p.protein, 'g'),
                      _field(l10n.fieldCarbohydrates, _carbGCtrl, p.carbs, 'g'),
                      _field(l10n.fieldFat, _fatGCtrl, p.fat, 'g'),
                      _readonlyCard(
                        l10n.calculatedCalories,
                        '$_calcCalories kcal',
                        p.primary,
                      ),
                    ],
                  ),
                },
              ),
            ),
          ),

          const SizedBox(height: 22),
          PtButton(
            label: l10n.continueLabel,
            icon: Icons.arrow_forward_rounded,
            expand: true,
            onPressed: widget.onNext,
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
    final l10n = context.l10n;
    final p = context.pal;
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: p.honeySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Sprout(mood: SproutMood.happy, size: 96),
                  ),
                  Positioned(
                    right: -4,
                    top: 4,
                    child: PopIn(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: p.honey,
                          shape: BoxShape.circle,
                          border: Border.all(color: p.bg, width: 4),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                l10n.onbStayOnTrackTitle,
                textAlign: TextAlign.center,
                style: PtText.display(color: p.text).copyWith(fontSize: 26),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.onbStayOnTrackBody,
                style: PtText.body(color: p.textMuted).copyWith(height: 1.55),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              PtButton(
                label: l10n.letsGo,
                icon: Icons.restaurant_rounded,
                expand: true,
                haptic: true,
                onPressed: onFinish,
              ),
              const SizedBox(height: 6),
              PtButton(
                label: l10n.skipForNow,
                tone: PtButtonTone.ghost,
                color: p.textMuted,
                onPressed: onFinish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
