import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/food_entry.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final dates = store.loggedDates;
    final goals = store.goals;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: dates.isEmpty
          ? const Center(
              child: Text('No logged days yet.',
                  style: TextStyle(color: AppColors.textMuted)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dates.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final date = dates[i];
                final entries = store.entriesForDay(date);
                final cals =
                    entries.fold<double>(0, (s, e) => s + e.calories);
                final pct =
                    (cals / goals.dailyCalories.toDouble()).clamp(0.0, 1.0);
                final isToday = _isSameDay(date, DateTime.now());

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showDaySheet(context, date, entries),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isToday
                                    ? 'Today'
                                    : DateFormat('EEE, MMM d').format(date),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${entries.length} item${entries.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${cals.round()} kcal',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.calories),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: AppColors.border,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showDaySheet(
      BuildContext context, DateTime date, List<FoodEntry> entries) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DaySheet(date: date, entries: entries),
    );
  }
}

class _DaySheet extends StatelessWidget {
  const _DaySheet({required this.date, required this.entries});
  final DateTime date;
  final List<FoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cals = entries.fold<double>(0, (s, e) => s + e.calories);
    final protein = entries.fold<double>(0, (s, e) => s + e.protein);
    final carbs = entries.fold<double>(0, (s, e) => s + e.carbs);
    final fat = entries.fold<double>(0, (s, e) => s + e.fat);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(DateFormat('EEEE, MMMM d, y').format(date),
              style:
                  tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat('Calories', '${cals.round()}', 'kcal',
                  AppColors.calories),
              _Stat('Protein', protein.toStringAsFixed(1), 'g',
                  AppColors.protein),
              _Stat('Carbs', carbs.toStringAsFixed(1), 'g',
                  AppColors.carbs),
              _Stat('Fat', fat.toStringAsFixed(1), 'g', AppColors.fat),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          for (final e in entries)
            ListTile(
              dense: true,
              title: Text(e.foodName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  '${e.meal.label} · ${e.servingGrams.round()} g',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
              trailing: Text('${e.calories.round()} kcal',
                  style: const TextStyle(
                      color: AppColors.calories, fontSize: 12)),
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.unit, this.color);
  final String label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: color, fontSize: 18)),
        Text(unit,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 10)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
