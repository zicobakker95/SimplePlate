import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';

/// Sprout, PlateSimple's mascot: a round pea with two leaves.
enum SproutMood {
  /// Calm, blinks now and then.
  idle,

  /// Something was logged: a bounce and ^ ^ eyes.
  happy,

  /// A goal was reached: a jump, star eyes, wiggling leaves.
  celebrate,

  /// Nothing here yet: eyes closed, zzz.
  sleepy,

  /// Empty plate / no results: round eyes and an "o" mouth.
  hungry,

  /// Searching or loading: eyes up and to the side.
  thinking,
}

/// Drawn in code so it is crisp at any size and follows dark mode.
///
/// It never runs an endless animation: it is static between a blink every
/// few seconds and a one-shot reaction when [mood] or [pulse] changes, so a
/// screen with Sprout on it is idle when the user is.
class Sprout extends StatefulWidget {
  const Sprout({
    super.key,
    this.mood = SproutMood.idle,
    this.size = 96,
    this.pulse = 0,
  });

  final SproutMood mood;

  /// Width in logical pixels (height is 1.1x).
  final double size;

  /// Change to replay the mood's reaction without changing the mood.
  final int pulse;

  /// Screenshots/tests: no blink timer, reactions rendered at rest.
  static bool debugStill = false;

  @override
  State<Sprout> createState() => _SproutState();
}

class _SproutState extends State<Sprout> with TickerProviderStateMixin {
  late final AnimationController _blink;
  late final AnimationController _react;
  Timer? _blinkTimer;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _react = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (!Sprout.debugStill) {
      _scheduleBlink();
      if (widget.mood == SproutMood.celebrate ||
          widget.mood == SproutMood.happy) {
        _react.forward(from: 0);
      }
    }
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: 2600 + _rng.nextInt(2600)), () {
      if (!mounted) return;
      if (!context.reduceMotion) {
        _blink.forward(from: 0).then((_) {
          if (mounted) _blink.reverse();
        });
      }
      _scheduleBlink();
    });
  }

  @override
  void didUpdateWidget(Sprout old) {
    super.didUpdateWidget(old);
    if (Sprout.debugStill || context.reduceMotion) return;
    if (old.mood != widget.mood || old.pulse != widget.pulse) {
      _react.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _blink.dispose();
    _react.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_blink, _react]),
          builder: (context, _) => CustomPaint(
            size: Size(widget.size, widget.size * 1.1),
            painter: _SproutPainter(
              mood: widget.mood,
              blink: _blink.value,
              react: _react.isAnimating ? _react.value : 1,
              p: p,
            ),
          ),
        ),
      ),
    );
  }
}

class _SproutPainter extends CustomPainter {
  _SproutPainter({
    required this.mood,
    required this.blink,
    required this.react,
    required this.p,
  });

  final SproutMood mood;
  final double blink;

  /// 0..1 progress of the one-shot reaction (1 = at rest).
  final double react;
  final PlatePalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.36;

    // Reaction offsets.
    var lift = 0.0;
    var squash = 0.0;
    var wiggle = 0.0;
    final t = react;
    if (t < 1) {
      switch (mood) {
        case SproutMood.celebrate:
          lift = math.sin(t * math.pi) * w * 0.16;
          squash = -math.sin(t * math.pi * 2) * 0.06 * (1 - t);
          wiggle = math.sin(t * math.pi * 6) * (1 - t);
        case SproutMood.happy:
          lift = math.sin(t * math.pi * 2).abs() * w * 0.06 * (1 - t);
          squash = math.sin(t * math.pi * 2) * 0.05 * (1 - t);
          wiggle = math.sin(t * math.pi * 4) * 0.6 * (1 - t);
        case SproutMood.sleepy:
          squash = math.sin(t * math.pi) * 0.04;
        default:
          wiggle = math.sin(t * math.pi * 3) * 0.4 * (1 - t);
      }
    }
    final droop = mood == SproutMood.sleepy ? 0.06 : 0.0;
    final center = Offset(w / 2, h * 0.6 - lift + w * droop * 0.3);

