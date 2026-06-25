import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../theme/app_colors.dart';

/// Circular calorie progress ring with consumed/remaining text.
/// Optional [burned] shows net calories when activity is logged.
class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    this.burned = 0,
    this.radius = 90,
  });

  final double consumed;
  final double goal;
  final double burned;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final net = consumed - burned;
    final pct = goal > 0 ? (net / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - net).clamp(0, double.infinity);
    final over = net > goal;

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: 12,
      percent: pct,
      backgroundColor: AppColors.border,
      progressColor: over ? AppColors.danger : AppColors.primary,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 600,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            net.round().toString(),
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          Text(
            burned > 0 ? 'net kcal' : 'kcal eaten',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            over
                ? '${(net - goal).round()} over'
                : '${remaining.round()} left',
            style: TextStyle(
                fontSize: 11,
                color: over ? AppColors.danger : AppColors.textMuted,
                fontWeight: FontWeight.w500),
          ),
          if (burned > 0) ...[
            const SizedBox(height: 2),
            Text(
              '−${burned.round()} burned',
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}
