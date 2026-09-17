import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/extensions/context_extensions.dart';
import 'widgets/app_bottom_nav_bar.dart';

/// Scaffold that hosts the five tab branches and the floating nav bar.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.navHome,
      l10n.navCategory,
      l10n.navCart,
      l10n.navFavorite,
      l10n.navProfile,
    ];

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        items: [
          for (var i = 0; i < labels.length; i++)
            AppNavItem(asset: AppBottomNavBar.assets[i], label: labels[i]),
        ],
      ),
    );
  }

  /// Tapping the active tab again pops it back to its root.
  void _goBranch(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}
