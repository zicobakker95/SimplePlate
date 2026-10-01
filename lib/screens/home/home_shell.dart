import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../ui/kit.dart';
import '../../widgets/ad_banner.dart';
import '../goals/goals_screen.dart';
import '../history/history_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[TodayScreen(), HistoryScreen(), GoalsScreen()];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      // Every tab stays alive (state, scroll position, the banner below), but
      // only the visible one ticks; switching fades the new tab in.
      body: Stack(
        children: [
          for (var i = 0; i < _pages.length; i++)
            Offstage(
              offstage: i != _index,
              child: TickerMode(
                enabled: i == _index,
                child: _FadeOnShow(visible: i == _index, child: _pages[i]),
              ),
            ),
        ],
      ),
      // One banner for all three tabs, sitting directly above the nav bar.
      // Placed here rather than in each tab so switching tabs does not
      // dispose and re-request it -- that would burn requests that never get
      // shown, which is exactly the kind of thing that ruins a match rate.
      // The Scaffold lays the tab content out above this, so nothing is
      // covered.
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdBanner.bar(),
          _PlateNavBar(
            index: _index,
            onSelect: (i) => setState(() => _index = i),
            items: [
              _NavItem(
                Icons.restaurant_menu_outlined,
                Icons.restaurant_menu_rounded,
                l10n.navToday,
              ),
              _NavItem(
                Icons.calendar_month_outlined,
                Icons.calendar_month_rounded,
                l10n.navHistory,
              ),
              _NavItem(Icons.flag_outlined, Icons.flag_rounded, l10n.navGoals),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom navigation: the selected tab sits in a soft green pill and its
/// icon springs when chosen.
class _PlateNavBar extends StatelessWidget {
  const _PlateNavBar({
    required this.index,
    required this.onSelect,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final color = selected ? p.primary : p.textMuted;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.9,
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Pt.base,
                curve: Pt.ease,
                width: selected ? 60 : 44,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? p.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(Pt.rPill),
                ),
                child: AnimatedScale(
                  scale: selected ? 1.12 : 1,
                  duration: Pt.slow,
                  curve: Curves.elasticOut,
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: color,
                    size: 23,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PtText.tiny(
                  color: color,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and lifts a tab in each time it becomes the visible one.
class _FadeOnShow extends StatefulWidget {
  const _FadeOnShow({required this.visible, required this.child});
  final bool visible;
  final Widget child;

  @override
  State<_FadeOnShow> createState() => _FadeOnShowState();
}

class _FadeOnShowState extends State<_FadeOnShow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Pt.base)..value = 1;
  }

  @override
  void didUpdateWidget(_FadeOnShow old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible && !context.reduceMotion) {
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
        final t = Pt.ease.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
    );
  }
}