    // Ground shadow (shrinks while airborne).
    final shadowScale = 1 - lift / (w * 0.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.6 + r * 0.98),
        width: r * 1.5 * shadowScale,
        height: r * 0.22 * shadowScale,
      ),
      Paint()
        ..color = (p.isDark ? Colors.black : const Color(0xFF5A4320))
            .withValues(alpha: p.isDark ? 0.35 : 0.12),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1 + squash, 1 - squash);

    // Stem and leaves.
    final stemTop = Offset(0, -r * 1.22);
    final stem = Paint()
      ..color = p.sproutLeaf
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, -r * 0.92), stemTop, stem);
    // Two leaves in a V; the right one a little smaller.
    _leaf(canvas, stemTop, r, -2.45 - wiggle * 0.35 + droop * 3, flip: false);
    _leaf(
      canvas,
      stemTop,
      r * 0.86,
      -0.7 + wiggle * 0.35 - droop * 3,
      flip: true,
    );

    // Body.
    final body = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawOval(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.05,
          colors: [
            Color.lerp(p.sproutBody, Colors.white, 0.28)!,
            p.sproutBody,
            p.sproutDeep,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(body),
    );
    // Shine.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-r * 0.42, -r * 0.5),
        width: r * 0.34,
        height: r * 0.2,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );

    // Cheeks.
    final cheek = Paint()..color = p.sproutCheek.withValues(alpha: 0.75);
    for (final s in [-1, 1]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(r * 0.56 * s, r * 0.2),
          width: r * 0.3,
          height: r * 0.17,
        ),
        cheek,
      );
    }

    _face(canvas, r);
    canvas.restore();

    if (mood == SproutMood.sleepy) _zzz(canvas, Offset(w * 0.8, h * 0.18), w);
  }

  void _leaf(
    Canvas canvas,
    Offset base,
    double r,
    double angle, {
    required bool flip,
  }) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final len = r * 0.95;
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.5, -len * 0.42, len, 0)
      ..quadraticBezierTo(len * 0.5, len * 0.42, 0, 0)
      ..close();
    canvas.drawPath(leaf, Paint()..color = flip ? p.sproutBody : p.sproutLeaf);
    canvas.drawLine(
      Offset(len * 0.12, 0),
      Offset(len * 0.8, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = r * 0.04
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  void _face(Canvas canvas, double r) {
    final ink = Paint()..color = p.sproutFace;
    final line = Paint()
      ..color = p.sproutFace
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.09
      ..strokeCap = StrokeCap.round;
    final eyeY = -r * 0.08;
    final eyeX = r * 0.34;

    switch (mood) {
      case SproutMood.happy:
        for (final s in [-1, 1]) {
          final c = Offset(eyeX * s, eyeY + r * 0.04);
          canvas.drawArc(
            Rect.fromCircle(center: c, radius: r * 0.12),
            math.pi * 1.1,
            math.pi * 0.8,
            false,
            line,
          );
        }
      case SproutMood.celebrate:
        for (final s in [-1, 1]) {
          _star(canvas, Offset(eyeX * s, eyeY), r * 0.16, p.honey);
        }
      case SproutMood.sleepy:
        for (final s in [-1, 1]) {
          final c = Offset(eyeX * s, eyeY - r * 0.02);
          canvas.drawArc(
            Rect.fromCircle(center: c, radius: r * 0.11),
            0.15,
            math.pi - 0.3,
            false,
            line,
          );
        }
      default:
        final look = mood == SproutMood.thinking
            ? Offset(r * 0.06, -r * 0.06)
            : Offset.zero;
        final open = (1 - blink).clamp(0.08, 1.0);
        final eyeH = r * (mood == SproutMood.hungry ? 0.3 : 0.26) * open;
        for (final s in [-1, 1]) {
          final c = Offset(eyeX * s, eyeY) + look;
          canvas.drawOval(
            Rect.fromCenter(center: c, width: r * 0.2, height: eyeH),
            ink,
          );
          if (open > 0.5) {
            canvas.drawCircle(
              c + Offset(r * 0.035, -eyeH * 0.22),
              r * 0.04,
              Paint()..color = Colors.white,
            );
          }
        }
    }

    // Mouth.
    final mouthC = Offset(0, r * 0.3);
    switch (mood) {
      case SproutMood.celebrate:
        final m = Path()
          ..moveTo(-r * 0.24, mouthC.dy - r * 0.04)
          ..quadraticBezierTo(
            0,
            mouthC.dy + r * 0.42,
            r * 0.24,
            mouthC.dy - r * 0.04,
          )
          ..close();
        canvas.drawPath(m, ink);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, mouthC.dy + r * 0.13),
            width: r * 0.2,
            height: r * 0.1,
          ),
          Paint()..color = p.sproutCheek,
        );
      case SproutMood.hungry:
        canvas.drawOval(
          Rect.fromCenter(center: mouthC, width: r * 0.17, height: r * 0.2),
          ink,
        );
      case SproutMood.sleepy:
        canvas.drawLine(
          mouthC.translate(-r * 0.08, 0),
          mouthC.translate(r * 0.08, 0),
          line,
        );
      case SproutMood.thinking:
        canvas.drawArc(
          Rect.fromCenter(
            center: mouthC.translate(r * 0.05, -r * 0.02),
            width: r * 0.22,
            height: r * 0.12,
          ),
          0.2,
          math.pi * 0.6,
          false,
          line,
        );
      default:
        final wide = mood == SproutMood.happy ? 0.42 : 0.3;
        canvas.drawArc(
          Rect.fromCenter(
            center: mouthC.translate(0, -r * 0.08),
            width: r * wide,
            height: r * 0.26,
          ),
          0.25,
          math.pi - 0.5,
          false,
          line,
        );
    }
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = c + Offset(math.cos(a), math.sin(a)) * rad;
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _zzz(Canvas canvas, Offset at, double w) {
    final style = TextStyle(
      color: p.textMuted,
      fontFamily: PtText.family,
      fontWeight: FontWeight.w700,
    );
    var o = at;
    for (final s in [0.13, 0.1, 0.075]) {
      final tp = TextPainter(
        text: TextSpan(
          text: 'z',
          style: style.copyWith(fontSize: w * s),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, o);
      o = o.translate(w * 0.08, -w * 0.09);
    }
  }

  @override
  bool shouldRepaint(_SproutPainter old) =>
      old.mood != mood ||
      old.blink != blink ||
      old.react != react ||
      old.p != p;
}
