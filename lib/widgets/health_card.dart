import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
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
  bool _permissionDenied = false;
  double _burnedFromHealth = 0;
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    if (HealthService.instance.isAuthorised) _refresh();
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _permissionDenied = false;
    });
    final ok = await HealthService.instance.requestPermissions();
    if (!mounted) return;
    setState(() => _connecting = false);
    if (ok) {
      await _refresh();
    } else {
      setState(() => _permissionDenied = true);
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
          content: Text(
              ok ? context.l10n.healthSynced : context.l10n.healthWriteFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                Text(l10n.healthSync,
                    style: const TextStyle(
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
                Platform.isIOS
                    ? l10n.healthConnectApple
                    : l10n.healthConnectGoogle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              if (_permissionDenied) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          Platform.isIOS
                              ? l10n.healthDeniedIos
                              : l10n.healthDeniedAndroid,
                          style: const TextStyle(
                              color: Colors.orange, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.settings_rounded, size: 14),
                  label: Text(l10n.openSettings),
                  onPressed: () => AppSettings.openAppSettings(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
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
                  label: Text(
                      _permissionDenied ? l10n.tryAgain : l10n.connectHealth),
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
                  _Stat(l10n.statSteps, '$_steps',
                      Icons.directions_walk_rounded, Colors.blueAccent),
                  const SizedBox(width: 16),
                  _Stat(l10n.statBurned, '${_burnedFromHealth.round()} kcal',
                      Icons.local_fire_department_rounded, Colors.orange),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_rounded, size: 16),
                label: Text(l10n.syncNutrition),
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
