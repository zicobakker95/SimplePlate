import 'package:flutter/material.dart';

import '../theme/plate_theme.dart';

/// Placeholder rows that breathe while results load. The animation only
/// runs while the skeleton is on screen, i.e. while something is loading.
class PtSkeletonList extends StatefulWidget {
  const PtSkeletonList({super.key, this.rows = 5});
  final int rows;

  @override
  State<PtSkeletonList> createState() => _PtSkeletonListState();
}

class _PtSkeletonListState extends State<PtSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: p.sunken,
        borderRadius: BorderRadius.circular(h),
      ),
    );
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
        child: Column(
          children: [
            for (var i = 0; i < widget.rows; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Pt.gutter,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: p.sunken,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bar(160.0 + (i % 3) * 30, 12),
                          const SizedBox(height: 8),
                          bar(100.0 + (i % 2) * 40, 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
