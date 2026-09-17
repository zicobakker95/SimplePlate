import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../screens/premium/premium_screen.dart';
import '../services/food_store.dart';
import '../services/health_service.dart';
import '../services/health_sync_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';

/// Card for the Today screen showing Health Connect / Apple Health data.
///
/// Three states. Free: a teaser that opens Premium. Premium with sync off:
/// one button that asks Health for access and switches sync on (the same
/// thing the Goals toggle does). Premium with sync on: today's steps (iOS)
/// and active calories, the newest weight Health has — with a one-tap way
/// to bring a scale reading into the log — and a manual push of today's
/// nutrition for anyone who wants to see it land.
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
  HealthWeight? _healthWeight;

  bool get _active =>
      SubscriptionService.instance.isPremium &&
      context.read<FoodStore>().healthSyncEnabled;

  @override
  void initState() {
    super.initState();
    if (_active) _refresh();
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _permissionDenied = false;
    });
    final ok = await HealthSyncService.instance.connect();
    if (!mounted) return;
    if (ok) await context.read<FoodStore>().setHealthSyncEnabled(true);
    if (!mounted) return;
    setState(() {
      _connecting = false;
      _permissionDenied = !ok;
    });
    if (ok) await _refresh();
  }

  Future<void> _refresh() async {
    if (!HealthService.instance.isAuthorised) {
      // A previous launch granted access; re-establish it without a prompt.
      await HealthSyncService.instance.restore();
    }
    if (!mounted) return;
    setState(() => _syncing = true);
    final burned = await HealthService.instance.fetchCaloriesBurnedToday();
    final steps = await HealthService.instance.fetchStepsToday();
    final weight = await HealthSyncService.instance.latestWeight();
    if (!mounted) return;
    setState(() {
      _burnedFromHealth = burned;
      _steps = steps;
      _healthWeight = weight;
      _syncing = false;
    });
  }

  Future<void> _importWeight(HealthWeight w) async {
    final store = context.read<FoodStore>();
    await store.logWeight(w.kg, at: w.at, fromHealth: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.healthWeightImported)));
  }

  Future<void> _writeNutrition() async {
    final store = context.read<FoodStore>();
    final now = DateTime.now();
    final ok = await HealthSyncService.instance
        .syncDay(now, store.entriesForDay(now));
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
    final store = context.watch<FoodStore>();
    return ListenableBuilder(
      listenable: SubscriptionService.instance,
      builder: (context, _) {
        final premium = SubscriptionService.instance.isPremium;
        final enabled = premium && store.healthSyncEnabled;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      premium
                          ? Icons.favorite_rounded
                          : Icons.workspace_premium_rounded,
                      color: premium ? Colors.redAccent : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.healthSync,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const Spacer(),
                    if (enabled && _syncing)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (enabled)
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        color: AppColors.primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _refresh,
                      ),
                  ],
                ),
                if (!premium)
                  _teaser(l10n)
                else if (!enabled)
                  _connectPrompt(l10n)
                else
                  _stats(l10n, store),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _teaser(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(l10n.healthSyncTeaserSub,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.workspace_premium_rounded, size: 16),
            label: Text(l10n.upgradeToPremium),
            onPressed: () => PremiumScreen.show(context),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _connectPrompt(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          Platform.isIOS ? l10n.healthConnectApple : l10n.healthConnectGoogle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        if (_permissionDenied) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Platform.isIOS
                      ? l10n.healthDeniedIos
                      : l10n.healthDeniedAndroid,
                  style: const TextStyle(color: Colors.orange, fontSize: 11),
                ),
              ),
            ],
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
            label: Text(_permissionDenied ? l10n.tryAgain : l10n.connectHealth),
            onPressed: _connecting ? null : _connect,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stats(AppLocalizations l10n, FoodStore store) {
    final unit = store.weightUnit;
    final hw = _healthWeight;
    // Offer the Health reading only when that day has nothing in the log —
    // otherwise it is usually the app's own write coming back.
    final offerImport = hw != null && !store.hasWeightOn(hw.at);
    final locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            // Steps come from Apple Health only — Android reads just
            // calories and weight (Play minimum-scope policy).
            if (Platform.isIOS)
              _Stat(l10n.statSteps, '$_steps', Icons.directions_walk_rounded,
                  Colors.blueAccent),
            _Stat(l10n.statBurned, '${_burnedFromHealth.round()} kcal',
                Icons.local_fire_department_rounded, Colors.orange),
            if (hw != null)
              _Stat(
                  l10n.statWeight,
                  '${unit.format(hw.kg)} · ${DateFormat('MMM d', locale).format(hw.at)}',
                  Icons.monitor_weight_outlined,
                  AppColors.primary),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (offerImport)
              FilledButton.tonalIcon(
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text(l10n.healthAddWeightToLog(unit.format(hw.kg))),
                onPressed: () => _importWeight(hw),
              ),
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
        ),
      ],
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
                    color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            Text(label,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
