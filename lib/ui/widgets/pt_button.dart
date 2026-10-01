import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';
import 'pressable.dart';

enum PtButtonTone {
  /// Filled herb green: the one main action on a surface.
  primary,

  /// Tinted green: secondary actions that still matter.
  soft,

  /// Hairline outline.
  outline,

  /// Text only.
  ghost,

  /// Tomato: destructive.
  danger,

  /// Saffron gradient: Premium.
  premium,
}

/// The app's button. Pill shaped, squishes on press, 48 dp minimum height,
/// shows a spinner instead of the icon while [loading].
class PtButton extends StatelessWidget {
  const PtButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = PtButtonTone.primary,
    this.expand = false,
    this.loading = false,
    this.compact = false,
    this.haptic = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PtButtonTone tone;

  /// Fill the available width.
  final bool expand;
  final bool loading;

  /// Smaller padding for inline/card actions (still 48 dp tall).
  final bool compact;
  final bool haptic;

  /// Overrides the accent (e.g. water blue on the water card).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final enabled = onPressed != null && !loading;
    final accent = color ?? p.primary;

    Color bg;
    Color fg;
    Gradient? gradient;
    BoxBorder? border;
    switch (tone) {
      case PtButtonTone.primary:
        bg = accent;
        fg = color == null ? p.onPrimary : Colors.white;
      case PtButtonTone.soft:
        bg = color == null ? p.primarySoft : accent.withValues(alpha: 0.14);
        fg = p.isDark ? accent : _darken(accent);
      case PtButtonTone.outline:
        bg = Colors.transparent;
        fg = p.isDark ? accent : _darken(accent);
        border = Border.all(color: p.border, width: 1.5);
      case PtButtonTone.ghost:
        bg = Colors.transparent;
        fg = p.isDark ? accent : _darken(accent);
      case PtButtonTone.danger:
        bg = p.dangerSoft;
        fg = p.dangerInk;
      case PtButtonTone.premium:
        bg = p.premium;
        gradient = Pt.premiumGradient(p);
        fg = const Color(0xFF3A2606);
    }

    final hPad = compact ? 16.0 : 22.0;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: fg),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PtText.button(
              color: fg,
            ).copyWith(fontSize: compact ? 14.5 : 16),
          ),
        ),
      ],
    );

    return Pressable(
      onTap: enabled ? onPressed : null,
      enabled: enabled,
      haptic: haptic,
      pressedScale: 0.96,
      semanticLabel: null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: compact ? Pt.tap : 54,
          minWidth: Pt.tap,
        ),
        child: Container(
          width: expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
          alignment: expand ? Alignment.center : null,
          decoration: BoxDecoration(
            color: gradient == null ? bg : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(Pt.rPill),
            border: border,
            boxShadow: tone == PtButtonTone.primary && enabled && !p.isDark
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      ),
    );
  }

  static Color _darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.78).clamp(0.0, 1.0)).toColor();
  }
}

/// Round icon button with squish feedback, a 48 dp target and a tooltip.
class PtIconButton extends StatelessWidget {
  const PtIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.background,
    this.size = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  /// Null draws the default surface chip; transparent for bare glyphs.
  final Color? background;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final bg = background ?? p.surface;
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onPressed,
        enabled: onPressed != null,
        pressedScale: 0.88,
        semanticLabel: tooltip,
        child: SizedBox(
          width: Pt.tap,
          height: Pt.tap,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                boxShadow: bg == Colors.transparent ? null : Pt.shadow(p, 0.5),
                border: p.isDark && bg != Colors.transparent
                    ? Border.all(color: p.border)
                    : null,
              ),
              child: Icon(icon, size: iconSize, color: color ?? p.text),
            ),
          ),
        ),
      ),
    );
  }
}
