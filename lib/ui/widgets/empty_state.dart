import 'package:flutter/material.dart';

import '../mascot/sprout.dart';
import '../theme/plate_theme.dart';

/// Sprout + a title, a line of help and an optional action. Every list in
/// the app that can be empty uses this instead of a lone grey sentence.
class PtEmptyState extends StatelessWidget {
  const PtEmptyState({
    super.key,
    required this.title,
    this.body,
    this.mood = SproutMood.sleepy,
    this.action,
    this.mascotSize = 92,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
  });

  final String title;
  final String? body;
  final SproutMood mood;
  final Widget? action;
  final double mascotSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Sprout(mood: mood, size: mascotSize),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PtText.headline(color: p.text),
          ),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: PtText.small(color: p.textMuted),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}
