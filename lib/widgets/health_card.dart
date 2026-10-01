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
import '../ui/kit.dart';

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
    showPtToast(
      context,
      context.l10n.healthWeightImported,
      icon: Icons.check_circle_rounded,
      tone: PtToastTone.success,
    );
  }

  Future<void> _writeNutrition() async {
    final store = context.read<FoodStore>();
    final now = DateTime.now();
    final ok = await HealthSyncService.instance.syncDay(
      now,
      store.entriesForDay(now),
    );
    if (!mounted) return;
    showPtToast(
      context,
      ok ? context.l10n.healthSynced : context.l10n.healthWriteFailed,
      icon: ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
      tone: ok ? PtToastTone.success : PtToastTone.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final store = context.watch<FoodStore>();
    return ListenableBuilder(
      listenable: SubscriptionService.instance,
      builder: (context, _) {
        final premium = SubscriptionService.instance.isPremium;
        final enabled = premium && store.healthSyncEnabled;
        return PtCard(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(
                    premium
                        ? Icons.favorite_rounded
                        : Icons.workspace_premium_rounded,
                    color: premium ? p.fat : p.premium,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.healthSync,
                      style: PtText.tile(
                        color: p.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (!premium)
                    PtTag(
                      label: 'Premium',
                      color: p.premiumInk,
                      icon: Icons.star_rounded,
                    )
                  else if (enabled && _syncing)
                    const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (enabled)
                    PtIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: l10n.syncNutrition,
                      background: Colors.transparent,
                      color: p.primary,
                      size: 36,
                      iconSize: 20,
                      onPressed: _refresh,
                    ),
                ],
              ),
              AnimatedSize(
                duration: Pt.base,
                curve: Pt.ease,
                alignment: Alignment.topCenter,
                child: !premium
                    ? _teaser(l10n, p)
                    : !enabled
                    ? _connectPrompt(l10n, p)
                    : _stats(l10n, p, store),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _teaser(AppLocalizations l10n, PlatePalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(l10n.healthSyncTeaserSub, style: PtText.small(color: p.textMuted)),
        const SizedBox(height: 14),
        PtButton(
          label: l10n.upgradeToPremium,
          icon: Icons.workspace_premium_rounded,
          tone: PtButtonTone.premium,
          compact: true,
          expand: true,
          onPressed: () => PremiumScreen.show(context, source: 'health_card'),
        ),
      ],
    );
  }

  Widget _connectPrompt(AppLocalizations l10n, PlatePalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          Platform.isIOS ? l10n.healthConnectApple : l10n.healthConnectGoogle,
          style: PtText.small(color: p.textMuted),
        ),
        if (_permissionDenied) ...[
          const SizedBox(height: 10),
          _Notice(
            text: Platform.isIOS
                ? l10n.healthDeniedIos
                : l10n.healthDeniedAndroid,
          ),
        ],
        const SizedBox(height: 14),
        PtButton(
          label: _permissionDenied ? l10n.tryAgain : l10n.connectHealth,
          icon: Icons.link_rounded,
          tone: PtButtonTone.soft,
          color: p.fat,
          compact: true,
          expand: true,
          loading: _connecting,
          onPressed: _connecting ? null : _connect,
        ),
      ],
    );
  }

  Widget _stats(AppLocalizations l10n, PlatePalette p, FoodStore store) {
    final unit = store.weightUnit;
    final hw = _healthWeight;
    // Offer the Health reading only when that day has nothing in the log —
    // otherwise it is usually the app's own write coming back.
    final offerImport = hw != null && !store.hasWeightOn(hw.at);
    final locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            // Steps come from Apple Health only — Android reads just
            // calories and weight (Play minimum-scope policy).
            if (Platform.isIOS)
              Expanded(
                child: _Stat(
                  l10n.statSteps,
                  '$_steps',
                  Icons.directions_walk_rounded,
                  p.protein,
                  p.proteinInk,
                ),
              ),
            Expanded(
              child: _Stat(
                l10n.statBurned,
                '${_burnedFromHealth.round()} kcal',
                Icons.local_fire_department_rounded,
                p.carbs,
                p.carbsInk,
              ),
            ),
            if (hw != null)
              Expanded(
                child: _Stat(
                  l10n.statWeight,
                  '${unit.format(hw.kg)} · ${DateFormat('MMM d', locale).format(hw.at)}',
                  Icons.monitor_weight_outlined,
                  p.fresh,
                  p.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (offerImport)
              PtButton(
                label: l10n.healthAddWeightToLog(unit.format(hw.kg)),
                icon: Icons.download_rounded,
                compact: true,
                onPressed: () => _importWeight(hw),
              ),
            PtButton(
              label: l10n.syncNutrition,
              icon: Icons.upload_rounded,
              tone: PtButtonTone.soft,
              compact: true,
              onPressed: _writeNutrition,
            ),
          ],
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.honeySoft,
        borderRadius: BorderRadius.circular(Pt.rSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: p.honeyInk, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: PtText.tiny(color: p.honeyInk)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon, this.color, this.ink);
  final String label, value;
  final IconData icon;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: p.isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(Pt.rSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            style: PtText.small(color: ink, weight: FontWeight.w700),
          ),
          Text(label, style: PtText.tiny(color: p.textMuted)),
        ],
      ),
    );
  }
}
