import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/plate_theme.dart';

/// Fire-and-forget food confetti: peas, leaves and crumbs in the macro
/// colours. Put a [ConfettiLayer] above the content and call
/// [ConfettiController.burst]. The ticker stops when the last piece fades,
/// so an idle screen never repaints.
class ConfettiController extends ChangeNotifier {
  final List<_Piece> _pieces = [];
  final math.Random _rng = math.Random();

  /// A radial pop from [origin] (fractions of the layer size).
  void burst({
    Offset origin = const Offset(0.5, 0.3),
    int count = 34,
    required List<Color> colors,
    double power = 1,
  }) {
    for (var i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (_rng.nextDouble() - 0.5) * math.pi * 1.6;
      final speed = (240 + _rng.nextDouble() * 380) * power;
      _pieces.add(
        _Piece(
          pos: origin,
          vel: Offset(math.cos(angle), math.sin(angle)) * speed,
          color: colors[_rng.nextInt(colors.length)],
          size: 6 + _rng.nextDouble() * 6,
          spin: (_rng.nextDouble() - 0.5) * 12,
          life: 1.2 + _rng.nextDouble() * 0.7,
          shape: _rng.nextInt(3),
        ),
      );
    }
    notifyListeners();
  }

  bool get isActive => _pieces.isNotEmpty;
}

class ConfettiLayer extends StatefulWidget {
  const ConfettiLayer({super.key, required this.controller});
  final ConfettiController controller;

  @override
  State<ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    widget.controller.addListener(_wake);
  }

  void _wake() {
    if (context.reduceMotion) {
      widget.controller._pieces.clear();
      return;
    }
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 1 / 60
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final size = context.size ?? Size.zero;
    final list = widget.controller._pieces;
    for (final p in list) {
      if (p.relative) {
        p.pos = Offset(p.pos.dx * size.width, p.pos.dy * size.height);
        p.relative = false;
      }
      p.vel = Offset(p.vel.dx * (1 - 1.1 * dt), p.vel.dy + 640 * dt);
      p.pos += p.vel * dt;
      p.angle += p.spin * dt;
      p.age += dt;
    }
    list.removeWhere((p) => p.age >= p.life || p.pos.dy > size.height + 40);
    if (list.isEmpty) _ticker.stop();
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_wake);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(widget.controller._pieces),
        ),
      ),
    );
  }
}

class _Piece {
  _Piece({
    required this.pos,
    required this.vel,
    required this.color,
    required this.size,
    required this.spin,
    required this.life,
    required this.shape,
  });

  Offset pos;
  Offset vel;
  bool relative = true;
  final Color color;
  final double size;
  final double spin;
  final double life;
  final int shape;
  double angle = 0;
  double age = 0;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces);
  final List<_Piece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      if (p.relative) continue;
      final fade = (1 - p.age / p.life).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: math.min(1, fade * 1.8));
      canvas.save();
      canvas.translate(p.pos.dx, p.pos.dy);
      canvas.rotate(p.angle);
      switch (p.shape) {
        case 0: // pea
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
          canvas.drawCircle(
            Offset(-p.size * 0.14, -p.size * 0.14),
            p.size * 0.13,
            Paint()..color = Colors.white.withValues(alpha: 0.5 * fade),
          );
        case 1: // leaf
          final leaf = Path()
            ..moveTo(-p.size * 0.7, 0)
            ..quadraticBezierTo(0, -p.size * 0.55, p.size * 0.7, 0)
            ..quadraticBezierTo(0, p.size * 0.55, -p.size * 0.7, 0)
            ..close();
          canvas.drawPath(leaf, paint);
        default: // crumb
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size,
                height: p.size * 0.6,
              ),
              Radius.circular(p.size * 0.2),
            ),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// The default confetti colours: the plate's macro palette.
List<Color> foodConfettiColors(PlatePalette p) => [
  p.fresh,
  p.carbs,
  p.protein,
  p.fat,
  p.honey,
  p.sproutBody,
];
