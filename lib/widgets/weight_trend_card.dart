import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/weight_entry.dart';
import '../screens/premium/premium_screen.dart';
import '../services/food_store.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';
import '../utils/weight_math.dart';

/// Where the weight is heading: a 30- or 90-day chart of the log with a
/// 7-day moving average and the change over the period. Premium — a free
/// user sees the chart dimmed under a lock that opens the paywall. Logging
/// weight is free either way; only reading the trend off it is paid.
class WeightTrendCard extends StatefulWidget {
  const WeightTrendCard({super.key});

  @override
  State<WeightTrendCard> createState() => _WeightTrendCardState();
}

class _WeightTrendCardState extends State<WeightTrendCard> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    return ListenableBuilder(
      listenable: SubscriptionService.instance,
      builder: (context, _) {
        final premium = SubscriptionService.instance.isPremium;
        final trend = store.weightTrendFor(_days);
        if (premium) {
          return _TrendBody(
            trend: trend,
            unit: store.weightUnit,
            days: _days,
            onDaysChanged: (d) => setState(() => _days = d),
          );
        }
        return _LockedPreview(
          child: _TrendBody(
            // Real data when there is enough to draw; otherwise a sample,
            // so the preview always shows what is being sold.
            trend: trend.entries.length >= 2 ? trend : _sampleTrend(_days),
            unit: store.weightUnit,
            days: _days,
            onDaysChanged: null,
          ),
        );
      },
    );
  }

  static WeightTrend _sampleTrend(int days) {
    final now = DateTime.now();
    final entries = <WeightEntry>[];
    for (var i = 0; i < 12; i++) {
      final at = now.subtract(Duration(days: (11 - i) * (days ~/ 12)));
      final wobble = (i.isEven ? 0.4 : -0.3) + (i % 3 == 0 ? 0.2 : 0);
      entries.add(WeightEntry(
          id: 'sample-$i', kg: 78.0 - i * 0.18 + wobble, loggedAt: at));
    }
    return WeightTrend(
        days: days, entries: entries, movingAverageKg: movingAverage(entries));
  }
}

class _TrendBody extends StatelessWidget {
  const _TrendBody({
    required this.trend,
    required this.unit,
    required this.days,
    required this.onDaysChanged,
  });

  final WeightTrend trend;
  final WeightUnit unit;
  final int days;
  final ValueChanged<int>? onDaysChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final latest = trend.latestKg;
    final change = trend.changeKg;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.weightTrend,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (latest != null)
                  Text(
                    unit.format(latest),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SegmentedButton<int>(
                  segments: [
                    for (final d in const [30, 90])
                      ButtonSegment(value: d, label: Text(l10n.weightTrendDays(d))),
                  ],
                  selected: {days},
                  onSelectionChanged: onDaysChanged == null
                      ? null
                      : (s) => onDaysChanged!(s.first),
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: WidgetStatePropertyAll(
                        const TextStyle(fontSize: 12)),
                    padding: WidgetStatePropertyAll(
                        const EdgeInsets.symmetric(horizontal: 10)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    change == null
                        ? l10n.weightTrendNoChange
                        : l10n.weightTrendChange(
                            unit.format(change, signed: true), days),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: change == null
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (trend.entries.length < 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  l10n.weightTrendNeedMore,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                ),
              )
            else ...[
              SizedBox(
                height: 90,
                child: CustomPaint(
                  painter: _TrendPainter(trend: trend),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d', locale)
                        .format(trend.entries.first.loggedAt),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10),
                  ),
                  Text(
                    DateFormat('MMM d', locale)
                        .format(trend.entries.last.loggedAt),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _LegendSwatch(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      label: l10n.weightTrendLoggedLegend),
                  const SizedBox(width: 14),
                  _LegendSwatch(
                      color: AppColors.accentSoft,
                      label: l10n.weightTrendAverageLegend),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

/// Raw entries as a thin, muted line with dots; the 7-day average as the
/// bold line on top. The average is the one to read, so it gets the ink.
class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.trend});
  final WeightTrend trend;

  @override
  void paint(Canvas canvas, Size size) {
    final entries = trend.entries;
    if (entries.length < 2) return;
    final avg = trend.movingAverageKg;

    final all = [...entries.map((e) => e.kg), ...avg];
    final minKg = all.reduce(min);
    final maxKg = all.reduce(max);
    final range = (maxKg - minKg).clamp(1.0, double.infinity);
    final firstMs = entries.first.loggedAt.millisecondsSinceEpoch;
    final lastMs = entries.last.loggedAt.millisecondsSinceEpoch;
    final span = max(1, lastMs - firstMs);

    Offset at(int i, double kg) {
      final x = (entries[i].loggedAt.millisecondsSinceEpoch - firstMs) /
          span *
          size.width;
      final y = size.height -
          ((kg - minKg) / range * (size.height - 8) + 4);
      return Offset(x, y);
    }

    // Guide lines at the top and bottom of the range.
    final guide = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, 4), Offset(size.width, 4), guide);
    canvas.drawLine(Offset(0, size.height - 4),
        Offset(size.width, size.height - 4), guide);

    final rawPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.7);
    final raw = Path();
    for (var i = 0; i < entries.length; i++) {
      final p = at(i, entries[i].kg);
      i == 0 ? raw.moveTo(p.dx, p.dy) : raw.lineTo(p.dx, p.dy);
      canvas.drawCircle(p, 2, dotPaint);
    }
    canvas.drawPath(raw, rawPaint);

    final avgPaint = Paint()
      ..color = AppColors.accentSoft
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final smooth = Path();
    for (var i = 0; i < entries.length; i++) {
      final p = at(i, avg[i]);
      i == 0 ? smooth.moveTo(p.dx, p.dy) : smooth.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(smooth, avgPaint);
    canvas.drawCircle(at(entries.length - 1, avg.last), 4,
        Paint()..color = AppColors.accentSoft);
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.trend.days != trend.days ||
      old.trend.entries.length != trend.entries.length ||
      (old.trend.entries.isNotEmpty &&
          trend.entries.isNotEmpty &&
          (old.trend.entries.last.id != trend.entries.last.id ||
              old.trend.entries.first.id != trend.entries.first.id));
}

/// The chart, dimmed, under a lock that opens Premium. Same shape as the
/// weekly-insights teaser so the two paid cards read as one family.
///
/// The chart sizes the card and the overlay fills it. The overlay's own
/// content is shorter than the chart at normal text sizes; at extreme
/// scales it is allowed to clip rather than throw.
class _LockedPreview extends StatelessWidget {
  const _LockedPreview({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      children: [
        IgnorePointer(child: Opacity(opacity: 0.4, child: child)),
        Positioned.fill(
          // The Card's own margin, so the veil sits inside the card edge.
          child: Container(
            margin: Theme.of(context).cardTheme.margin ??
                const EdgeInsets.all(4),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(l10n.weightTrend,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(l10n.premiumFeature,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      l10n.weightTrendTeaserSub,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      icon: const Icon(Icons.workspace_premium_rounded,
                          size: 16),
                      label: Text(l10n.upgradeToPremium),
                      onPressed: () => PremiumScreen.show(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
