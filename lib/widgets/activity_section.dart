import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/l10n.dart';
import '../models/activity_entry.dart';
import '../services/food_store.dart';
import '../ui/kit.dart';

/// Common activity presets for quick logging. [key] selects the localized
/// label; [met] is the metabolic equivalent for the calorie estimate.
const _presets = [
  (key: 'walking', met: 3.5, emoji: '🚶'),
  (key: 'running', met: 9.8, emoji: '🏃'),
  (key: 'cycling', met: 7.5, emoji: '🚴'),
  (key: 'swimming', met: 8.0, emoji: '🏊'),
  (key: 'weightTraining', met: 5.0, emoji: '🏋️'),
  (key: 'yoga', met: 2.5, emoji: '🧘'),
  (key: 'hiit', met: 8.5, emoji: '⚡'),
  (key: 'hiking', met: 6.0, emoji: '🥾'),
];

typedef _Preset = ({String key, double met, String emoji});

String _presetLabel(AppLocalizations l, String key) => switch (key) {
  'walking' => l.actWalking,
  'running' => l.actRunning,
  'cycling' => l.actCycling,
  'swimming' => l.actSwimming,
  'weightTraining' => l.actWeightTraining,
  'yoga' => l.actYoga,
  'hiit' => l.actHIIT,
  'hiking' => l.actHiking,
  _ => key,
};

/// Card that shows today's activity log and provides an "Add activity" button.
class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final l10n = context.l10n;
    final p = context.pal;
    final activities = store.todayActivities;
    final burned = store.todayBurned();

    return PtCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(Icons.directions_run_rounded, color: p.carbs, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.activity,
                      style: PtText.tile(
                        color: p.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (activities.isEmpty)
                      Text(
                        l10n.noActivityToday,
                        style: PtText.small(color: p.textMuted),
                      ),
                  ],
                ),
              ),
              if (burned > 0)
                PtTag(
                  label: '−${burned.round()} kcal',
                  color: p.carbsInk,
                  icon: Icons.local_fire_department_rounded,
                ),
            ],
          ),
          if (activities.isNotEmpty) const SizedBox(height: 6),
          for (final a in activities)
            PopIn(
              key: ValueKey(a.id),
              child: _ActivityTile(entry: a),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: PtButton(
              label: l10n.addActivity,
              icon: Icons.add_rounded,
              tone: PtButtonTone.soft,
              compact: true,
              onPressed: () => _showLogSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogSheet(BuildContext context) {
    return showPtSheet(
      context,
      title: context.l10n.logActivityTitle,
      builder: (_) => const _LogActivitySheet(),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});
  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: PtText.small(color: p.text, weight: FontWeight.w600),
                ),
                Text(
                  '${entry.durationMinutes} min',
                  style: PtText.tiny(color: p.textMuted),
                ),
              ],
            ),
          ),
          Text(
            '−${entry.caloriesBurned} kcal',
            style: PtText.number(13, color: p.carbsInk),
          ),
          PtIconButton(
            icon: Icons.close_rounded,
            tooltip: context.l10n.remove,
            background: Colors.transparent,
            color: p.textMuted,
            size: 32,
            iconSize: 18,
            onPressed: () => context.read<FoodStore>().deleteActivity(entry.id),
          ),
        ],
      ),
    );
  }
}

class _LogActivitySheet extends StatefulWidget {
  const _LogActivitySheet();

  @override
  State<_LogActivitySheet> createState() => _LogActivitySheetState();
}

class _LogActivitySheetState extends State<_LogActivitySheet> {
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '30');
  final _calCtrl = TextEditingController();
  _Preset? _selectedPreset;
  bool _manualMode = false;

  // Body weight used for MET-based calorie estimate (default 70 kg).
  double get _bodyWeightKg {
    final profile = context.read<FoodStore>().userProfile;
    return profile?.weightKg ?? 70.0;
  }

  int _estimateCalories() {
    final preset = _selectedPreset;
    if (preset == null) return 0;
    final mins = int.tryParse(_durationCtrl.text) ?? 30;
    // MET × weight(kg) × duration(h)
    return (preset.met * _bodyWeightKg * mins / 60).round();
  }

  void _warn(String message) => showPtToast(
    context,
    message,
    icon: Icons.error_outline_rounded,
    tone: PtToastTone.warning,
  );

  Future<void> _log() async {
    final l10n = context.l10n;
    final duration = int.tryParse(_durationCtrl.text) ?? 0;
    if (duration <= 0) {
      _warn(l10n.enterValidDuration);
      return;
    }

    final String name;
    final int burned;

    if (_manualMode) {
      name = _nameCtrl.text.trim().isEmpty
          ? l10n.customActivity
          : _nameCtrl.text.trim();
      burned = int.tryParse(_calCtrl.text) ?? 0;
      if (burned <= 0) {
        _warn(l10n.enterCaloriesBurned);
        return;
      }
    } else {
      if (_selectedPreset == null) {
        _warn(l10n.selectActivityFirst);
        return;
      }
      name = _presetLabel(l10n, _selectedPreset!.key);
      burned = _estimateCalories();
    }

    final entry = ActivityEntry(
      id: const Uuid().v4(),
      name: name,
      caloriesBurned: burned,
      durationMinutes: duration,
      loggedAt: DateTime.now(),
    );

    await context.read<FoodStore>().logActivity(entry);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final estimated = _manualMode ? 0 : _estimateCalories();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PtSegmented<bool>(
          segments: [
            PtSegment(false, l10n.presets, icon: Icons.grid_view_rounded),
            PtSegment(true, l10n.manual, icon: Icons.edit_outlined),
          ],
          selected: _manualMode,
          onChanged: (v) => setState(() => _manualMode = v),
        ),
        const SizedBox(height: 16),
        AnimatedSize(
          duration: Pt.base,
          curve: Pt.ease,
          alignment: Alignment.topCenter,
          child: !_manualMode
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in _presets)
                      PtChoiceChip(
                        label: _presetLabel(l10n, preset.key),
                        leading: preset.emoji,
                        selected: _selectedPreset?.key == preset.key,
                        color: p.isDark ? p.carbs : p.carbsInk,
                        onTap: () => setState(() => _selectedPreset = preset),
                      ),
                  ],
                )
              : Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.activityNameLabel,
                        hintText: l10n.activityNameHint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _calCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.caloriesBurnedLabel,
                        suffixText: 'kcal',
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _durationCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.durationLabel,
            suffixText: 'min',
            prefixIcon: const Icon(Icons.timer_outlined),
          ),
          onChanged: (_) => setState(() {}),
        ),
        AnimatedSwitcher(
          duration: Pt.base,
          child: !_manualMode && _selectedPreset != null && estimated > 0
              ? Padding(
                  key: ValueKey(estimated),
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: p.carbs,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.estimatedBurned(estimated),
                          style: PtText.small(
                            color: p.carbsInk,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        PtButton(
          label: l10n.logActivityTitle,
          icon: Icons.check_rounded,
          expand: true,
          haptic: true,
          onPressed: _log,
        ),
      ],
    );
  }
}
