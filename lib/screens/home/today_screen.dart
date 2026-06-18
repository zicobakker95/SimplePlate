import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/food_entry.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/calorie_ring.dart';
import '../../widgets/macro_bar.dart';
import '../../widgets/meal_section.dart';
import '../log/add_food_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final goals = store.goals;
    final today = store.todayEntries;
    final cals = store.todayCalories();
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
              padding: const EdgeInsets.only(right: 8),
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
}
