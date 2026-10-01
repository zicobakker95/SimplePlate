import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/weight_entry.dart';
import '../screens/premium/premium_screen.dart';
import '../services/food_store.dart';
import '../services/subscription_service.dart';
import '../ui/kit.dart';
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
      entries.add(
        WeightEntry(
          id: 'sample-$i',
          kg: 78.0 - i * 0.18 + wobble,
          loggedAt: at,
        ),
      );
    }
    return WeightTrend(
      days: days,
      entries: entries,
      movingAverageKg: movingAverage(entries),
    );
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
    final p = context.pal;
    final locale = Localizations.localeOf(context).toString();
    final latest = trend.latestKg;
    final change = trend.changeKg;

    return PtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                Icons.monitor_weight_outlined,
                color: p.primary,
                size: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.weightTrend,
                  style: PtText.headline(color: p.text).copyWith(fontSize: 16),
                ),
              ),
              if (latest != null)
                Text(
                  unit.format(latest),
                  style: PtText.number(16, color: p.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 170,
                child: PtSegmented<int>(
                  compact: true,
                  segments: [
                    for (final d in const [30, 90])
                      PtSegment(d, l10n.weightTrendDays(d)),
                  ],
                  selected: days,
                  onChanged: onDaysChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  change == null
                      ? l10n.weightTrendNoChange
                      : l10n.weightTrendChange(
                          unit.format(change, signed: true),
                          days,
                        ),
                  textAlign: TextAlign.end,
                  style: PtText.small(
                    color: change == null ? p.textMuted : p.text,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (trend.entries.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.weightTrendNeedMore,
                textAlign: TextAlign.center,
                style: PtText.small(color: p.textMuted),
              ),
            )
          else ...[
            SizedBox(
              height: 110,
              // The lines draw themselves left to right when the card
              // appears or the range changes.
              child: TweenAnimationBuilder<double>(
                key: ValueKey(days),
                tween: Tween(begin: context.reduceMotion ? 1 : 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Pt.ease,
                builder: (context, t, _) => CustomPaint(
                  painter: _TrendPainter(
                    trend: trend,
                    progress: t,
                    raw: p.primary.withValues(alpha: 0.45),
                    average: p.fresh,
                    guide: p.border,
                    fill: p.fresh.withValues(alpha: 0.14),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                    'MMM d',
                    locale,
                  ).format(trend.entries.first.loggedAt),
                  style: PtText.tiny(color: p.textMuted),
                ),
                Text(
                  DateFormat(
                    'MMM d',
                    locale,
                  ).format(trend.entries.last.loggedAt),
                  style: PtText.tiny(color: p.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _LegendSwatch(
                  color: p.primary.withValues(alpha: 0.45),
                  label: l10n.weightTrendLoggedLegend,
                ),
                _LegendSwatch(
                  color: p.fresh,
                  label: l10n.weightTrendAverageLegend,
                ),
              ],
            ),
          ],
        ],
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
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: PtText.tiny(color: context.pal.textMuted)),
      ],
    );
  }
}

/// Raw entries as a thin, muted line with dots; the 7-day average as the
/// bold line on top with a soft fill. The average is the one to read, so it
/// gets the ink. [progress] reveals the lines left to right.
class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.trend,
    required this.progress,
    required this.raw,
    required this.average,
    required this.guide,
    required this.fill,
  });

  final WeightTrend trend;
  final double progress;
  final Color raw;
  final Color average;
  final Color guide;
  final Color fill;

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
      final x =
          (entries[i].loggedAt.millisecondsSinceEpoch - firstMs) /
          span *
          size.width;
      final y = size.height - ((kg - minKg) / range * (size.height - 12) + 6);
      return Offset(x, y);
    }

    // Guide lines at the top and bottom of the range.
    final guidePaint = Paint()
      ..color = guide
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 6), Offset(size.width, 6), guidePaint);
    canvas.drawLine(
      Offset(0, size.height - 6),
      Offset(size.width, size.height - 6),
      guidePaint,
    );

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width * progress + 6, size.height),
    );

    // Soft area under the average.
    final area = Path()..moveTo(0, size.height);
    for (var i = 0; i < entries.length; i++) {
      final pt = at(i, avg[i]);
      area.lineTo(pt.dx, pt.dy);
    }
    area
      ..lineTo(at(entries.length - 1, avg.last).dx, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = fill);

    final rawPaint = Paint()
      ..color = raw
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()..color = raw;
    final rawPath = Path();
    for (var i = 0; i < entries.length; i++) {
      final pt = at(i, entries[i].kg);
      i == 0 ? rawPath.moveTo(pt.dx, pt.dy) : rawPath.lineTo(pt.dx, pt.dy);
      canvas.drawCircle(pt, 2.5, dotPaint);
    }
    canvas.drawPath(rawPath, rawPaint);

    final avgPaint = Paint()
      ..color = average
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final smooth = Path();
    for (var i = 0; i < entries.length; i++) {
      final pt = at(i, avg[i]);
      i == 0 ? smooth.moveTo(pt.dx, pt.dy) : smooth.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(smooth, avgPaint);
    canvas.restore();

    if (progress >= 1) {
      final end = at(entries.length - 1, avg.last);
      canvas.drawCircle(end, 6, Paint()..color = average);
      canvas.drawCircle(end, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.progress != progress ||
      old.average != average ||
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
    final p = context.pal;
    return Stack(
      children: [
        IgnorePointer(child: Opacity(opacity: 0.35, child: child)),
        Positioned.fill(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(Pt.rMd),
            ),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: Pt.premiumGradient(p),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF3A2606),
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.weightTrend,
                      style: PtText.headline(color: p.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.premiumFeature,
                      style: PtText.small(color: p.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.weightTrendTeaserSub,
                      textAlign: TextAlign.center,
                      style: PtText.small(color: p.text),
                    ),
                    const SizedBox(height: 12),
                    PtButton(
                      label: l10n.upgradeToPremium,
                      icon: Icons.workspace_premium_rounded,
                      tone: PtButtonTone.premium,
                      compact: true,
                      onPressed: () =>
                          PremiumScreen.show(context, source: 'weight_trend'),
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
