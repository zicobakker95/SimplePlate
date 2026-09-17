import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../screens/premium/premium_screen.dart';
import '../services/food_store.dart';
import '../services/health_sync_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';

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
    final store = context.watch<FoodStore>();
    final isIOS = Platform.isIOS;
    return ListenableBuilder(
      listenable: SubscriptionService.instance,
      builder: (context, _) {
        final premium = SubscriptionService.instance.isPremium;
        final enabled = premium && store.healthSyncEnabled;
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                value: enabled,
                onChanged: _busy ? null : _toggle,
                secondary: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(
                        premium
                            ? Icons.favorite_rounded
                            : Icons.workspace_premium_rounded,
                        color: premium ? Colors.redAccent : AppColors.primary,
                      ),
                title: Text(
                  isIOS
                      ? l10n.healthSyncSettingApple
                      : l10n.healthSyncSettingGoogle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: premium ? null : Text(l10n.healthSyncPremiumOnly),
                activeThumbColor: AppColors.primary,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(
                  isIOS
                      ? l10n.healthSyncExplainApple
                      : l10n.healthSyncExplainGoogle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              if (_denied) ...[
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isIOS
                              ? l10n.healthDeniedIos
                              : l10n.healthDeniedAndroid,
                          style: const TextStyle(
                              color: Colors.orange, fontSize: 11),
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppSettings.openAppSettings(),
                        child: Text(l10n.openSettings,
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
