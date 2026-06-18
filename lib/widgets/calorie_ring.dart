import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../theme/app_colors.dart';

/// Circular calorie progress ring with consumed/remaining text.
class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    this.radius = 90,
  });

  final double consumed;
  final double goal;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final pct = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - consumed).clamp(0, double.infinity);
    final over = consumed > goal;

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: 12,
      percent: pct,
      backgroundColor: AppColors.border,
      progressColor:
          over ? AppColors.danger : AppColors.primary,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 600,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            consumed.round().toString(),
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          const Text('kcal eaten',
              style: TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            over
                ? '${(consumed - goal).round()} over'
                : '${remaining.round()} left',
            style: TextStyle(
                fontSize: 11,
                color: over ? AppColors.danger : AppColors.textMuted,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
