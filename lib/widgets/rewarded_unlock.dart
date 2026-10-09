import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../screens/premium/premium_screen.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../ui/kit.dart';

enum _NoAdChoice { cancel, retry, premium }

/// Offers a rewarded ad in exchange for unlocking [key] for [days], and
/// resolves true once the feature is unlocked.
///
/// The unlock only ever comes from the ad's reward callback (or from buying
/// Premium). When no ad is available the user gets a friendly explanation
/// with a retry and the Premium upsell instead of a free pass, which is what
/// a single no-fill used to hand out. [placement] names the feature for
/// analytics.
Future<bool> unlockWithRewardedAd(
  BuildContext context, {
  required String key,
  required int days,
  required String placement,
}) async {
  final ads = AdService.instance;
  while (true) {
    final outcome = await ads.showRewardedUnlock(key: key, days: days);
    switch (outcome) {
      case RewardedOutcome.rewarded:
        AnalyticsService.instance.logEvent('rewarded_ad_watched', {
          'placement': placement,
        });
        return true;
      case RewardedOutcome.dismissed:
        return false;
      case RewardedOutcome.unavailable:
        if (!context.mounted) return false;
        final choice = await _showNoAdDialog(context);
        if (!context.mounted) return false;
        switch (choice) {
          case _NoAdChoice.retry:
            await _whileLoading(context, ads.retryRewarded());
            if (!context.mounted) return false;
            // Loaded: the loop shows it. Still nothing: it comes straight
            // back to this dialog.
            continue;
          case _NoAdChoice.premium:
            await PremiumScreen.show(context, source: '${placement}_no_ad');
            return ads.isUnlocked(key);
          case _NoAdChoice.cancel:
            return false;
        }
    }
  }
}

Future<_NoAdChoice> _showNoAdDialog(BuildContext context) async {
  final l10n = context.l10n;
  final choice = await showDialog<_NoAdChoice>(
    context: context,
    builder: (ctx) => PtDialog(
      title: l10n.adNotReadyTitle,
      body: '${l10n.unlockAdUnavailable}\n\n${l10n.adNotReadyPremiumHint}',
      icon: Icons.ondemand_video_rounded,
      actions: [
        PtButton(
          label: l10n.cancel,
          tone: PtButtonTone.ghost,
          compact: true,
          onPressed: () => Navigator.pop(ctx, _NoAdChoice.cancel),
        ),
        PtButton(
          label: l10n.upgradeToPremium,
          icon: Icons.workspace_premium_rounded,
          tone: PtButtonTone.soft,
          compact: true,
          onPressed: () => Navigator.pop(ctx, _NoAdChoice.premium),
        ),
        PtButton(
          label: l10n.retry,
          icon: Icons.refresh_rounded,
          compact: true,
          onPressed: () => Navigator.pop(ctx, _NoAdChoice.retry),
        ),
      ],
    ),
  );
  return choice ?? _NoAdChoice.cancel;
}

/// Shows a small blocking spinner while [work] runs.
Future<T> _whileLoading<T>(BuildContext context, Future<T> work) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  var open = true;
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  ).whenComplete(() => open = false);
  try {
    return await work;
  } finally {
    if (open && navigator.mounted) navigator.pop();
  }
}
