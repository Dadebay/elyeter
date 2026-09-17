import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/address/presentation/view/address_list_page.dart';
import '../../features/auth/presentation/view/login_page.dart';
import '../../features/cart/presentation/view/cart_page.dart';
import '../../features/category/presentation/view/category_page.dart';
import '../../features/favorite/presentation/view/favorite_page.dart';
import '../../features/home/presentation/view/home_page.dart';
import '../../features/notification/presentation/view/notification_page.dart';
import '../../features/order/presentation/view/order_list_page.dart';
import '../../features/product/presentation/view/product_detail_page.dart';
import '../../features/profile/presentation/view/profile_page.dart';
import '../../features/search/presentation/view/search_page.dart';
import '../../features/settings/presentation/view/settings_page.dart';
import '../view/home_shell.dart';
import 'app_routes.dart';

/// Single [GoRouter] instance.
///
/// The five tabs live in a [StatefulShellRoute] so each keeps its own
/// navigation stack and scroll position — tapping Home twice does not reset
/// the Cart tab.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home.path,
                name: AppRoutes.home.name,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: AppRoutes.productDetail.path,
                    name: AppRoutes.productDetail.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ProductDetailPage(
                      productId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.category.path,
                name: AppRoutes.category.name,
                builder: (context, state) => const CategoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart.path,
                name: AppRoutes.cart.name,
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorite.path,
                name: AppRoutes.favorite.name,
                builder: (context, state) => const FavoritePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile.path,
                name: AppRoutes.profile.name,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: AppRoutes.orders.path,
                    name: AppRoutes.orders.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const OrderListPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.addresses.path,
                    name: AppRoutes.addresses.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AddressListPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.notifications.path,
                    name: AppRoutes.notifications.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const NotificationPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.settings.path,
                    name: AppRoutes.settings.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search.path,
        name: AppRoutes.search.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SearchPage(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(state.error.toString()))),
  );
}
