import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_entry.dart';
import '../services/food_store.dart';
import '../theme/app_colors.dart';

/// Common activity presets for quick logging.
const _presets = [
  (name: 'Walking', met: 3.5),
  (name: 'Running', met: 9.8),
  (name: 'Cycling', met: 7.5),
  (name: 'Swimming', met: 8.0),
  (name: 'Weight training', met: 5.0),
  (name: 'Yoga', met: 2.5),
  (name: 'HIIT', met: 8.5),
  (name: 'Hiking', met: 6.0),
];

/// Card that shows today's activity log and provides an "Add activity" button.
class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final activities = store.todayActivities;
    final burned = store.todayBurned();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_run_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                const Text('Activity',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                if (burned > 0)
                  Text(
                    '−${burned.round()} kcal',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
              ],
            ),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No activity logged today.',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12),
                ),
              )
            else
              for (final a in activities)
                _ActivityTile(entry: a),
            TextButton.icon(
              onPressed: () => _showLogDialog(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add activity'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _LogActivitySheet(),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});
  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(entry.name,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text('${entry.durationMinutes} min',
          style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '−${entry.caloriesBurned} kcal',
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.textMuted),
            onPressed: () =>
                context.read<FoodStore>().deleteActivity(entry.id),
            padding: const EdgeInsets.only(left: 4),
            constraints: const BoxConstraints(),
            tooltip: 'Remove',
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
  ({String name, double met})? _selectedPreset;
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

  Future<void> _log() async {
    final duration = int.tryParse(_durationCtrl.text) ?? 0;
    if (duration <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid duration.')));
      return;
    }

    final String name;
    final int burned;

    if (_manualMode) {
      name = _nameCtrl.text.trim().isEmpty
          ? 'Custom activity'
          : _nameCtrl.text.trim();
      burned = int.tryParse(_calCtrl.text) ?? 0;
      if (burned <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter calories burned.')));
        return;
      }
    } else {
      if (_selectedPreset == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select an activity first.')));
        return;
      }
      name = _selectedPreset!.name;
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
    final tt = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    final estimated = _manualMode ? 0 : _estimateCalories();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Log activity',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          // Mode toggle
          Row(
            children: [
              ChoiceChip(
                label: const Text('Presets'),
                selected: !_manualMode,
                onSelected: (_) => setState(() => _manualMode = false),
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                    color: !_manualMode
                        ? AppColors.primary
                        : AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Manual'),
                selected: _manualMode,
                onSelected: (_) => setState(() => _manualMode = true),
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                    color: _manualMode
                        ? AppColors.primary
                        : AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!_manualMode) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) {
                final selected = _selectedPreset?.name == p.name;
                return ChoiceChip(
                  label: Text(p.name),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedPreset = p),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12),
                );
              }).toList(),
            ),
          ] else ...[
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Activity name',
                hintText: 'e.g. Soccer, Dancing…',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _calCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories burned',
                suffixText: 'kcal',
              ),
            ),
          ],

          const SizedBox(height: 12),
          TextField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Duration',
              suffixText: 'min',
            ),
            onChanged: (_) => setState(() {}),
          ),

          if (!_manualMode && _selectedPreset != null && estimated > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Estimated: ~$estimated kcal burned',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _log,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Log activity'),
            ),
          ),
        ],
      ),
    );
  }
}
