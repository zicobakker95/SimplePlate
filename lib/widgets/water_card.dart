import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/food_store.dart';
import '../ui/kit.dart';

/// Daily water intake. Tap an empty glass to drink one, a full one to take
/// it back; the reset button clears the day after a confirmation.
class WaterCard extends StatelessWidget {
  const WaterCard({super.key, this.goal = 8});

  final int goal;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final l10n = context.l10n;
    final p = context.pal;
    final glasses = store.waterGlasses;

    return PtCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(Icons.water_drop_rounded, color: p.water, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.water,
                  style: PtText.headline(color: p.text).copyWith(fontSize: 16),
                ),
              ),
              Bump(
                trigger: glasses,
                child: Text(
                  l10n.waterCount(glasses, goal),
                  style: PtText.small(
                    color: glasses >= goal ? p.water : p.textMuted,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: glasses > 0 ? 1 : 0,
                duration: Pt.base,
                child: PtIconButton(
                  icon: Icons.restart_alt_rounded,
                  tooltip: l10n.reset,
                  background: Colors.transparent,
                  color: p.textMuted,
                  size: 36,
                  iconSize: 20,
                  onPressed: glasses > 0 ? () => _reset(context) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Glasses share the row evenly up to a comfortable size; long
          // goals wrap onto more rows.
          LayoutBuilder(
            builder: (context, box) {
              final slot = (box.maxWidth / goal).clamp(36.0, 44.0);
              return Wrap(
                runSpacing: 4,
                children: List.generate(goal, (i) {
                  final filled = i < glasses;
                  return _Glass(
                    width: slot,
                    filled: filled,
                    label: filled ? l10n.waterRemoveGlass : l10n.waterAddGlass,
                    onTap: () {
                      if (filled) {
                        context.read<FoodStore>().removeWater();
                      } else {
                        context.read<FoodStore>().addWater();
                      }
                    },
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _reset(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showPtConfirm(
      context,
      title: l10n.resetWaterTitle,
      body: l10n.resetWaterBody,
      confirmLabel: l10n.reset,
      cancelLabel: l10n.cancel,
      icon: Icons.water_drop_outlined,
      destructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<FoodStore>().resetWater();
    }
  }
}

class _Glass extends StatelessWidget {
  const _Glass({
    required this.filled,
    required this.onTap,
    required this.label,
    this.width = 40,
  });

  final double width;
  final bool filled;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget glass(double level) => CustomPaint(
      size: const Size(30, 38),
      painter: _GlassPainter(
        level: level,
        water: p.water,
        outline: filled ? p.water : p.border,
        empty: p.sunken,
      ),
    );
    return Pressable(
      onTap: onTap,
      haptic: true,
      pressedScale: 0.85,
      semanticLabel: label,
      child: SizedBox(
        width: width,
        height: 48,
        child: Center(
          child: context.reduceMotion
              ? glass(filled ? 1 : 0)
              : TweenAnimationBuilder<double>(
                  tween: Tween(end: filled ? 1 : 0),
                  duration: filled
                      ? const Duration(milliseconds: 650)
                      : const Duration(milliseconds: 260),
                  curve: filled ? Curves.easeOutBack : Curves.easeIn,
                  builder: (context, v, _) => glass(v),
                ),
        ),
      ),
    );
  }
}

/// A tumbler: tapered outline, water with a gentle meniscus wave.
class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.level,
    required this.water,
    required this.outline,
    required this.empty,
  });

  final double level;
  final Color water;
  final Color outline;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final taper = w * 0.12;
    final glass = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - taper, h - 4)
      ..quadraticBezierTo(w - taper, h, w - taper - 4, h)
      ..lineTo(taper + 4, h)
      ..quadraticBezierTo(taper, h, taper, h - 4)
      ..close();

    canvas.drawPath(glass, Paint()..color = empty);

    final l = level.clamp(0.0, 1.1);
    if (l > 0) {
      canvas.save();
      canvas.clipPath(glass);
      final top = h - (h - 6) * math.min(l, 1.0) - (l > 1 ? (l - 1) * 6 : 0);
      final wave = Path()
        ..moveTo(0, top)
        ..quadraticBezierTo(w * 0.25, top - 3, w * 0.5, top)
        ..quadraticBezierTo(w * 0.75, top + 3, w, top)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        wave,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [water.withValues(alpha: 0.75), water],
          ).createShader(Offset.zero & size),
      );
      // A highlight down the side.
      canvas.drawLine(
        Offset(w * 0.24, top + 5),
        Offset(w * 0.28, h - 6),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }

    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..color = outline,
    );
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.level != level || old.outline != outline || old.water != water;
}
