import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../screens/premium/premium_screen.dart';
import '../services/food_store.dart';
import '../services/health_sync_service.dart';
import '../services/subscription_service.dart';
import '../ui/kit.dart';

/// The Health sync switch under Goals, with a plain account of what is read
/// and written before anyone is asked for a permission. Premium: a free
/// user can read the explanation, and flipping the switch opens the paywall
/// instead of the Health prompt.
class HealthSyncSetting extends StatefulWidget {
  const HealthSyncSetting({super.key});

  @override
  State<HealthSyncSetting> createState() => _HealthSyncSettingState();
}

class _HealthSyncSettingState extends State<HealthSyncSetting> {
  bool _busy = false;
  bool _denied = false;

  Future<void> _toggle(bool on) async {
    final store = context.read<FoodStore>();
    if (!on) {
      await store.setHealthSyncEnabled(false);
      if (mounted) setState(() => _denied = false);
      return;
    }
    if (!SubscriptionService.instance.isPremium) {
      PremiumScreen.show(context, source: 'health_sync_setting');
      return;
    }
    setState(() {
      _busy = true;
      _denied = false;
    });
    final granted = await HealthSyncService.instance.connect();
    if (!mounted) return;
    if (granted) await store.setHealthSyncEnabled(true);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _denied = !granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final store = context.watch<FoodStore>();
    final isIOS = Platform.isIOS;
    return ListenableBuilder(
      listenable: SubscriptionService.instance,
      builder: (context, _) {
        final premium = SubscriptionService.instance.isPremium;
        final enabled = premium && store.healthSyncEnabled;
        return PtCard(
          padding: EdgeInsets.zero,
          child: AnimatedSize(
            duration: Pt.base,
            curve: Pt.ease,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PtSwitchTile(
                  value: enabled,
                  onChanged: _busy ? null : _toggle,
                  leading: _busy
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconBadge(
                          premium
                              ? Icons.favorite_rounded
                              : Icons.workspace_premium_rounded,
                          color: premium ? p.fat : p.premium,
                          size: 40,
                        ),
                  title: isIOS
                      ? l10n.healthSyncSettingApple
                      : l10n.healthSyncSettingGoogle,
                  subtitle: premium ? null : l10n.healthSyncPremiumOnly,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Text(
                    isIOS
                        ? l10n.healthSyncExplainApple
                        : l10n.healthSyncExplainGoogle,
                    style: PtText.small(color: p.textMuted),
                  ),
                ),
                if (_denied)
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                    decoration: BoxDecoration(
                      color: p.honeySoft,
                      borderRadius: BorderRadius.circular(Pt.rSm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: p.honeyInk,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isIOS
                                ? l10n.healthDeniedIos
                                : l10n.healthDeniedAndroid,
                            style: PtText.tiny(color: p.honeyInk),
                          ),
                        ),
                        PtButton(
                          label: l10n.openSettings,
                          tone: PtButtonTone.ghost,
                          compact: true,
                          onPressed: () => AppSettings.openAppSettings(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
