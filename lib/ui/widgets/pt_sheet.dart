import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';
import 'pt_button.dart';

/// Opens a bottom sheet in the app's one sheet style: rounded top, grab
/// handle, optional title, padding that follows the keyboard.
///
/// [builder] returns the body. Use [scrollable] for forms so a small screen
/// or a large text scale can scroll instead of overflowing.
Future<T?> showPtSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  String? subtitle,
  bool scrollable = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => PtSheetFrame(
      title: title,
      subtitle: subtitle,
      scrollable: scrollable,
      child: Builder(builder: builder),
    ),
  );
}

/// The frame every sheet uses. Exposed for sheets that need their own
/// scroll controller (draggable sheets).
class PtSheetFrame extends StatelessWidget {
  const PtSheetFrame({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.scrollable = true,
    this.padding = const EdgeInsets.fromLTRB(Pt.gutter, 0, Pt.gutter, 20),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final body = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: PtText.title(color: p.text)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: PtText.small(color: p.textMuted)),
            ],
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PtGrabHandle(),
            Flexible(
              child: scrollable ? SingleChildScrollView(child: body) : body,
            ),
          ],
        ),
      ),
    );
  }
}

class PtGrabHandle extends StatelessWidget {
  const PtGrabHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Center(
        child: Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: context.pal.border,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

/// The app's dialog. A header glyph, title, body and up to two actions.
/// [content] replaces the body text for dialogs with fields.
class PtDialog extends StatelessWidget {
  const PtDialog({
    super.key,
    required this.title,
    this.body,
    this.content,
    this.icon,
    this.iconColor,
    required this.actions,
  });

  final String title;
  final String? body;
  final Widget? content;
  final IconData? icon;
  final Color? iconColor;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final accent = iconColor ?? p.primary;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              title,
              style: PtText.headline(color: p.text).copyWith(fontSize: 19),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!, style: PtText.body(color: p.textMuted)),
            ],
            if (content != null) ...[const SizedBox(height: 14), content!],
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

/// Yes/no confirmation in the app style. Returns true on confirm.
Future<bool?> showPtConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  IconData? icon,
  bool destructive = false,
  bool barrierDismissible = true,
}) {
  final p = context.pal;
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => PtDialog(
      title: title,
      body: body,
      icon: icon,
      iconColor: destructive ? p.danger : null,
      actions: [
        PtButton(
          label: cancelLabel,
          tone: PtButtonTone.ghost,
          compact: true,
          color: destructive ? p.textMuted : null,
          onPressed: () => Navigator.pop(ctx, false),
        ),
        PtButton(
          label: confirmLabel,
          tone: destructive ? PtButtonTone.danger : PtButtonTone.primary,
          compact: true,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
}
