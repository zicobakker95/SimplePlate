import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/food_entry.dart';
import '../../services/food_store.dart';
import '../../ui/kit.dart';
import '../../widgets/activity_section.dart';
import '../../widgets/health_card.dart';
import '../../widgets/meal_section.dart';
import '../../widgets/share_card.dart';
import '../../widgets/water_card.dart';
import '../../widgets/weight_card.dart';
import '../log/add_food_screen.dart';

/// The day at a glance: the plate ring, macros, meals, water and the
/// secondary trackers. Also where the day's small celebrations happen.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _confetti = ConfettiController();

  /// What the last build saw, to spot transitions (null = first build, which
  /// never celebrates: opening the app is not an achievement).
  Set<String>? _knownIds;
  bool? _wasOnTarget;
  int? _lastGlasses;
  String? _day;

  /// Entries that arrived since the screen was built: they pop in.
  final Set<String> _fresh = {};

  /// Celebrations fire once per goal per day.
  static String? _calorieCelebratedOn;
  static String? _waterCelebratedOn;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  static bool onTarget(double net, int goal) =>
      goal > 0 && net >= goal * 0.85 && net <= goal * 1.1;

  /// Compares this build's numbers with the last one and queues the
  /// reactions: new rows pop, a logged food gets a toast, entering the
  /// calorie window or filling the water goal gets confetti.
  void _watch(FoodStore store, double net) {
    final now = DateTime.now();
    final day = '${now.year}-${now.month}-${now.day}';
    final ids = store.todayEntries.map((e) => e.id).toSet();
    final target = onTarget(net, store.goals.dailyCalories);
    final glasses = store.waterGlasses;

    if (_day != day) {
      // First build, or the date rolled over while the app was open.
      _day = day;
      _knownIds = ids;
      _wasOnTarget = target;
      _lastGlasses = glasses;
      _fresh.clear();
      return;
    }

    final added = ids.difference(_knownIds ?? ids);
    _knownIds = ids;
    if (added.isNotEmpty) {
      _fresh.addAll(added);
      if (added.length == 1) {
        final e = store.todayEntries.firstWhere((e) => e.id == added.first);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final l10n = context.l10n;
          showPtToast(
            context,
            l10n.foodLoggedToast(e.foodName, e.meal.localizedLabel(l10n)),
            leading: Text(e.meal.emoji, style: const TextStyle(fontSize: 20)),
          );
        });
      }
    }

    if (target && _wasOnTarget == false && _calorieCelebratedOn != day) {
      _calorieCelebratedOn = day;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _celebrate(
          (l10n) => l10n.goalReachedToast,
          const Offset(0.5, 0.18),
        ),
      );
    }
    _wasOnTarget = target;

    final goal = store.waterGoal;
    if (store.waterEnabled &&
        glasses >= goal &&
        (_lastGlasses ?? glasses) < goal &&
        _waterCelebratedOn != day) {
      _waterCelebratedOn = day;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _celebrate(
          (l10n) => l10n.waterGoalToast,
          const Offset(0.5, 0.42),
          water: true,
        ),
      );
    }
    _lastGlasses = glasses;
  }

  void _celebrate(
    String Function(AppLocalizations) message,
    Offset origin, {
    bool water = false,
  }) {
    if (!mounted) return;
    final p = context.pal;
    _confetti.burst(
      origin: origin,
      colors: water
          ? [p.water, p.waterSoft, p.protein, Colors.white]
          : foodConfettiColors(p),
    );
    showPtToast(
      context,
      message(context.l10n),
      leading: const Sprout(mood: SproutMood.celebrate, size: 30),
      tone: PtToastTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final l10n = context.l10n;
    final goals = store.goals;
    final today = store.todayEntries;
    final cals = store.todayCalories();
    final burned = store.todayBurned();
    final net = (cals - burned).clamp(0.0, double.infinity);
    _watch(store, net);

    var i = 0;
    Widget enter(Widget child) => FadeSlideIn(index: i++, child: child);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: _Header(
                    streak: store.streak,
                    onShare: () => ShareCard.show(
                      context,
                      date: DateTime.now(),
                      calories: cals,
                      goalCalories: goals.dailyCalories,
                      protein: store.todayProtein(),
                      carbs: store.todayCarbs(),
                      fat: store.todayFat(),
                      streak: store.streak,
                    ),
                    onCopy: () => _copyYesterday(context),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                sliver: SliverList.list(
                  children: [
                    enter(
                      _PlateCard(
                        consumed: cals,
                        burned: burned,
                        goal: goals.dailyCalories,
                        protein: store.todayProtein(),
                        carbs: store.todayCarbs(),
                        fat: store.todayFat(),
                        proteinGoal: goals.proteinGrams,
                        carbsGoal: goals.carbsGrams,
                        fatGoal: goals.fatGrams,
                        entryCount: today.length,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (store.waterEnabled) ...[
                      enter(WaterCard(goal: store.waterGoal)),
                      const SizedBox(height: 14),
                    ],
                    if (today.isEmpty) ...[
                      enter(
                        PtCard(
                          child: PtEmptyState(
                            mood: SproutMood.hungry,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            title: l10n.emptyTodayTitle,
                            body: l10n.emptyTodayBody,
                            action: PtButton(
                              label: l10n.logFood,
                              icon: Icons.add_rounded,
                              haptic: true,
                              onPressed: () =>
                                  _addFood(context, MealType.snack),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    for (final meal in MealType.values)
                      enter(
                        MealSection(
                          meal: meal,
                          entries: today.where((e) => e.meal == meal).toList(),
                          fresh: _fresh,
                          onAdd: () => _addFood(context, meal),
                          onDelete: (id) => store.deleteEntry(id),
                        ),
                      ),
                    PtSectionHeader(_moreLabel(l10n)),
                    enter(const WeightCard()),
                    const SizedBox(height: 14),
                    enter(const ActivitySection()),
                    const SizedBox(height: 14),
                    enter(const HealthSyncCard()),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(child: ConfettiLayer(controller: _confetti)),
        ],
      ),
      floatingActionButton: _HiddenWhileTyping(
        child: PtButton(
          label: l10n.logFood,
          icon: Icons.add_rounded,
          haptic: true,
          onPressed: () => _addFood(context, MealType.snack),
        ),
      ),
    );
  }

  /// Heading above the secondary trackers, built from existing strings so
  /// no locale is left with an English heading.
  String _moreLabel(AppLocalizations l10n) =>
      '${l10n.bodyWeight} · ${l10n.activity}';

  void _addFood(BuildContext context, MealType meal) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddFoodScreen(defaultMeal: meal)));
  }

  Future<void> _copyYesterday(BuildContext context) async {
    final store = context.read<FoodStore>();
    final l10n = context.l10n;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final count = store.entriesForDay(yesterday).length;
    if (count == 0) {
      showPtToast(
        context,
        l10n.copyYesterdayNone,
        icon: Icons.info_outline_rounded,
      );
      return;
    }
    final confirmed = await showPtConfirm(
      context,
      title: l10n.copyYesterdayTitle,
      body: l10n.copyYesterdayBody(count),
      confirmLabel: l10n.copyAction,
      cancelLabel: l10n.cancel,
      icon: Icons.copy_all_rounded,
    );
    if (confirmed != true || !context.mounted) return;
    final added = await store.copyYesterdayEntries();
    if (!context.mounted) return;
    showPtToast(
      context,
      l10n.copiedSnack(added),
      icon: Icons.check_circle_rounded,
      tone: PtToastTone.success,
    );
  }
}

/// Greeting, the app name, the date, the streak and the two day actions.
class _Header extends StatelessWidget {
  const _Header({
    required this.streak,
    required this.onShare,
    required this.onCopy,
  });

  final int streak;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l10n = context.l10n;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final greeting = now.hour < 12
        ? l10n.greetingMorning
        : now.hour < 18
        ? l10n.greetingAfternoon
        : l10n.greetingEvening;
    final date = DateFormat('EEEE, MMM d', locale).format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Pt.gutter, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting · $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PtText.small(color: p.textMuted),
                ),
                const SizedBox(height: 2),
                Text('PlateSimple', style: PtText.title(color: p.text)),
              ],
            ),
          ),
          if (streak > 0) ...[
            Bump(
              trigger: streak,
              child: Semantics(
                label: l10n.dayStreak(streak),
                excludeSemantics: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: p.honeySoft,
                    borderRadius: BorderRadius.circular(Pt.rPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: p.honey,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: PtText.number(15, color: p.honeyInk),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          PtIconButton(
            icon: Icons.ios_share_rounded,
            tooltip: l10n.todayShareTooltip,
            onPressed: onShare,
            size: 40,
            iconSize: 20,
          ),
          PtIconButton(
            icon: Icons.copy_all_rounded,
            tooltip: l10n.todayCopyTooltip,
            onPressed: onCopy,
            size: 40,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

/// The hero card: the plate ring with the day's calories, then the three
/// macro rings. Sprout sits on the rim and reacts to the day.
class _PlateCard extends StatelessWidget {
  const _PlateCard({
    required this.consumed,
    required this.burned,
    required this.goal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.entryCount,
  });

  final double consumed, burned, protein, carbs, fat;
  final int goal, proteinGoal, carbsGoal, fatGoal, entryCount;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l10n = context.l10n;
    // Clamp net to zero so a big burn day never shows a negative count.
    final net = (consumed - burned).clamp(0.0, double.infinity);
    final pct = goal > 0 ? net / goal : 0.0;
    final remaining = (goal - net).clamp(0, double.infinity);
    final over = net > goal;
    final onTarget = _TodayScreenState.onTarget(net, goal);
    final width = MediaQuery.sizeOf(context).width;
    final ringSize = (width * 0.56).clamp(180.0, 240.0);

    final mood = entryCount == 0
        ? SproutMood.sleepy
        : onTarget
        ? SproutMood.celebrate
        : SproutMood.happy;

    return PtCard(
      radius: Pt.rLg,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Semantics(
                label:
                    '${net.round()} ${burned > 0 ? l10n.netKcal : l10n.kcalEaten}, '
                    '${over ? l10n.kcalOver((net - goal).round()) : l10n.kcalLeft(remaining.round())}',
                excludeSemantics: true,
                child: PlateRing(
                  value: pct,
                  over: over,
                  size: ringSize,
                  stroke: ringSize * 0.075,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedCount(
                        value: net,
                        style: PtText.number(ringSize * 0.19, color: p.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        burned > 0 ? l10n.netKcal : l10n.kcalEaten,
                        style: PtText.tiny(color: p.textMuted),
                      ),
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: Pt.base,
                        child: Container(
                          key: ValueKey(over),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: over ? p.dangerSoft : p.freshSoft,
                            borderRadius: BorderRadius.circular(Pt.rPill),
                          ),
                          child: Text(
                            over
                                ? l10n.kcalOver((net - goal).round())
                                : l10n.kcalLeft(remaining.round()),
                            style: PtText.tiny(
                              color: over ? p.dangerInk : p.primary,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (burned > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.kcalBurnedLine(burned.round()),
                          style: PtText.tiny(color: p.carbsInk),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Asleep in the empty state below instead.
              if (entryCount > 0)
                Positioned(
                  right: -4,
                  top: -6,
                  child: Sprout(mood: mood, size: 52, pulse: entryCount),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MacroBowl(
                  label: l10n.macroProtein,
                  value: protein,
                  goal: proteinGoal,
                  color: p.protein,
                  ink: p.proteinInk,
                ),
              ),
              Expanded(
                child: _MacroBowl(
                  label: l10n.macroCarbs,
                  value: carbs,
                  goal: carbsGoal,
                  color: p.carbs,
                  ink: p.carbsInk,
                ),
              ),
              Expanded(
                child: _MacroBowl(
                  label: l10n.macroFat,
                  value: fat,
                  goal: fatGoal,
                  color: p.fat,
                  ink: p.fatInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroBowl extends StatelessWidget {
  const _MacroBowl({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
    required this.ink,
  });

  final String label;
  final double value;
  final int goal;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Semantics(
      label: '$label ${value.round()} / ${goal}g',
      excludeSemantics: true,
      child: Column(
        children: [
          MacroRing(
            value: goal > 0 ? value / goal : 0,
            color: color,
            size: 62,
            stroke: 7,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedCount(
                  value: value,
                  format: (v) => '${v.round()}g',
                  style: PtText.number(14, color: p.text),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PtText.small(color: ink, weight: FontWeight.w700),
          ),
          Text('/ ${goal}g', style: PtText.tiny(color: p.textMuted)),
        ],
      ),
    );
  }
}

/// Hides the "Log food" button while the keyboard is up. It floats just above
/// the keyboard -- right where the weight card's Save and Cancel end up -- and
/// a field being typed into never needs it.
///
/// Listens to window metrics itself: this screen sits inside the shell's
/// Scaffold, whose MediaQuery no longer carries the keyboard inset, so
/// nothing else would rebuild the button when the keyboard opens.
class _HiddenWhileTyping extends StatefulWidget {
  const _HiddenWhileTyping({required this.child});
  final Widget child;

  @override
  State<_HiddenWhileTyping> createState() => _HiddenWhileTypingState();
}

class _HiddenWhileTypingState extends State<_HiddenWhileTyping>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final typing = View.of(context).viewInsets.bottom > 0;
    return AnimatedScale(
      scale: typing ? 0 : 1,
      duration: Pt.base,
      curve: typing ? Curves.easeIn : Pt.spring,
      child: typing ? const SizedBox.shrink() : widget.child,
    );
  }
}
