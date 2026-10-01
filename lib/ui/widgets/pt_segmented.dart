import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';
import 'pressable.dart';

class PtSegment<T> {
  const PtSegment(this.value, this.label, {this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

/// Segmented control with a thumb that slides between options.
class PtSegmented<T> extends StatelessWidget {
  const PtSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.compact = false,
  });

  final List<PtSegment<T>> segments;
  final T selected;

  /// Null disables the control (locked previews).
  final ValueChanged<T>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final index = segments.indexWhere((s) => s.value == selected);
    final count = segments.length;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.sunken,
        borderRadius: BorderRadius.circular(Pt.rPill),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final finite = box.maxWidth.isFinite;
          return Stack(
            children: [
              if (finite && index >= 0)
                AnimatedPositioned(
                  duration: context.reduceMotion ? Duration.zero : Pt.base,
                  curve: Pt.spring,
                  left: box.maxWidth / count * index,
                  width: box.maxWidth / count,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: p.isDark ? p.surfaceAlt : p.surface,
                      borderRadius: BorderRadius.circular(Pt.rPill),
                      boxShadow: Pt.shadow(p, 0.4),
                    ),
                  ),
                ),
              Row(
                mainAxisSize: finite ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  for (final s in segments)
                    _wrap(
                      finite,
                      Pressable(
                        onTap: onChanged == null || s.value == selected
                            ? null
                            : () => onChanged!(s.value),
                        enabled: onChanged != null,
                        pressedScale: 0.94,
                        child: Semantics(
                          selected: s.value == selected,
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: compact ? 36 : 42,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 10 : 12,
                              vertical: 6,
                            ),
                            alignment: Alignment.center,
                            // Unbounded width has no sliding thumb.
                            decoration: !finite && s.value == selected
                                ? BoxDecoration(
                                    color: p.isDark ? p.surfaceAlt : p.surface,
                                    borderRadius: BorderRadius.circular(
                                      Pt.rPill,
                                    ),
                                  )
                                : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (s.icon != null) ...[
                                  Icon(
                                    s.icon,
                                    size: 16,
                                    color: s.value == selected
                                        ? p.primary
                                        : p.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: AnimatedDefaultTextStyle(
                                    duration: Pt.fast,
                                    style: PtText.small(
                                      color: s.value == selected
                                          ? p.text
                                          : p.textMuted,
                                      weight: s.value == selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    child: Text(
                                      s.label,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _wrap(bool finite, Widget child) =>
      finite ? Expanded(child: child) : child;
}

/// A pill choice chip that springs when selected.
class PtChoiceChip extends StatelessWidget {
  const PtChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Emoji or short glyph in front of the label.
  final String? leading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final accent = color ?? p.primary;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.92,
      haptic: true,
      child: Semantics(
        selected: selected,
        child: AnimatedContainer(
          duration: Pt.base,
          curve: Pt.ease,
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? accent : p.sunken,
            borderRadius: BorderRadius.circular(Pt.rPill),
            boxShadow: selected && !p.isDark
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                AnimatedScale(
                  scale: selected ? 1.18 : 1,
                  duration: Pt.base,
                  curve: Pt.spring,
                  child: Text(leading!, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: PtText.small(
                    // Text colour follows the chip's own lightness, so any
                    // accent stays readable.
                    color: selected
                        ? (ThemeData.estimateBrightnessForColor(accent) ==
                                  Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A1712))
                        : p.text,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
