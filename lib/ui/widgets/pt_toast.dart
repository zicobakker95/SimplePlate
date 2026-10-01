import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';

enum PtToastTone { neutral, success, warning }

/// Floating toast with an icon, built on SnackBar so it stacks, times out and
/// is announced like any other snackbar.
void showPtToast(
  BuildContext context,
  String message, {
  IconData? icon,
  PtToastTone tone = PtToastTone.neutral,
  Widget? leading,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final p = context.pal;
  final accent = switch (tone) {
    PtToastTone.success => p.isDark ? p.fresh : const Color(0xFF7FE0A6),
    PtToastTone.warning => p.honey,
    PtToastTone.neutral => p.isDark ? p.textMuted : p.bgDeep,
  };
  final fg = p.isDark ? p.text : p.surface;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        content: Row(
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: 10),
            ] else if (icon != null) ...[
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: PtText.body(color: fg, weight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
}
