import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n.dart';
import '../../services/subscription_service.dart';
import '../../services/analytics_service.dart';
import '../../ui/kit.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  /// Opens the paywall as a full-screen modal route. [source] names the
  /// thing the user tapped, so the funnel can be read per placement rather
  /// than as one number.
  static Future<void> show(BuildContext context, {String source = 'other'}) {
    AnalyticsService.instance.logPaywallView(source);
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const PremiumScreen(),
      ),
    );
  }

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
    final l10n = context.l10n;
    final p = context.pal;

    final features = [
      (
        Icons.bar_chart_rounded,
        p.fresh,
        l10n.featInsightsTitle,
        l10n.featInsightsSub,
      ),
      (
        Icons.monitor_weight_outlined,
        p.protein,
        l10n.featWeightTrendTitle,
        l10n.featWeightTrendSub,
      ),
      (
        Icons.favorite_rounded,
        p.fat,
        l10n.featHealthSyncTitle,
        l10n.featHealthSyncSub,
      ),
      (Icons.block_rounded, p.carbs, l10n.featAdFreeTitle, l10n.featAdFreeSub),
      (
        Icons.volunteer_activism_rounded,
        p.premium,
        l10n.featSupportTitle,
        l10n.featSupportSub,
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.premiumSoft, p.bg],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: PtIconButton(
                          icon: Icons.close_rounded,
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          background: Colors.transparent,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        PopIn(
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: p.plate,
                              shape: BoxShape.circle,
                              border: Border.all(color: p.premium, width: 5),
                              boxShadow: Pt.shadow(p),
                            ),
                          ),
                        ),
                        const Sprout(mood: SproutMood.celebrate, size: 78),
                        Positioned(
                          top: -10,
                          right: -6,
                          child: PopIn(
                            delay: const Duration(milliseconds: 250),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: Pt.premiumGradient(p),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFF3A2606),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        l10n.premiumTitle,
                        textAlign: TextAlign.center,
                        style: PtText.title(color: p.text),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        l10n.premiumSubtitle,
                        textAlign: TextAlign.center,
                        style: PtText.small(color: p.textMuted),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Pt.gutter, 8, Pt.gutter, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Feature list ──────────────────────────────────────
                  PtCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        for (var i = 0; i < features.length; i++)
                          FadeSlideIn(
                            index: i,
                            child: PtTile(
                              leading: IconBadge(
                                features[i].$1,
                                color: features[i].$2,
                                size: 40,
                              ),
                              title: features[i].$3,
                              titleStyle: PtText.tile(
                                color: p.text,
                              ).copyWith(fontWeight: FontWeight.w700),
                              subtitle: features[i].$4,
                              subtitleMaxLines: 4,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Plans ─────────────────────────────────────────────
                  if (svc.loadingProducts)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  else if (svc.products.isEmpty)
                    Text(
                      l10n.loadPricingError,
                      textAlign: TextAlign.center,
                      style: PtText.small(color: p.textMuted),
                    )
                  else ...[
                    Text(
                      l10n.choosePlan.toUpperCase(),
                      style: PtText.label(color: p.textMuted),
                    ),
                    const SizedBox(height: 10),
                    for (final plan in svc.planOptions)
                      _PlanCard(
                        plan: plan,
                        isSelected: _selectedId == plan.id,
                        isBestValue: plan.id == SubscriptionService.kYearlyId,
                        onTap: () => setState(() => _selectedId = plan.id),
                      ),
                  ],

                  const SizedBox(height: 18),

                  // ── Subscribe button ──────────────────────────────────
                  PtButton(
                    label: svc.isPremium ? l10n.alreadyPremium : l10n.subscribe,
                    icon: svc.isPremium
                        ? Icons.verified_rounded
                        : Icons.workspace_premium_rounded,
                    tone: PtButtonTone.premium,
                    expand: true,
                    haptic: true,
                    loading: svc.purchasing,
                    onPressed:
                        svc.purchasing || svc.isPremium || _selectedId == null
                        ? null
                        : _purchase,
                  ),
                  const SizedBox(height: 6),

                  // ── Restore ───────────────────────────────────────────
                  Center(
                    child: PtButton(
                      label: l10n.restorePurchases,
                      tone: PtButtonTone.ghost,
                      compact: true,
                      color: p.textMuted,
                      onPressed: svc.purchasing ? null : _restore,
                    ),
                  ),

                  // ── Legal ─────────────────────────────────────────────
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: [
                      _LegalLink(
                        label: l10n.privacyPolicy,
                        url:
                            'https://zibaentertainment.com/privacy-policy-platesimple.html',
                      ),
                      _LegalLink(
                        label: l10n.termsOfUse,
                        url:
                            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.subsRenew,
                    textAlign: TextAlign.center,
                    style: PtText.tiny(
                      color: p.textMuted,
                    ).copyWith(height: 1.5),
                  ),
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
    final price = svc.priceOf(plan.id);
    await AnalyticsService.instance.logBeginCheckout(
      productId: plan.id,
      value: price?.value ?? 0,
      currency: price?.currency ?? 'EUR',
    );
    await svc.purchase(plan.purchaseTarget);
  }

  Future<void> _restore() async {
    await SubscriptionService.instance.restorePurchases();
    if (!mounted) return;
    final isPremium = SubscriptionService.instance.isPremium;
    showPtToast(
      context,
      isPremium ? context.l10n.premiumRestored : context.l10n.noSubFound,
      icon: isPremium ? Icons.verified_rounded : Icons.info_outline_rounded,
      tone: isPremium ? PtToastTone.success : PtToastTone.neutral,
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.url});
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Semantics(
      link: true,
      child: Pressable(
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              label,
              style: PtText.small(color: p.textMuted).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: p.textFaint,
              ),
            ),
          ),
        ),
      ),
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
    final p = context.pal;
    final isYearly = plan.id == SubscriptionService.kYearlyId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.97,
        haptic: true,
        child: Semantics(
          selected: isSelected,
          child: AnimatedContainer(
            duration: Pt.base,
            curve: Pt.ease,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? p.premiumSoft : p.surface,
              borderRadius: BorderRadius.circular(Pt.rMd),
              border: Border.all(
                color: isSelected ? p.premium : p.border,
                width: isSelected ? 2.5 : 1.2,
              ),
              boxShadow: isSelected ? Pt.shadow(p, 0.7) : null,
            ),
            child: Row(
              children: [
                // Radio
                AnimatedContainer(
                  duration: Pt.base,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? p.premium : p.border,
                      width: 2,
                    ),
                    color: isSelected ? p.premium : Colors.transparent,
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1 : 0,
                    duration: Pt.slow,
                    curve: Pt.spring,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: Color(0xFF3A2606),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            isYearly ? l10n.planYearly : l10n.planMonthly,
                            style: PtText.headline(
                              color: p.text,
                            ).copyWith(fontSize: 16),
                          ),
                          if (isBestValue)
                            PtTag(
                              label: l10n.bestValue,
                              color: p.primary,
                              filled: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (plan.hasFreeTrial) ...[
                        Text(
                          l10n.freeTrial,
                          style: PtText.small(
                            color: p.primary,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        isYearly ? l10n.billedYearly : l10n.billedMonthly,
                        style: PtText.small(color: p.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(plan.price, style: PtText.number(18, color: p.text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
