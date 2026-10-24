import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Width bands, read from the space the app actually has — never from the
/// device type or the size at launch, because the iPhone Duo resizes the
/// running app when it folds or unfolds, and iPad split view does the same.
///
///  * [phone]  under 600 pt: phones and the Duo's outer display
///  * [open]   600–840 pt:   the Duo's inner display, small tablets in portrait
///  * [tablet] 840 pt and up: tablets and the Duo's inner display in landscape
enum WidthBand { phone, open, tablet }

WidthBand widthBandFor(double width) => width < 600
    ? WidthBand.phone
    : width < 840
    ? WidthBand.open
    : WidthBand.tablet;

WidthBand widthBandOf(BuildContext context) =>
    widthBandFor(MediaQuery.sizeOf(context).width);

/// The widest a screen's column of cards, lists and forms gets (its phone
/// gutters included), so phone UI doesn't stretch across a wide window.
const double kContentMaxWidth = 640;

/// How far to pull a screen's content in from each side to centre it in a
/// column at most [maxWidth] wide. Zero on phones, so their layout is
/// untouched.
double contentInset(
  BuildContext context, {
  double maxWidth = kContentMaxWidth,
}) => math.max(0, (MediaQuery.sizeOf(context).width - maxWidth) / 2);

extension ContentPadding on EdgeInsets {
  /// This padding plus [contentInset] at each side: for a scroll view's
  /// padding, so the content is capped but the whole width still scrolls.
  EdgeInsets capped(BuildContext context) {
    final inset = contentInset(context);
    return copyWith(left: left + inset, right: right + inset);
  }
}

/// Keeps [child] in a centred column at most [kContentMaxWidth] wide. A
/// no-op on phones, and the same widget tree at every width, so folding or
/// unfolding never rebuilds what is inside it.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: contentInset(context)),
    child: child,
  );
}
