import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/plate_theme.dart';

/// Tap feedback used everywhere: the child squishes while pressed and
/// springs back on release. Feedback starts on pointer-down so taps feel
/// instant; [onTap] fires on release as usual.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.haptic = false,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
    this.semanticLabel,
    this.button = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;

  /// Light selection click on press (logging actions only).
  final bool haptic;
  final bool enabled;
  final HitTestBehavior behavior;
  final String? semanticLabel;

  /// Announce as a button (off for rows that carry their own semantics).
  final bool button;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _active =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _set(bool down) {
    if (_down != down && mounted) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final still = context.reduceMotion;
    return Semantics(
      button: widget.button,
      enabled: _active,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: _active
            ? (_) {
                _set(true);
                if (widget.haptic) HapticFeedback.selectionClick();
              }
            : null,
        onTapUp: _active ? (_) => _set(false) : null,
        onTapCancel: _active ? () => _set(false) : null,
        onTap: widget.enabled ? widget.onTap : null,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        child: AnimatedScale(
          scale: _down && !still ? widget.pressedScale : 1,
          duration: _down ? const Duration(milliseconds: 80) : Pt.base,
          curve: _down ? Curves.easeOut : Pt.spring,
          child: AnimatedOpacity(
            opacity: widget.enabled ? 1 : 0.45,
            duration: Pt.fast,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
