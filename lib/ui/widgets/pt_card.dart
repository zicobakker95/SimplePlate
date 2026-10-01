import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';
import 'pressable.dart';

/// Plate-white rounded card with the soft warm shadow (border in dark).
class PtCard extends StatelessWidget {
  const PtCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Pt.s16),
    this.color,
    this.gradient,
    this.radius = Pt.rMd,
    this.onTap,
    this.borderColor,
    this.shadow = true,
    this.clip = false,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final double radius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final bool shadow;
  final bool clip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final border = borderColor ?? (p.isDark ? p.border : null);
    final card = Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? p.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border, width: 1.2),
        boxShadow: shadow ? Pt.shadow(p) : null,
      ),
      child: child,
    );
    return onTap == null
        ? card
        : Pressable(
            onTap: onTap,
            pressedScale: 0.98,
            semanticLabel: semanticLabel,
            child: card,
          );
  }
}

/// Small rounded-square icon chip used as a leading badge.
class IconBadge extends StatelessWidget {
  const IconBadge(
    this.icon, {
    super.key,
    required this.color,
    this.size = 40,
    this.iconSize,
    this.background,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: iconSize ?? size * 0.52),
    );
  }
}

/// Section header: small caps label with an optional trailing widget.
class PtSectionHeader extends StatelessWidget {
  const PtSectionHeader(
    this.label, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(4, 20, 4, 10),
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    label.toUpperCase(),
                    style: PtText.label(color: p.textMuted),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: PtText.small(color: p.textMuted)),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// List row: badge, title/subtitle, trailing. 56+ dp tall, squishy.
class PtTile extends StatelessWidget {
  const PtTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.titleStyle,
    this.subtitleMaxLines = 2,
    this.titleMaxLines = 2,
    this.below,
  });

  final String title;
  final String? subtitle;

  /// Extra line under the subtitle (macro dots, a bar).
  final Widget? below;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final int subtitleMaxLines;
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle ?? PtText.tile(color: p.text),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: subtitleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: PtText.small(color: p.textMuted),
                    ),
                  ],
                  if (below != null) ...[const SizedBox(height: 4), below!],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
    if (onTap == null && onLongPress == null) return row;
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 0.98,
      child: row,
    );
  }
}

/// A row with a switch. The whole row toggles.
class PtSwitchTile extends StatelessWidget {
  const PtSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: PtTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        titleStyle: PtText.tile(
          color: context.pal.text,
        ).copyWith(fontWeight: FontWeight.w600),
        subtitleMaxLines: 4,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

/// Hairline divider inset to line up with tile text.
class PtDivider extends StatelessWidget {
  const PtDivider({super.key, this.indent = 16});
  final double indent;

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    indent: indent,
    color: context.pal.border,
  );
}

/// Small rounded pill (cached, unlocked, best value, streak...).
class PtTag extends StatelessWidget {
  const PtTag({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;

  /// Solid background with white text instead of a tint.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = !filled
        ? color
        : ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : const Color(0xFF1A1712);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Pt.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PtText.tiny(color: fg, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
