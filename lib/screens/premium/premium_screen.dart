import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n.dart';
import '../../services/subscription_service.dart';
import '../../theme/app_colors.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  /// Push the paywall as a full-screen modal route.
  static Future<void> show(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const PremiumScreen(),
        ),
      );

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    final svc = SubscriptionService.instance;
    // Default selection: yearly (best value)
    if (svc.yearly != null) {
      _selectedId = SubscriptionService.kYearlyId;
    } else if (svc.monthly != null) {
      _selectedId = SubscriptionService.kMonthlyId;
    }
    svc.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    // Auto-select yearly once products load
    if (_selectedId == null) {
      final svc = SubscriptionService.instance;
      if (svc.yearly != null) {
        setState(() => _selectedId = SubscriptionService.kYearlyId);
      } else if (svc.monthly != null) {
        setState(() => _selectedId = SubscriptionService.kMonthlyId);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    SubscriptionService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = SubscriptionService.instance;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF2D1B69)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 2),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.premiumTitle,
                        style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(l10n.premiumSubtitle,
                        style: tt.bodySmall
                            ?.copyWith(color: Colors.white60)),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Feature list ────────────────────────────────────────
                  _Feature(
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.primary,
                    title: l10n.featInsightsTitle,
                    subtitle: l10n.featInsightsSub,
                  ),
                  const SizedBox(height: 16),
                  _Feature(
                    icon: Icons.block_rounded,
                    color: Colors.orangeAccent,
                    title: l10n.featAdFreeTitle,
                    subtitle: l10n.featAdFreeSub,
                  ),
                  const SizedBox(height: 16),
                  _Feature(
                    icon: Icons.favorite_rounded,
                    color: Colors.redAccent,
                    title: l10n.featSupportTitle,
                    subtitle: l10n.featSupportSub,
                  ),

                  const SizedBox(height: 28),

                  // ── Plans ────────────────────────────────────────────────
                  if (svc.loadingProducts)
                    const Center(
                        child:
                            CircularProgressIndicator(strokeWidth: 2))
                  else if (svc.products.isEmpty)
                    Center(
                      child: Text(
                        l10n.loadPricingError,
                        textAlign: TextAlign.center,
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  else ...[
                    Text(l10n.choosePlan,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    for (final plan in svc.planOptions)
                      _PlanCard(
                        plan: plan,
                        isSelected: _selectedId == plan.id,
                        isBestValue:
                            plan.id == SubscriptionService.kYearlyId,
                        onTap: () =>
                            setState(() => _selectedId = plan.id),
                      ),
                  ],

                  const SizedBox(height: 24),

                  // ── Subscribe button ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      icon: svc.purchasing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Icon(Icons.workspace_premium_rounded,
                              size: 20),
                      label: Text(
                        svc.isPremium ? l10n.alreadyPremium : l10n.subscribe,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      onPressed: svc.purchasing ||
                              svc.isPremium ||
                              _selectedId == null
                          ? null
                          : _purchase,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Restore ──────────────────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed:
                          svc.purchasing ? null : _restore,
                      child: Text(l10n.restorePurchases,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Legal ────────────────────────────────────────────────
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      children: [
                        GestureDetector(
                          onTap: () => launchUrl(
                              Uri.parse(
                                  'https://zibaentertainment.com/privacy/'),
                              mode: LaunchMode.externalApplication),
                          child: Text(l10n.privacyPolicy,
                              style: tt.bodySmall
                                  ?.copyWith(color: AppColors.textMuted)),
                        ),
                        GestureDetector(
                          onTap: () => launchUrl(
                              Uri.parse(
                                  'https://zibaentertainment.com/terms/'),
                              mode: LaunchMode.externalApplication),
                          child: Text(l10n.termsOfUse,
                              style: tt.bodySmall
                                  ?.copyWith(color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      l10n.subsRenew,
                      textAlign: TextAlign.center,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textMuted, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchase() async {
    final svc = SubscriptionService.instance;
    final plan = svc.planOptions.firstWhere((p) => p.id == _selectedId);
    await svc.purchase(plan.purchaseTarget);
  }

  Future<void> _restore() async {
    await SubscriptionService.instance.restorePurchases();
    if (!mounted) return;
    final isPremium = SubscriptionService.instance.isPremium;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          isPremium ? context.l10n.premiumRestored : context.l10n.noSubFound),
    ));
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _Feature extends StatelessWidget {
  const _Feature(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});
  final IconData icon;
  final Color color;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.isBestValue,
    required this.onTap,
  });
  final PlanOption plan;
  final bool isSelected, isBestValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isYearly = plan.id == SubscriptionService.kYearlyId;
    final borderColor =
        isSelected ? AppColors.primary : AppColors.border;
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.08)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isYearly ? l10n.planYearly : l10n.planMonthly,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.bestValue,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (plan.hasFreeTrial) ...[
                    Text(
                      l10n.freeTrial,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    isYearly ? l10n.billedYearly : l10n.billedMonthly,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Price
            Text(
              plan.price,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
