import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/nutrition_goals.dart';
import '../../screens/premium/premium_screen.dart';
import '../../services/food_store.dart';
import '../../services/notification_service.dart';
import '../../services/subscription_service.dart';
import '../../theme/app_colors.dart';

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
    _reminderTime =
        TimeOfDay(hour: store.reminderHour, minute: store.reminderMinute);

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

    // Rebuild when any field changes so live calculations update
    for (final c in [
      _calPctCtrl, _proPctCtrl, _carbPctCtrl, _fatPctCtrl,
      _proGCtrl, _carbGCtrl, _fatGCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _calCtrl, _proCtrl, _carbCtrl, _fatCtrl,
      _calPctCtrl, _proPctCtrl, _carbPctCtrl, _fatPctCtrl,
      _proGCtrl, _carbGCtrl, _fatGCtrl,
      _waterGoalCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Derived values ──────────────────────────────────────────────────────────

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

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    late NutritionGoals goals;
    switch (_mode) {
      case _GoalMode.manual:
        goals = NutritionGoals(
          dailyCalories: int.tryParse(_calCtrl.text) ?? 2000,
          proteinGrams: int.tryParse(_proCtrl.text) ?? 150,
          carbsGrams: int.tryParse(_carbCtrl.text) ?? 200,
          fatGrams: int.tryParse(_fatCtrl.text) ?? 65,
        );
      case _GoalMode.percentages:
        goals = NutritionGoals(
          dailyCalories: _pctCalories,
          proteinGrams: _calcProteinG,
          carbsGrams: _calcCarbsG,
          fatGrams: _calcFatG,
        );
      case _GoalMode.macrosToCalories:
        goals = NutritionGoals(
          dailyCalories: _calcCalories,
          proteinGrams: _macroProteinG,
          carbsGrams: _macroCarbsG,
          fatGrams: _macroFatG,
        );
    }
    setState(() => _saving = true);
    await context.read<FoodStore>().saveGoals(goals);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Goals saved!')));
  }

  // ── Widgets ─────────────────────────────────────────────────────────────────

  Widget _field(String label, TextEditingController ctrl, Color accent,
      String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  Widget _readonlyCard(String label, String value, Color accent) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  color: accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _pctHint(String macro, int grams, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        '  → $grams g $macro',
        style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _pctSumIndicator() {
    final sum = _pctSum.round();
    final ok = sum == 100;
    final color = ok ? AppColors.primary : AppColors.fat;
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            ok
                ? 'Percentages add up to 100% ✓'
                : 'Percentages add up to $sum% (should be 100%)',
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _manualMode() {
    return Column(children: [
      _field('Calories', _calCtrl, AppColors.calories, 'kcal'),
      _field('Protein', _proCtrl, AppColors.protein, 'g'),
      _field('Carbohydrates', _carbCtrl, AppColors.carbs, 'g'),
      _field('Fat', _fatCtrl, AppColors.fat, 'g'),
    ]);
  }

  Widget _percentagesMode() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _field('Daily calories', _calPctCtrl, AppColors.calories, 'kcal'),
      const SizedBox(height: 4),
      _field('Protein %', _proPctCtrl, AppColors.protein, '%'),
      _pctHint('protein', _calcProteinG, AppColors.protein),
      _field('Carbohydrates %', _carbPctCtrl, AppColors.carbs, '%'),
      _pctHint('carbs', _calcCarbsG, AppColors.carbs),
      _field('Fat %', _fatPctCtrl, AppColors.fat, '%'),
      _pctHint('fat', _calcFatG, AppColors.fat),
      _pctSumIndicator(),
    ]);
  }

  Widget _macrosToCaloriesMode() {
    return Column(children: [
      _field('Protein', _proGCtrl, AppColors.protein, 'g'),
      _field('Carbohydrates', _carbGCtrl, AppColors.carbs, 'g'),
      _field('Fat', _fatGCtrl, AppColors.fat, 'g'),
      const SizedBox(height: 8),
      _readonlyCard('Calculated calories', '$_calcCalories kcal',
          AppColors.calories),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Premium banner ────────────────────────────────────────────────
          ListenableBuilder(
            listenable: SubscriptionService.instance,
            builder: (context, _) {
              final isPremium = SubscriptionService.instance.isPremium;
              return GestureDetector(
                onTap: isPremium ? null : () => PremiumScreen.show(context),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPremium
                          ? [const Color(0xFF1A2E1A), const Color(0xFF1B3A1B)]
                          : [const Color(0xFF1A1A2E), const Color(0xFF2D1B69)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPremium
                          ? Colors.greenAccent.withValues(alpha: 0.4)
                          : AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPremium
                            ? Icons.verified_rounded
                            : Icons.workspace_premium_rounded,
                        color: isPremium
                            ? Colors.greenAccent
                            : AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPremium
                                  ? 'You\'re a Premium member'
                                  : 'Upgrade to Premium',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isPremium
                                      ? Colors.greenAccent
                                      : Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPremium
                                  ? 'Weekly insights unlocked · No ads'
                                  : 'Weekly insights · No ads · Support dev',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isPremium
                                      ? Colors.greenAccent.withValues(alpha: 0.8)
                                      : Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      if (!isPremium)
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.white54),
                    ],
                  ),
                ),
              );
            },
          ),
          Text('Daily nutrition targets',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Choose how you want to set your goals.',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // ── Mode toggle ────────────────────────────────────────────────────
          SegmentedButton<_GoalMode>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary.withOpacity(0.2),
              selectedForegroundColor: AppColors.primary,
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
            ),
            segments: const [
              ButtonSegment(
                value: _GoalMode.manual,
                icon: Icon(Icons.edit_outlined, size: 16),
                label: Text('Manual'),
              ),
              ButtonSegment(
                value: _GoalMode.percentages,
                icon: Icon(Icons.percent, size: 16),
                label: Text('% → Macros'),
              ),
              ButtonSegment(
                value: _GoalMode.macrosToCalories,
                icon: Icon(Icons.calculate_outlined, size: 16),
                label: Text('Macros → kcal'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 6),

          // ── Mode description ───────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Padding(
              key: ValueKey(_mode),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                switch (_mode) {
                  _GoalMode.manual =>
                    'Enter your calories and macro grams directly.',
                  _GoalMode.percentages =>
                    'Enter total calories and the % split — grams are calculated live.',
                  _GoalMode.macrosToCalories =>
                    'Enter your macro grams — total calories are calculated live.',
                },
                style:
                    tt.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Mode content ───────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
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

          // ── Water tracking ─────────────────────────────────────────────────
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Text('Water tracking',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Track your daily water intake on the home screen.',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _waterEnabled,
                  onChanged: (v) {
                    setState(() => _waterEnabled = v);
                    _saveWaterSettings();
                  },
                  title: const Text('Show water tracker',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Displays water card on Today screen'),
                  activeColor: AppColors.primary,
                ),
                if (_waterEnabled) ...[
                  const Divider(height: 1, color: AppColors.border),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: TextField(
                      controller: _waterGoalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Daily goal',
                        suffixText: 'glasses',
                        prefixIcon: Icon(Icons.water_drop_rounded,
                            color: Colors.lightBlue),
                      ),
                      onChanged: (_) => _saveWaterSettings(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Reminders ──────────────────────────────────────────────────────
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Text('Daily reminder',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Get a daily nudge to log your meals.',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _ReminderSection(
            enabled: _reminderEnabled,
            time: _reminderTime,
            onToggle: (v) => _setReminder(enabled: v),
            onTimeTap: _pickReminderTime,
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Text('Feedback',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            "I'm a solo developer and your feedback helps make PlateSimple better. "
            'Takes less than a minute!',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback_rounded,
                  color: AppColors.primary),
              title: const Text('Share feedback',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('zibaentertainment.com/feedback'),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => launchUrl(
                Uri.parse('https://zibaentertainment.com/feedback/'),
                mode: LaunchMode.externalApplication,
              ),
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
            style: tt.bodySmall
                ?.copyWith(color: AppColors.textMuted, height: 1.6),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWaterSettings() async {
    final goal = int.tryParse(_waterGoalCtrl.text) ?? 8;
    await context
        .read<FoodStore>()
        .setWaterSettings(enabled: _waterEnabled, goal: goal.clamp(1, 30));
  }

  Future<void> _setReminder({required bool enabled}) async {
    await NotificationService.instance
        .requestPermissions(context);
    if (!mounted) return;

    setState(() => _reminderEnabled = enabled);
    final store = context.read<FoodStore>();
    await store.setReminder(
        enabled: enabled,
        hour: _reminderTime.hour,
        minute: _reminderTime.minute);

    if (enabled) {
      await NotificationService.instance.scheduleDaily(
          hour: _reminderTime.hour, minute: _reminderTime.minute);
    } else {
      await NotificationService.instance.cancelReminder();
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
        minute: picked.minute);
    if (_reminderEnabled) {
      await NotificationService.instance
          .scheduleDaily(hour: picked.hour, minute: picked.minute);
    }
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
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            value: enabled,
            onChanged: onToggle,
            title: const Text('Enable reminder',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Sends a daily notification'),
            activeColor: AppColors.primary,
          ),
          if (enabled) ...[
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.access_time_rounded,
                  color: AppColors.primary),
              title: const Text('Reminder time'),
              trailing: Text(
                time.format(context),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 16),
              ),
              onTap: onTimeTap,
            ),
          ],
        ],
      ),
    );
  }
}
