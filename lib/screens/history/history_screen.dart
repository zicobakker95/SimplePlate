import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/food_entry.dart';
import '../../models/nutrition_goals.dart';
import '../../screens/premium/premium_screen.dart';
import '../../services/food_store.dart';
import '../../services/subscription_service.dart';
import '../../ui/kit.dart';
import '../../widgets/edit_entry_sheet.dart';
import '../../widgets/meal_section.dart';
import '../../widgets/rewarded_unlock.dart';
import '../../widgets/weight_trend_card.dart';
import '../../services/ad_service.dart';
import '../../services/ad_config.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final l10n = context.l10n;
    final p = context.pal;
    final dates = store.loggedDates;
    final goals = store.goals;

    return Scaffold(
      // One scroll for the whole page. This used to be a fixed-height header
      // above an Expanded list, which had no room to give: adding the banner
      // took ~50px and the header started overflowing. Slivers also mean the
      // date list is still built lazily rather than all at once.
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Pt.gutter, 16, Pt.gutter, 8),
                child: Text(
                  l10n.historyTitle,
                  style: PtText.title(color: p.text),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  FadeSlideIn(
                    child: ListenableBuilder(
                      // AdService too: a rewarded day-unlock has to swap the
                      // teaser for the real card immediately, without a
                      // restart.
                      listenable: Listenable.merge([
                        SubscriptionService.instance,
                        AdService.instance,
                      ]),
                      builder: (context, _) {
                        final unlocked =
                            SubscriptionService.instance.isPremium ||
                            AdService.instance.isUnlocked(
                              AdService.insightsUnlockKey,
                            );
                        return AnimatedSwitcher(
                          duration: Pt.slow,
                          child: unlocked
                              ? _WeeklySummaryCard(
                                  key: const ValueKey('summary'),
                                  store: store,
                                  goals: goals,
                                  temporary:
                                      !SubscriptionService.instance.isPremium,
                                )
                              : const _WeeklyInsightsTeaser(
                                  key: ValueKey('teaser'),
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Weight trend: Premium, with a locked preview otherwise.
                  const FadeSlideIn(index: 1, child: WeightTrendCard()),
                  const SizedBox(height: 14),
                  // Monthly calendar heatmap
                  FadeSlideIn(
                    index: 2,
                    child: _CalendarHeatmap(store: store, goals: goals),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (dates.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: PtEmptyState(
                  mood: SproutMood.sleepy,
                  title: l10n.noLoggedDays,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: dates.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (_, i) => FadeSlideIn(
                  index: 3 + min(i, 6),
                  child: _DayCard(date: dates[i], store: store, goals: goals),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One logged day: a small ring of the day against the goal, the date, the
/// item count and the total. Opens the editable day sheet.
class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.date,
    required this.store,
    required this.goals,
  });

  final DateTime date;
  final FoodStore store;
  final NutritionGoals goals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final locale = Localizations.localeOf(context).toString();
    final entries = store.entriesForDay(date);
    final cals = entries.fold<double>(0, (s, e) => s + e.calories);
    final goal = goals.dailyCalories.toDouble();
    final pct = goal > 0 ? cals / goal : 0.0;
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final color = _adherenceColor(p, cals, goal);

    return PtCard(
      onTap: () => showDaySheet(context, date),
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      child: Row(
        children: [
          MacroRing(
            value: pct,
            color: color,
            size: 46,
            stroke: 6,
            child: Text(
              '${(pct * 100).round()}%',
              style: PtText.number(12, color: p.text),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday
                      ? l10n.today
                      : DateFormat('EEE, MMM d', locale).format(date),
                  style: PtText.tile(
                    color: p.text,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.itemsCount(entries.length),
                  style: PtText.small(color: p.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${cals.round()} kcal',
                style: PtText.number(15, color: p.text),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 84,
                child: FillBar(value: pct, color: color, height: 6),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: p.textFaint),
        ],
      ),
    );
  }
}

/// Green when the day landed in the target window, a lighter green when
/// under, tomato when over — the same rule everywhere in History.
Color _adherenceColor(PlatePalette p, double cals, double goal) {
  if (cals <= 0) return p.sunken;
  if (cals > goal * 1.1) return p.fat;
  if (cals >= goal * 0.85) return p.fresh;
  return p.fresh.withValues(alpha: 0.45);
}

/// Opens the editable day sheet for [date].
///
/// The sheet reads its entries straight from [FoodStore], so edits and
/// deletions made inside it refresh the list and the day totals immediately.
void showDaySheet(BuildContext context, DateTime date) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _DaySheet(date: date),
  );
}

class _DaySheet extends StatelessWidget {
  const _DaySheet({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final locale = Localizations.localeOf(context).toString();

    // Watching the store keeps the list and the totals below in sync after an
    // edit or a delete without the sheet having to be reopened.
    final store = context.watch<FoodStore>();
    final entries = store.entriesForDay(date);
    final goals = store.goals;

    final cals = entries.fold<double>(0, (s, e) => s + e.calories);
    final protein = entries.fold<double>(0, (s, e) => s + e.protein);
    final carbs = entries.fold<double>(0, (s, e) => s + e.carbs);
    final fat = entries.fold<double>(0, (s, e) => s + e.fat);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(Pt.gutter, 0, Pt.gutter, 32),
        children: [
          const PtGrabHandle(),
          Text(
            DateFormat('EEEE, MMMM d, y', locale).format(date),
            style: PtText.title(color: p.text),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.itemsCount(entries.length)}  ·  '
            '${cals.round()} / ${goals.dailyCalories} kcal',
            style: PtText.small(color: p.textMuted),
          ),
          const SizedBox(height: 14),
          // Day totals — recomputed on every store change.
          NutrientRow(calories: cals, protein: protein, carbs: carbs, fat: fat),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            PtEmptyState(mood: SproutMood.sleepy, title: l10n.noEntriesThatDay)
          else
            // Grouped by meal so the day reads the same way the Today tab does.
            for (final meal in MealType.values)
              ..._mealBlock(
                context,
                meal,
                entries.where((e) => e.meal == meal).toList(),
              ),
        ],
      ),
    );
  }

  List<Widget> _mealBlock(
    BuildContext context,
    MealType meal,
    List<FoodEntry> entries,
  ) {
    if (entries.isEmpty) return const [];
    final l10n = context.l10n;
    final p = context.pal;
    final store = context.read<FoodStore>();
    final mealCals = entries.fold<double>(0, (s, e) => s + e.calories);

    return [
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Row(
          children: [
            Text(meal.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                meal.localizedLabel(l10n),
                style: PtText.headline(color: p.text).copyWith(fontSize: 15),
              ),
            ),
            Text(
              '${mealCals.round()} kcal',
              style: PtText.number(13, color: p.primary),
            ),
          ],
        ),
      ),
      PtCard(
        padding: EdgeInsets.zero,
        clip: true,
        color: p.surfaceAlt,
        shadow: false,
        borderColor: p.border,
        child: Column(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) const PtDivider(indent: 0),
              // Tap as well as long-press, with swipe-to-delete: see EntryRow.
              EntryRow(
                key: ValueKey(entries[i].id),
                entry: entries[i],
                onDelete: (id) => store.deleteEntry(id),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}

/// Offers the weekly insights for [AdConfig.insightsUnlockDays] in exchange
/// for a rewarded ad. The History gate listens to AdService, so a successful
/// unlock swaps this teaser for the real card with no restart.
Future<void> _unlockInsightsWithAd(BuildContext context) async {
  await unlockWithRewardedAd(
    context,
    key: AdService.insightsUnlockKey,
    days: AdConfig.instance.insightsUnlockDays,
    placement: 'weekly_insights',
  );
}

class _WeeklyInsightsTeaser extends StatelessWidget {
  const _WeeklyInsightsTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    const heights = [0.45, 0.7, 0.35, 0.85, 0.62, 0.95, 0.5];
    // The overlay, not the sample chart, sizes the card: a longer
    // translation or a bigger text scale makes the card taller instead of
    // overflowing it.
    return PtCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final h in heights)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FractionallySizedBox(
                            heightFactor: h,
                            child: Container(
                              decoration: BoxDecoration(
                                color: p.fresh,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          _LockOverlay(
            title: l10n.weeklyInsights,
            subtitle: l10n.premiumFeature,
            source: 'weekly_insights',
            // The same day-unlock deal the barcode scanner offers. This card
            // already existed purely to advertise a feature free users cannot
            // have; letting them earn it for a day turns the advert into a
            // trial, and a trial sells the subscription better than a lock.
            secondary: AdConfig.instance.insightsRewardedEnabled
                ? PtButton(
                    label: l10n.unlockWithAdToday,
                    icon: Icons.play_circle_outline_rounded,
                    tone: PtButtonTone.ghost,
                    compact: true,
                    onPressed: () => _unlockInsightsWithAd(context),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// The shared "Premium" lock: a crown badge, a title, a line and the
/// upgrade button, over a dimmed preview of what is being sold.
class _LockOverlay extends StatelessWidget {
  const _LockOverlay({
    required this.title,
    required this.subtitle,
    required this.source,
    this.secondary,
  });

  final String title;
  final String subtitle;
  final String source;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: Pt.premiumGradient(p),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFF3A2606),
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PtText.headline(color: p.text),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: PtText.small(color: p.textMuted),
          ),
          const SizedBox(height: 14),
          PtButton(
            label: l10n.upgradeToPremium,
            icon: Icons.workspace_premium_rounded,
            tone: PtButtonTone.premium,
            compact: true,
            onPressed: () => PremiumScreen.show(context, source: source),
          ),
          if (secondary != null) ...[const SizedBox(height: 4), secondary!],
        ],
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({
    super.key,
    required this.store,
    required this.goals,
    this.temporary = false,
  });
  final FoodStore store;
  final NutritionGoals goals;

  /// True when this is showing because of a rewarded day-unlock rather than
  /// Premium. Labelled so nobody thinks they bought something they did not,
  /// and so the card still reads as a trial of a paid feature.
  final bool temporary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });
    final cals = days.map((d) => store.caloriesTotalsForDay(d)).toList();
    final avg = cals.reduce((a, b) => a + b) / 7;
    final goal = goals.dailyCalories.toDouble();
    // Scale so the goal line and the tallest bar both fit.
    final top = max(goal * 1.15, cals.reduce(max)).clamp(1.0, double.infinity);
    const chartH = 96.0;

    return PtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.sevenDayAverage,
                  style: PtText.headline(color: p.text).copyWith(fontSize: 16),
                ),
              ),
              if (temporary) ...[
                const SizedBox(width: 8),
                PtTag(label: l10n.unlockedForToday, color: p.premiumInk),
              ],
              const SizedBox(width: 8),
              AnimatedCount(
                value: avg,
                format: (v) => l10n.kcalAvg(v.round()),
                style: PtText.number(14, color: p.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: chartH + 30,
            child: Stack(
              children: [
                // Goal line.
                Positioned(
                  left: 0,
                  right: 0,
                  // Bars stand on a 24 px label row.
                  top: chartH + 6 - chartH * goal / top,
                  child: _DashedLine(color: p.textFaint),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final isToday = i == 6;
                    final h = cals[i] > 0
                        ? (chartH * cals[i] / top).clamp(6.0, chartH)
                        : 4.0;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: h),
                            duration: Duration(milliseconds: 600 + i * 70),
                            curve: Pt.spring,
                            builder: (context, v, _) => Container(
                              height: v.clamp(0.0, chartH + 4),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: _adherenceColor(p, cals[i], goal),
                                borderRadius: BorderRadius.circular(7),
                                border: isToday
                                    ? Border.all(color: p.primary, width: 2)
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                            child: Center(
                              child: Text(
                                DateFormat(
                                  'E',
                                  locale,
                                ).format(days[i]).substring(0, 1),
                                style: PtText.tiny(
                                  color: isToday ? p.primary : p.textMuted,
                                  weight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1.5),
      painter: _DashPainter(color),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (double x = 0; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(min(x + 4, size.width), 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

/// Monthly calendar grid colour-coded by calorie adherence.
class _CalendarHeatmap extends StatefulWidget {
  const _CalendarHeatmap({required this.store, required this.goals});
  final FoodStore store;
  final NutritionGoals goals;

  @override
  State<_CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<_CalendarHeatmap> {
  late DateTime _month;

  /// +1 when moving forward in time, -1 back: the grid slides that way.
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _go(int delta) => setState(() {
    _direction = delta;
    _month = DateTime(_month.year, _month.month + delta);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    final locale = Localizations.localeOf(context).toString();
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final startWeekday = _month.weekday % 7; // 0=Sun, 1=Mon…
    final goal = widget.goals.dailyCalories.toDouble();
    final now = DateTime.now();
    final canGoForward = !DateTime(_month.year, _month.month + 1).isAfter(now);

    // Pre-compute all calorie totals once — avoids 42 × O(n) scans inside
    // the grid on every rebuild.
    final calsByDay = <int, double>{};
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_month.year, _month.month, d);
      if (!date.isAfter(now)) {
        calsByDay[d] = widget.store.caloriesTotalsForDay(date);
      }
    }

    // Localised one-letter weekday headers, Sunday first like the grid.
    final sunday = DateTime(2024, 1, 7);
    final headers = [
      for (var i = 0; i < 7; i++)
        DateFormat(
          'E',
          locale,
        ).format(sunday.add(Duration(days: i))).substring(0, 1),
    ];

    final grid = GridView.builder(
      key: ValueKey(_month),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      itemCount: startWeekday + daysInMonth,
      itemBuilder: (_, idx) {
        if (idx < startWeekday) return const SizedBox.shrink();
        final day = idx - startWeekday + 1;
        final date = DateTime(_month.year, _month.month, day);
        final isFuture = date.isAfter(now);
        final cals = calsByDay[day] ?? 0.0;
        final isToday = DateUtils.isSameDay(date, now);
        final logged = cals > 0 && !isFuture;

        final Color cellColor;
        if (isFuture) {
          cellColor = Colors.transparent;
        } else if (cals == 0) {
          cellColor = p.sunken;
        } else {
          cellColor = _adherenceColor(p, cals, goal);
        }

        // Any non-future day opens its editable day sheet.
        return Pressable(
          onTap: isFuture ? null : () => showDaySheet(context, date),
          enabled: !isFuture,
          pressedScale: 0.85,
          semanticLabel: DateFormat.MMMd(locale).format(date),
          child: Container(
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(9),
              border: isToday
                  ? Border.all(color: p.primary, width: 2)
                  : isFuture
                  ? Border.all(color: p.border)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: PtText.tiny(
                // Dark ink on the solid green/tomato cells reads in both
                // themes; the pale "under" cells keep the normal text.
                color: logged
                    ? (cals >= goal * 0.85 ? const Color(0xFF1A1712) : p.text)
                    : p.textMuted,
                weight: isToday ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );

    return PtCard(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PtIconButton(
                icon: Icons.chevron_left_rounded,
                tooltip: l10n.prevMonth,
                background: Colors.transparent,
                onPressed: () => _go(-1),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Pt.base,
                  child: Text(
                    DateFormat('MMMM y', locale).format(_month),
                    key: ValueKey(_month),
                    textAlign: TextAlign.center,
                    style: PtText.headline(
                      color: p.text,
                    ).copyWith(fontSize: 16),
                  ),
                ),
              ),
              PtIconButton(
                icon: Icons.chevron_right_rounded,
                tooltip: l10n.nextMonth,
                background: Colors.transparent,
                onPressed: canGoForward ? () => _go(1) : null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    for (final d in headers)
                      Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: PtText.tiny(
                              color: p.textMuted,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: context.reduceMotion ? Duration.zero : Pt.slow,
                  switchInCurve: Pt.ease,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) {
                    final incoming = child.key == ValueKey(_month);
                    final dx = (incoming ? 0.25 : -0.25) * _direction;
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: Offset(dx, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  child: grid,
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _LegendDot(
                      p.fresh.withValues(alpha: 0.45),
                      l10n.legendUnder,
                    ),
                    _LegendDot(p.fresh, l10n.legendOnTarget),
                    _LegendDot(p.fat, l10n.legendOver),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: PtText.tiny(color: context.pal.textMuted)),
      ],
    );
  }
}
