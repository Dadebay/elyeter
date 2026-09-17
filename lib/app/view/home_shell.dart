import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/extensions/context_extensions.dart';
import '../../core/widgets/cart_fly_animation.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/cart_state.dart';
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
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cart) => AppBottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _goBranch,
          items: [
            for (var i = 0; i < labels.length; i++)
              AppNavItem(
                asset: AppBottomNavBar.assets[i],
                label: labels[i],
                // The Cart tab is what added products fly to, and the only
                // one carrying a count.
                iconKey: i == _cartTab ? CartFlyAnimation.cartIconKey : null,
                badgeCount: i == _cartTab ? cart.lineCount : 0,
              ),
          ],
        ),
      ),
    );
  }

  /// Index of the Cart tab in [AppBottomNavBar.assets].
  static const _cartTab = 2;

  /// Tapping the active tab again pops it back to its root.
  void _goBranch(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}
