import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';

/// The hero of Today: a plate (white disc with a rim, like the app icon)
/// inside a thick ring that fills as calories are logged. The fill sweeps
/// to its new value, so logging a meal visibly "plates up".
class PlateRing extends StatelessWidget {
  const PlateRing({
    super.key,
    required this.value,
    required this.size,
    this.over = false,
    this.stroke = 16,
    this.child,
  });

  /// 0..1 of the goal.
  final double value;
  final double size;
  final bool over;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final v = value.clamp(0.0, 1.0);
    Widget paint(double t) => CustomPaint(
      painter: _PlatePainter(
        value: t,
        stroke: stroke,
        track: p.sunken,
        colors: over ? [p.fat, p.danger] : [p.fresh, p.primary],
        plate: p.plate,
        rim: p.plateRim,
        shadow: p.isDark ? Colors.black54 : p.shadow,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
    if (context.reduceMotion) return paint(v);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: v),
      duration: Pt.fill,
      curve: Pt.ease,
      builder: (context, t, _) => paint(t),
    );
  }
}

class _PlatePainter extends CustomPainter {
  _PlatePainter({
    required this.value,
    required this.stroke,
    required this.track,
    required this.colors,
    required this.plate,
    required this.rim,
    required this.shadow,
  });

  final double value;
  final double stroke;
  final Color track;
  final List<Color> colors;
  final Color plate;
  final Color rim;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - stroke / 2;
    final ring = Rect.fromCircle(center: c, radius: r);

    // Track.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    // Plate: soft shadow, white disc, inner rim line.
    final plateR = r - stroke / 2 - 10;
    canvas.drawCircle(
      c.translate(0, 4),
      plateR,
      Paint()
        ..color = shadow.withValues(alpha: shadow.a * 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(c, plateR, Paint()..color = plate);
    canvas.drawCircle(
      c,
      plateR * 0.78,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = rim,
    );

    if (value <= 0) return;
    final sweep = math.pi * 2 * value;
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: colors,
      // Starts a little before 12 o'clock so the round start cap is
      // the light colour, not the end colour wrapping around.
      transform: const GradientRotation(-math.pi / 2 - 0.25),
    ).createShader(ring);
    canvas.drawArc(
      ring,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );

    // A glint at the leading tip, so the fill reads as moving food, not ink.
    final tip =
        c +
        Offset(math.cos(-math.pi / 2 + sweep), math.sin(-math.pi / 2 + sweep)) *
            r;
    canvas.drawCircle(
      tip,
      stroke * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_PlatePainter old) =>
      old.value != value ||
      old.colors.first != colors.first ||
      old.track != track ||
      old.plate != plate;
}

/// Circular progress with a rounded cap that sweeps to [value]. Used for
/// the macro "bowls" under the plate and wherever a small ring is needed.
class MacroRing extends StatelessWidget {
  const MacroRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 64,
    this.stroke = 7,
    this.track,
    this.child,
  });

  final double value;
  final Color color;
  final double size;
  final double stroke;
  final Color? track;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget paint(double t) => SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(t, stroke, color, track ?? p.sunken),
        child: Center(child: child),
      ),
    );
    final v = value.clamp(0.0, 1.0);
    if (context.reduceMotion) return paint(v);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: v),
      duration: Pt.fill,
      curve: Pt.ease,
      builder: (context, t, _) => paint(t),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.color, this.track);
  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(
        r,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Horizontal rounded bar that fills to [value].
class FillBar extends StatelessWidget {
  const FillBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
    this.track,
  });

  final double value;
  final Color color;
  final double height;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget bar(double t) => Container(
      height: height,
      decoration: BoxDecoration(
        color: track ?? p.sunken,
        borderRadius: BorderRadius.circular(height),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: t.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height),
          ),
        ),
      ),
    );
    final v = value.clamp(0.0, 1.0);
    if (context.reduceMotion) return bar(v);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: v),
      duration: Pt.fill,
      curve: Pt.ease,
      builder: (context, t, _) => bar(t),
    );
  }
}

/// A tiny donut of where a food's calories come from (protein / carbs /
/// fat), used as the leading badge on food rows. Reads at a glance: a
/// mostly-blue ring is a protein food, mostly-orange a carb food.
class MacroSplitRing extends StatelessWidget {
  const MacroSplitRing({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.size = 40,
    this.child,
  });

  final double protein, carbs, fat;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SplitPainter(
          [protein * 4, carbs * 4, fat * 9],
          [p.protein, p.carbs, p.fat],
          p.sunken,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _SplitPainter extends CustomPainter {
  _SplitPainter(this.values, this.colors, this.track);
  final List<double> values;
  final List<Color> colors;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.16;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
      return;
    }
    var start = -math.pi / 2;
    const gap = 0.12;
    final shown = values.where((v) => v > 0).length;
    for (var i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweep = math.pi * 2 * values[i] / total;
      final g = shown > 1 ? gap : 0.0;
      canvas.drawArc(
        rect,
        start + g / 2,
        math.max(0.01, sweep - g),
        false,
        paint..color = colors[i],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_SplitPainter old) =>
      old.track != track ||
      old.values.length != values.length ||
      Iterable.generate(values.length).any((i) => old.values[i] != values[i]);
}
