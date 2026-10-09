import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cross_promo.dart';
import '../../l10n/l10n.dart';
import '../../models/nutrition_goals.dart';
import '../../screens/goals/tdee_calculator_sheet.dart';
import '../../screens/premium/premium_screen.dart';
import '../../services/export_service.dart';
import '../../services/food_store.dart';
import '../../services/notification_service.dart';
import '../../services/subscription_service.dart';
import '../../ui/kit.dart';
import '../../ui/theme/appearance.dart';
import '../../debug/debug_menu_screen.dart';
import '../../utils/weight_math.dart';
import '../../widgets/health_sync_setting.dart';
import '../../widgets/weight_card.dart';
import '../../services/consent_gate.dart';

/// PlateSimple's privacy policy, linked from settings and the paywall.
const privacyPolicyUrl =
    'https://zibaentertainment.com/privacy-policy-platesimple.html';

enum _GoalMode { manual, percentages, macrosToCalories }

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Manual mode controllers
  late TextEditingController _calCtrl;
  late TextEditingController _proCtrl;
  late TextEditingController _carbCtrl;
  late TextEditingController _fatCtrl;

  // Percentage mode controllers
  late TextEditingController _calPctCtrl;
  late TextEditingController _proPctCtrl;
  late TextEditingController _carbPctCtrl;
  late TextEditingController _fatPctCtrl;

  // Macros → calories mode controllers
  late TextEditingController _proGCtrl;
  late TextEditingController _carbGCtrl;
  late TextEditingController _fatGCtrl;

  _GoalMode _mode = _GoalMode.manual;
  bool _saving = false;
  bool _initialised = false;

  // Reminder state
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  // Water state
  bool _waterEnabled = false;
  final TextEditingController _waterGoalCtrl = TextEditingController(text: '8');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;

    final g = context.read<FoodStore>().goals;

    // Load reminder prefs
    final store = context.read<FoodStore>();
    _reminderEnabled = store.reminderEnabled;
    _reminderTime = TimeOfDay(
      hour: store.reminderHour,
      minute: store.reminderMinute,
    );

    // Load water prefs
    _waterEnabled = store.waterEnabled;
    _waterGoalCtrl.text = store.waterGoal.toString();

    // Manual
    _calCtrl = TextEditingController(text: g.dailyCalories.toString());
    _proCtrl = TextEditingController(text: g.proteinGrams.toString());
    _carbCtrl = TextEditingController(text: g.carbsGrams.toString());
    _fatCtrl = TextEditingController(text: g.fatGrams.toString());

    // Percentage mode — derive starting percentages from current goals
    final totalKcal = g.dailyCalories > 0 ? g.dailyCalories : 2000;
    final proPct = ((g.proteinGrams * 4 / totalKcal) * 100).round();
    final carbPct = ((g.carbsGrams * 4 / totalKcal) * 100).round();
    final fatPct = ((g.fatGrams * 9 / totalKcal) * 100).round();
    _calPctCtrl = TextEditingController(text: g.dailyCalories.toString());
    _proPctCtrl = TextEditingController(text: proPct.toString());
    _carbPctCtrl = TextEditingController(text: carbPct.toString());
    _fatPctCtrl = TextEditingController(text: fatPct.toString());

    // Macros → calories
    _proGCtrl = TextEditingController(text: g.proteinGrams.toString());
    _carbGCtrl = TextEditingController(text: g.carbsGrams.toString());
    _fatGCtrl = TextEditingController(text: g.fatGrams.toString());

    // Rebuild when any field changes so live calculations (and the preview
    // ring) update.
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
      c.addListener(() => setState(() {}));
    }
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
      _waterGoalCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Derived values ──────────────────────────────────────────────────────

  /// Calories entered in percentage mode.
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

  /// What Save would store right now, for the preview ring.
  NutritionGoals get _pending => switch (_mode) {
    _GoalMode.manual => NutritionGoals(
      dailyCalories: int.tryParse(_calCtrl.text) ?? 2000,
      proteinGrams: int.tryParse(_proCtrl.text) ?? 150,
      carbsGrams: int.tryParse(_carbCtrl.text) ?? 200,
      fatGrams: int.tryParse(_fatCtrl.text) ?? 65,
    ),
    _GoalMode.percentages => NutritionGoals(
      dailyCalories: _pctCalories,
      proteinGrams: _calcProteinG,
      carbsGrams: _calcCarbsG,
      fatGrams: _calcFatG,
    ),
    _GoalMode.macrosToCalories => NutritionGoals(
      dailyCalories: _calcCalories,
      proteinGrams: _macroProteinG,
      carbsGrams: _macroCarbsG,
      fatGrams: _macroFatG,
    ),
  };

  // ── Save ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final goals = _pending;
    setState(() => _saving = true);
    await context.read<FoodStore>().saveGoals(goals);
    if (!mounted) return;
    setState(() => _saving = false);
    showPtToast(
      context,
      context.l10n.goalsSavedSnack,
      icon: Icons.check_circle_rounded,
      tone: PtToastTone.success,
    );
  }

  // ── Widgets ─────────────────────────────────────────────────────────────

  /// The debug entry, or null in release. Spread with `...?` so a release
  /// build inserts literally nothing.
  List<Widget>? _debugSection(BuildContext context) {
    final tile = debugToolsTile(context);
    if (tile == null) return null;
    return [const SizedBox(height: 24), tile];
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    Color accent,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _pctHint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(text, style: PtText.tiny(color: color)),
    );
  }

  Widget _pctSumIndicator() {
    final l10n = context.l10n;
    final p = context.pal;
    final sum = _pctSum.round();
    final ok = sum == 100;
    final color = ok ? p.primary : p.dangerInk;
    return AnimatedContainer(
      duration: Pt.base,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ok ? p.freshSoft : p.dangerSoft,
        borderRadius: BorderRadius.circular(Pt.rSm),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: color,
            size: 18,
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

  Widget _manualMode() {
    final l10n = context.l10n;
    final p = context.pal;
    return Column(
      children: [
        _field(l10n.fieldCalories, _calCtrl, p.fresh, 'kcal'),
        _field(l10n.fieldProtein, _proCtrl, p.protein, 'g'),
        _field(l10n.fieldCarbohydrates, _carbCtrl, p.carbs, 'g'),
        _field(l10n.fieldFat, _fatCtrl, p.fat, 'g'),
      ],
    );
  }

  Widget _percentagesMode() {
    final l10n = context.l10n;
    final p = context.pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(l10n.fieldDailyCalories, _calPctCtrl, p.fresh, 'kcal'),
        _field(l10n.fieldProteinPct, _proPctCtrl, p.protein, '%'),
        _pctHint(l10n.pctHintProtein(_calcProteinG), p.proteinInk),
        _field(l10n.fieldCarbsPct, _carbPctCtrl, p.carbs, '%'),
        _pctHint(l10n.pctHintCarbs(_calcCarbsG), p.carbsInk),
        _field(l10n.fieldFatPct, _fatPctCtrl, p.fat, '%'),
        _pctHint(l10n.pctHintFat(_calcFatG), p.fatInk),
        _pctSumIndicator(),
      ],
    );
  }

  Widget _macrosToCaloriesMode() {
    final l10n = context.l10n;
    final p = context.pal;
    return Column(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final store = context.watch<FoodStore>();
    final appearance = context.watch<AppearanceController>();
    final pending = _pending;

    var i = 0;
    Widget enter(Widget child) => FadeSlideIn(index: i++, child: child);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
              child: Text(l10n.navGoals, style: PtText.title(color: p.text)),
            ),
          ),

          // ── Premium banner ──────────────────────────────────────────────
          enter(
            ListenableBuilder(
              listenable: SubscriptionService.instance,
              builder: (context, _) => _PremiumBanner(
                isPremium: SubscriptionService.instance.isPremium,
              ),
            ),
          ),

          // ── Daily targets ───────────────────────────────────────────────
          PtSectionHeader(
            l10n.goalsDailyTargets,
            subtitle: l10n.goalsChooseHow,
          ),
          enter(
            PtCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Live preview of what Save would store.
                  Row(
                    children: [
                      MacroSplitRing(
                        protein: pending.proteinGrams.toDouble(),
                        carbs: pending.carbsGrams.toDouble(),
                        fat: pending.fatGrams.toDouble(),
                        size: 72,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              child: Text(
                                '${pending.dailyCalories}',
                                style: PtText.number(16, color: p.text),
                              ),
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
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            PtTag(
                              label: 'P ${pending.proteinGrams}g',
                              color: p.proteinInk,
                            ),
                            PtTag(
                              label: 'C ${pending.carbsGrams}g',
                              color: p.carbsInk,
                            ),
                            PtTag(
                              label: 'F ${pending.fatGrams}g',
                              color: p.fatInk,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // TDEE calculator shortcut
                  PtButton(
                    label: l10n.goalsCalcTdee,
                    icon: Icons.calculate_outlined,
                    tone: PtButtonTone.soft,
                    expand: true,
                    onPressed: () => TdeeCalculatorSheet.show(context),
                  ),
                  const SizedBox(height: 14),
                  // ── Mode toggle ────────────────────────────────────────
                  PtSegmented<_GoalMode>(
                    segments: [
                      PtSegment(_GoalMode.manual, l10n.goalModeManual),
                      PtSegment(_GoalMode.percentages, l10n.goalModePercent),
                      PtSegment(
                        _GoalMode.macrosToCalories,
                        l10n.goalModeMacros,
                      ),
                    ],
                    selected: _mode,
                    onChanged: (m) => setState(() => _mode = m),
                  ),
                  // ── Mode description ───────────────────────────────────
                  AnimatedSwitcher(
                    duration: Pt.base,
                    child: Padding(
                      key: ValueKey(_mode),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(switch (_mode) {
                        _GoalMode.manual => l10n.goalModeManualDesc,
                        _GoalMode.percentages => l10n.goalModePercentDesc,
                        _GoalMode.macrosToCalories => l10n.goalModeMacrosDesc,
                      }, style: PtText.small(color: p.textMuted)),
                    ),
                  ),
                  // ── Mode content ───────────────────────────────────────
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
                          _GoalMode.manual => _manualMode(),
                          _GoalMode.percentages => _percentagesMode(),
                          _GoalMode.macrosToCalories => _macrosToCaloriesMode(),
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  PtButton(
                    label: l10n.goalsSaveBtn,
                    icon: Icons.check_rounded,
                    expand: true,
                    haptic: true,
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),

          // ── Water tracking ──────────────────────────────────────────────
          PtSectionHeader(
            l10n.waterTrackingTitle,
            subtitle: l10n.waterTrackingSubtitle,
          ),
          enter(
            PtCard(
              padding: EdgeInsets.zero,
              child: AnimatedSize(
                duration: Pt.base,
                curve: Pt.ease,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    PtSwitchTile(
                      value: _waterEnabled,
                      leading: IconBadge(
                        Icons.water_drop_rounded,
                        color: p.water,
                        size: 40,
                      ),
                      onChanged: (v) {
                        setState(() => _waterEnabled = v);
                        _saveWaterSettings();
                      },
                      title: l10n.waterShowTracker,
                      subtitle: l10n.waterShowTrackerSub,
                    ),
                    if (_waterEnabled) ...[
                      const PtDivider(indent: 0),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        child: TextField(
                          controller: _waterGoalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.waterDailyGoal,
                            suffixText: l10n.waterGlassesUnit,
                            prefixIcon: Icon(
                              Icons.local_drink_rounded,
                              color: p.water,
                            ),
                          ),
                          onChanged: (_) => _saveWaterSettings(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Body weight ─────────────────────────────────────────────────
          PtSectionHeader(l10n.bodyWeight, subtitle: l10n.goalsWeightSubtitle),
          enter(
            PtCard(
              padding: EdgeInsets.zero,
              child: PtTile(
                leading: IconBadge(
                  Icons.straighten_rounded,
                  color: p.primary,
                  size: 40,
                ),
                title: l10n.weightUnitTitle,
                titleStyle: PtText.tile(
                  color: p.text,
                ).copyWith(fontWeight: FontWeight.w600),
                subtitle: l10n.weightUnitSub,
                trailing: SizedBox(
                  width: 112,
                  child: PtSegmented<WeightUnit>(
                    compact: true,
                    segments: [
                      for (final u in WeightUnit.values) PtSegment(u, u.symbol),
                    ],
                    selected: store.weightUnit,
                    onChanged: store.setWeightUnit,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          enter(const WeightCard()),

          // ── Health sync (Premium) ───────────────────────────────────────
          PtSectionHeader(
            l10n.healthSync,
            subtitle: l10n.healthSyncSettingSubtitle,
          ),
          enter(const HealthSyncSetting()),

          // ── Reminders ───────────────────────────────────────────────────
          PtSectionHeader(l10n.reminderTitle, subtitle: l10n.reminderSubtitle),
          enter(
            _ReminderSection(
              enabled: _reminderEnabled,
              time: _reminderTime,
              onToggle: (v) => _setReminder(enabled: v),
              onTimeTap: _pickReminderTime,
            ),
          ),

          // ── Appearance ──────────────────────────────────────────────────
          PtSectionHeader(
            l10n.appearanceTitle,
            subtitle: l10n.appearanceSubtitle,
          ),
          enter(
            PtSegmented<ThemeMode>(
              segments: [
                PtSegment(
                  ThemeMode.system,
                  l10n.themeSystem,
                  icon: Icons.brightness_auto_rounded,
                ),
                PtSegment(
                  ThemeMode.light,
                  l10n.themeLight,
                  icon: Icons.light_mode_rounded,
                ),
                PtSegment(
                  ThemeMode.dark,
                  l10n.themeDark,
                  icon: Icons.dark_mode_rounded,
                ),
              ],
              selected: appearance.value,
              onChanged: appearance.set,
            ),
          ),

          // ── Feedback ────────────────────────────────────────────────────
          PtSectionHeader(l10n.feedbackTitle, subtitle: l10n.feedbackBody),
          enter(
            PtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  PtTile(
                    leading: IconBadge(
                      Icons.feedback_rounded,
                      color: p.primary,
                      size: 40,
                    ),
                    title: l10n.feedbackShare,
                    titleStyle: PtText.tile(
                      color: p.text,
                    ).copyWith(fontWeight: FontWeight.w600),
                    subtitle: 'zibaentertainment.com/feedback',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: p.textMuted,
                    ),
                    onTap: () => launchUrl(
                      Uri.parse('https://zibaentertainment.com/feedback/'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  const PtDivider(indent: 70),
                  PtTile(
                    leading: IconBadge(
                      Icons.policy_outlined,
                      color: p.protein,
                      size: 40,
                    ),
                    title: l10n.privacyPolicy,
                    titleStyle: PtText.tile(
                      color: p.text,
                    ).copyWith(fontWeight: FontWeight.w600),
                    subtitle: l10n.privacyPolicySubtitle,
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: p.textMuted,
                    ),
                    onTap: () => launchUrl(
                      Uri.parse(privacyPolicyUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  // Required by Google wherever the consent form was shown: a
                  // way to change or withdraw ad consent later.
                  ValueListenableBuilder<bool>(
                    valueListenable:
                        ConsentGate.instance.privacyOptionsRequired,
                    builder: (context, required, _) => !required
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              const PtDivider(indent: 70),
                              PtTile(
                                leading: IconBadge(
                                  Icons.privacy_tip_outlined,
                                  color: p.protein,
                                  size: 40,
                                ),
                                title: l10n.privacyOptions,
                                titleStyle: PtText.tile(
                                  color: p.text,
                                ).copyWith(fontWeight: FontWeight.w600),
                                subtitle: l10n.privacyOptionsSubtitle,
                                trailing: Icon(
                                  Icons.chevron_right_rounded,
                                  color: p.textMuted,
                                ),
                                onTap: () =>
                                    ConsentGate.instance.showPrivacyOptions(),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),

          // ── Data export ─────────────────────────────────────────────────
          PtSectionHeader(
            l10n.dataExportTitle,
            subtitle: l10n.dataExportSubtitle,
          ),
          enter(
            PtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Builder(
                    builder: (tileContext) => PtTile(
                      leading: IconBadge(
                        Icons.table_chart_outlined,
                        color: p.fresh,
                        size: 40,
                      ),
                      title: l10n.exportCsv,
                      titleStyle: PtText.tile(
                        color: p.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                      subtitle: l10n.exportCsvSub,
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: p.textMuted,
                      ),
                      onTap: () {
                        final store = context.read<FoodStore>();
                        _export(
                          tileContext,
                          (origin) => ExportService.exportCsv(
                            entries: store.allEntries,
                            weightLog: store.weightLog.toList(),
                            activities: store.activities.toList(),
                            sharePositionOrigin: origin,
                          ),
                        );
                      },
                    ),
                  ),
                  const PtDivider(indent: 70),
                  Builder(
                    builder: (tileContext) => PtTile(
                      leading: IconBadge(
                        Icons.data_object_rounded,
                        color: p.carbs,
                        size: 40,
                      ),
                      title: l10n.exportJson,
                      titleStyle: PtText.tile(
                        color: p.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                      subtitle: l10n.exportJsonSub,
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: p.textMuted,
                      ),
                      onTap: () {
                        final store = context.read<FoodStore>();
                        _export(
                          tileContext,
                          (origin) => ExportService.exportJson(
                            entries: store.allEntries,
                            weightLog: store.weightLog.toList(),
                            activities: store.activities.toList(),
                            sharePositionOrigin: origin,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Debug tools — null in release, so this collapses to nothing in a
          // shipped build.
          ...?_debugSection(context),

          // ── More from ZiBa ──────────────────────────────────────────────
          const SizedBox(height: 28),
          MoreFromZiba(
            selfId: 'platesimple',
            group: ZibaGroup.wellness,
            title: 'More from ZiBa',
            textColor: p.text,
            mutedColor: p.textMuted,
            cardColor: p.surface,
            borderColor: p.isDark ? p.border : p.surface,
          ),

          // ── About ───────────────────────────────────────────────────────
          const SizedBox(height: 24),
          Row(
            children: [
              const Sprout(mood: SproutMood.happy, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutTitle.toUpperCase(),
                      style: PtText.label(color: p.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0\n'
                      'Food data provided by Open Food Facts (openfoodfacts.org) — '
                      'open database, open data, made by everyone.',
                      style: PtText.tiny(
                        color: p.textMuted,
                      ).copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveWaterSettings() async {
    final goal = int.tryParse(_waterGoalCtrl.text) ?? 8;
    await context.read<FoodStore>().setWaterSettings(
      enabled: _waterEnabled,
      goal: goal.clamp(1, 30),
    );
  }

  Future<void> _setReminder({required bool enabled}) async {
    if (enabled) {
      final granted =
          await NotificationService.instance.requestPermissions(context);
      if (!mounted) return;
      if (!granted) {
        // A reminder that can never be shown must not look switched on.
        setState(() => _reminderEnabled = false);
        _showNotificationsOffHint();
        return;
      }
    }

    setState(() => _reminderEnabled = enabled);
    final store = context.read<FoodStore>();
    await store.setReminder(
      enabled: enabled,
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
    );
    if (!mounted) return;

    if (enabled) {
      final l10n = context.l10n;
      await NotificationService.instance.scheduleDaily(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
        title: l10n.notifTitle,
        body: l10n.notifBody,
        channelName: l10n.notifChannelName,
        channelDescription: l10n.notifChannelDesc,
      );
    } else {
      await NotificationService.instance.cancelReminder();
    }
  }

  /// Notification permission is denied: say so, and offer the system
  /// settings, the only place it can be turned back on.
  void _showNotificationsOffHint() {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.reminderPermissionDenied),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l10n.openSettings,
            onPressed: () => AppSettings.openAppSettings(
              type: AppSettingsType.notification,
            ),
          ),
        ),
      );
  }

  /// Runs an export, anchored to the tapped row for the iPad popover, and
  /// reports a failure instead of letting it vanish.
  Future<void> _export(
    BuildContext tileContext,
    Future<void> Function(Rect? origin) run,
  ) async {
    final origin = ExportService.shareOriginOf(tileContext);
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.shareFailed;
    try {
      await run(origin);
    } catch (e) {
      debugPrint('[export] failed: $e');
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) return;
    setState(() => _reminderTime = picked);
    final store = context.read<FoodStore>();
    await store.setReminder(
      enabled: _reminderEnabled,
      hour: picked.hour,
      minute: picked.minute,
    );
    if (_reminderEnabled && mounted) {
      final l10n = context.l10n;
      await NotificationService.instance.scheduleDaily(
        hour: picked.hour,
        minute: picked.minute,
        title: l10n.notifTitle,
        body: l10n.notifBody,
        channelName: l10n.notifChannelName,
        channelDescription: l10n.notifChannelDesc,
      );
    }
  }
}

/// Upgrade card for free users (opens the paywall), a quiet "member" card
/// for subscribers.
class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.isPremium});
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    const ink = Color(0xFF3A2606);
    return PtCard(
      onTap: isPremium
          ? null
          : () => PremiumScreen.show(context, source: 'goals_banner'),
      gradient: isPremium ? null : Pt.premiumGradient(p),
      color: isPremium ? p.freshSoft : null,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPremium
                  ? p.fresh.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPremium
                  ? Icons.verified_rounded
                  : Icons.workspace_premium_rounded,
              color: isPremium ? p.primary : ink,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium
                      ? l10n.premiumBannerMemberTitle
                      : l10n.premiumBannerUpgradeTitle,
                  style: PtText.headline(color: isPremium ? p.text : ink),
                ),
                const SizedBox(height: 2),
                Text(
                  isPremium
                      ? l10n.premiumBannerMemberSub
                      : l10n.premiumBannerUpgradeSub,
                  style: PtText.small(
                    color: isPremium ? p.textMuted : ink.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium) const Icon(Icons.chevron_right_rounded, color: ink),
        ],
      ),
    );
  }
}

class _ReminderSection extends StatelessWidget {
  const _ReminderSection({
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimeTap,
  });

  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    return PtCard(
      padding: EdgeInsets.zero,
      child: AnimatedSize(
        duration: Pt.base,
        curve: Pt.ease,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            PtSwitchTile(
              value: enabled,
              onChanged: onToggle,
              leading: IconBadge(
                Icons.notifications_active_rounded,
                color: p.honey,
                size: 40,
              ),
              title: l10n.reminderEnable,
              subtitle: l10n.reminderEnableSub,
            ),
            if (enabled) ...[
              const PtDivider(indent: 0),
              PtTile(
                leading: IconBadge(
                  Icons.access_time_rounded,
                  color: p.primary,
                  size: 40,
                ),
                title: l10n.reminderTimeLabel,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: p.primarySoft,
                    borderRadius: BorderRadius.circular(Pt.rPill),
                  ),
                  child: Text(
                    time.format(context),
                    style: PtText.number(16, color: p.primary),
                  ),
                ),
                onTap: onTimeTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
