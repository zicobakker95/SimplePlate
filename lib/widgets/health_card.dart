import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/food_store.dart';
import '../services/health_service.dart';
import '../theme/app_colors.dart';

/// Card for the Today screen showing Health Connect / Apple Health data.
class HealthSyncCard extends StatefulWidget {
  const HealthSyncCard({super.key});

  @override
  State<HealthSyncCard> createState() => _HealthSyncCardState();
}

class _HealthSyncCardState extends State<HealthSyncCard> {
  bool _connecting = false;
  bool _syncing = false;
  double _burnedFromHealth = 0;
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    if (HealthService.instance.isAuthorised) _refresh();
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    final ok = await HealthService.instance.requestPermissions();
    if (!mounted) return;
    setState(() => _connecting = false);
    if (ok) {
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Health access not granted. Check permissions.')),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() => _syncing = true);
    final burned = await HealthService.instance.fetchCaloriesBurnedToday();
    final steps = await HealthService.instance.fetchStepsToday();
    if (!mounted) return;
    setState(() {
      _burnedFromHealth = burned;
      _steps = steps;
      _syncing = false;
    });
  }

  Future<void> _writeNutrition() async {
    final store = context.read<FoodStore>();
    final ok = await HealthService.instance.writeNutrition(
      calories: store.todayCalories(),
      protein: store.todayProtein(),
      carbs: store.todayCarbs(),
      fat: store.todayFat(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(ok
              ? 'Nutrition synced to Health!'
              : 'Could not write to Health.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authorised = HealthService.instance.isAuthorised;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
                const Text('Health sync',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                if (authorised && _syncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (authorised)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    color: AppColors.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _refresh,
                  ),
              ],
            ),
            if (!authorised) ...[
              const SizedBox(height: 8),
              Text(
                'Connect Apple Health or Google Health Connect to import calories burned and sync your nutrition.',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: _connecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.link_rounded, size: 16),
                  label: const Text('Connect Health'),
                  onPressed: _connecting ? null : _connect,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stat('Steps', '$_steps', Icons.directions_walk_rounded,
                      Colors.blueAccent),
                  const SizedBox(width: 16),
                  _Stat('Burned', '${_burnedFromHealth.round()} kcal',
                      Icons.local_fire_department_rounded, Colors.orange),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_rounded, size: 16),
                label: const Text('Sync nutrition to Health'),
                onPressed: _writeNutrition,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon, this.color);
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
