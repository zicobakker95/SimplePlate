import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/food_store.dart';
import '../theme/app_colors.dart';

/// Daily water intake tracker. Tap a droplet to log a glass; long-press to reset.
class WaterCard extends StatelessWidget {
  const WaterCard({super.key, this.goal = 8});

  final int goal;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final glasses = store.waterGlasses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_rounded,
                    color: Colors.lightBlue, size: 18),
                const SizedBox(width: 6),
                const Text('Water',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Text(
                  '$glasses / $goal glasses',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onLongPress: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset water?'),
                        content: const Text(
                            'Set today\'s water count back to 0?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.danger),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      context.read<FoodStore>().resetWater();
                    }
                  },
                  child: const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(goal, (i) {
                final filled = i < glasses;
                return GestureDetector(
                  onTap: () {
                    if (i < glasses) {
                      context.read<FoodStore>().removeWater();
                    } else {
                      context.read<FoodStore>().addWater();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: filled
                          ? Colors.lightBlue
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: filled
                            ? Colors.lightBlue
                            : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      Icons.water_drop_rounded,
                      size: 16,
                      color: filled ? Colors.white : AppColors.border,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
