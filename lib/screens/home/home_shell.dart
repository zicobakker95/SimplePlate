import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
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

  static const _pages = <Widget>[
    TodayScreen(),
    HistoryScreen(),
    GoalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: AppColors.surface,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu_rounded,
                color: AppColors.primary),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded,
                color: AppColors.primary),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon:
                const Icon(Icons.flag_rounded, color: AppColors.primary),
            label: l10n.navGoals,
          ),
        ],
      ),
    );
  }
}
