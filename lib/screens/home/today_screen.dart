import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/food_entry.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/activity_section.dart';
import '../../widgets/calorie_ring.dart';
import '../../widgets/macro_bar.dart';
import '../../widgets/meal_section.dart';
import '../../widgets/water_card.dart';
import '../../widgets/weight_card.dart';
import '../log/add_food_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final goals = store.goals;
    final today = store.todayEntries;
    final cals = store.todayCalories();
    final burned = store.todayBurned();
    final protein = store.todayProtein();
    final carbs = store.todayCarbs();
    final fat = store.todayFat();

    final dateLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlateSimple',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            Text(dateLabel,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          if (store.streak > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                avatar: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.orange, size: 16),
                label: Text('${store.streak}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                backgroundColor: AppColors.surfaceAlt,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.copy_all_rounded, size: 20),
            tooltip: 'Copy yesterday\'s meals',
            onPressed: () => _copyYesterday(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Calorie ring card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CalorieRing(
                    consumed: cals,
                    goal: goals.dailyCalories.toDouble(),
                    burned: burned,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: MacroBar(
                        label: 'Protein',
                        current: protein,
                        goal: goals.proteinGrams.toDouble(),
                        color: AppColors.protein,
                        unit: 'g',
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: MacroBar(
                        label: 'Carbs',
                        current: carbs,
                        goal: goals.carbsGrams.toDouble(),
                        color: AppColors.carbs,
                        unit: 'g',
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: MacroBar(
                        label: 'Fat',
                        current: fat,
                        goal: goals.fatGrams.toDouble(),
                        color: AppColors.fat,
                        unit: 'g',
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Water tracker (only if enabled in Goals)
          if (store.waterEnabled) ...[
            WaterCard(goal: store.waterGoal),
            const SizedBox(height: 4),
          ],

          // Weight card
          const WeightCard(),
          const SizedBox(height: 4),

          // Activity section
          const ActivitySection(),
          const SizedBox(height: 4),

          if (today.isEmpty) _EmptyTodayState(onLogFood: () => _addFood(context, MealType.snack)),

          // Meal sections
          for (final meal in MealType.values)
            MealSection(
              meal: meal,
              entries: today.where((e) => e.meal == meal).toList(),
              onAdd: () => _addFood(context, meal),
              onDelete: (id) => store.deleteEntry(id),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFood(context, MealType.snack),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log food'),
      ),
    );
  }

  void _addFood(BuildContext context, MealType meal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddFoodScreen(defaultMeal: meal)),
    );
  }

  Future<void> _copyYesterday(BuildContext context) async {
    final store = context.read<FoodStore>();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final count = store.entriesForDay(yesterday).length;
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No entries logged yesterday.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy yesterday?'),
        content: Text('Copy $count item${count == 1 ? '' : 's'} from yesterday to today?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Copy'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final added = await store.copyYesterdayEntries();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $added item${added == 1 ? '' : 's'} from yesterday.')),
    );
  }
}

/// Shown on [TodayScreen] when no food has been logged yet today, so the
/// page doesn't look broken with everything sitting at zero.
class _EmptyTodayState extends StatelessWidget {
  const _EmptyTodayState({required this.onLogFood});
  final VoidCallback onLogFood;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            const Text(
              'Nothing logged yet today',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Log your first meal to start tracking calories and macros.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onLogFood,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Log food'),
            ),
          ],
        ),
      ),
    );
  }
}
