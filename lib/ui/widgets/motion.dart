import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';

/// Fades and rises its child in, delayed by [index] steps: staggered lists.
/// Plays once per element; instant under reduce-motion.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 45),
    this.offset = 18,
    this.duration = const Duration(milliseconds: 420),
  });

  final Widget child;
  final int index;
  final Duration step;
  final double offset;
  final Duration duration;

  /// Screenshots/tests: render everything in its final state.
  static bool debugSkip = false;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Duration _delay;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // The stagger delay lives inside the controller (an Interval) rather
    // than in a Timer, so nothing is left pending when a screen closes.
    _delay = widget.step * math.min(widget.index, 10);
    _c = AnimationController(vsync: this, duration: _delay + widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (FadeSlideIn.debugSkip || context.reduceMotion) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _c.duration!.inMicroseconds;
    final start = total == 0 ? 0.0 : _delay.inMicroseconds / total;
    final curve = Interval(start, 1, curve: Pt.ease);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        if (_c.value >= 1) return child!;
        final t = curve.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offset),
            child: child,
          ),
        );
      },
    );
  }
}

/// A number that counts towards its new value (calories, grams).
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    required this.style,
    this.format,
    this.duration = const Duration(milliseconds: 700),
    this.textAlign,
  });

  final double value;
  final TextStyle style;

  /// Defaults to a rounded integer.
  final String Function(double v)? format;
  final Duration duration;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final fmt = format ?? (v) => v.round().toString();
    if (context.reduceMotion) {
      return Text(fmt(value), style: style, textAlign: textAlign);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: Pt.ease,
      builder: (context, v, _) =>
          Text(fmt(v), style: style, textAlign: textAlign),
    );
  }
}

/// Pops its child in with a little overshoot the first time it builds:
/// a newly logged food, a new ingredient, a badge.
class PopIn extends StatefulWidget {
  const PopIn({
    super.key,
    required this.child,
    this.enabled = true,
    this.delay = Duration.zero,
  });

  final Widget child;

  /// False renders the child as-is (rows that were already there).
  final bool enabled;
  final Duration delay;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: widget.delay + const Duration(milliseconds: 520),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.enabled || FadeSlideIn.debugSkip || context.reduceMotion) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _c.duration!.inMicroseconds;
    final start = widget.delay.inMicroseconds / total;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        if (_c.value >= 1) return child!;
        final t = Interval(start, 1).transform(_c.value);
        final scale = Curves.easeOutBack.transform(t);
        return Opacity(
          opacity: Curves.easeOut.transform(math.min(1, t * 2)),
          child: Transform.scale(scale: 0.6 + 0.4 * scale, child: child),
        );
      },
    );
  }
}

/// Plays a one-shot "boing" on [child] every time [trigger] changes:
/// the streak chip when it grows, a counter when something is added.
class Bump extends StatefulWidget {
  const Bump({super.key, required this.trigger, required this.child});
  final Object? trigger;
  final Widget child;

  @override
  State<Bump> createState() => _BumpState();
}

class _BumpState extends State<Bump> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    )..value = 1;
  }

  @override
  void didUpdateWidget(Bump old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !context.reduceMotion) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        if (_c.value >= 1) return child!;
        final s = 1 + 0.18 * math.sin(_c.value * math.pi);
        return Transform.scale(scale: s, child: child);
      },
    );
  }
}
