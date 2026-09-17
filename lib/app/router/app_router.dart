import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/extensions/context_extensions.dart';
import '../../features/address/presentation/view/address_list_page.dart';
import '../../features/auth/presentation/view/login_page.dart';
import '../../features/brand/presentation/view/brand_page.dart';
import '../../features/cart/presentation/view/cart_page.dart';
import '../../features/category/presentation/view/category_detail_page.dart';
import '../../features/category/presentation/view/category_page.dart';
import '../../features/favorite/presentation/view/favorite_page.dart';
import '../../features/legal/presentation/view/faq_page.dart';
import '../../features/legal/presentation/view/privacy_page.dart';
import '../../features/legal/presentation/view/terms_page.dart';
import '../../features/home/presentation/view/home_page.dart';
import '../../features/marketplace/presentation/view/marketplace_page.dart';
import '../../features/notification/presentation/view/notification_page.dart';
import '../../features/order/presentation/view/order_detail_page.dart';
import '../../features/order/presentation/view/order_list_page.dart';
import '../../features/product/presentation/view/product_detail_page.dart';
import '../../features/product/presentation/view/product_reviews_page.dart';
import '../../features/profile/presentation/view/edit_profile_page.dart';
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
                  GoRoute(
                    path: AppRoutes.productReviews.path,
                    name: AppRoutes.productReviews.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ProductReviewsPage(
                      productId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.brand.path,
                    name: AppRoutes.brand.name,
                    parentNavigatorKey: rootNavigatorKey,
                    // `extra` carries the display name, so the app bar reads
                    // "Loro Piana" rather than the slug.
                    builder: (context, state) => BrandPage(
                      id: state.pathParameters['id']!,
                      title: state.extra as String?,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.categoryDetail.path,
                    name: AppRoutes.categoryDetail.name,
                    parentNavigatorKey: rootNavigatorKey,
                    // `extra` carries the display name, so the app bar reads
                    // "Make Up" rather than the slug.
                    builder: (context, state) => CategoryDetailPage(
                      id: state.pathParameters['id']!,
                      title: state.extra as String?,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.marketplace.path,
                    name: AppRoutes.marketplace.name,
                    parentNavigatorKey: rootNavigatorKey,
                    // `extra` carries the partner's display name so the app
                    // bar reads "AliExpress", not "aliexpress".
                    builder: (context, state) => MarketplacePage(
                      id: state.pathParameters['id']!,
                      title: state.extra as String?,
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
                routes: [
                  GoRoute(
                    path: AppRoutes.orderDetail.path,
                    name: AppRoutes.orderDetail.name,
                    // Over the shell: an order being read is not a tab, and
                    // the nav bar would only offer a way to lose it.
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const OrderDetailPage(),
                  ),
                ],
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
                  // Two entry points, one page: history and the active
                  // subset differ by title (and later by filter), not by
                  // layout.
                  GoRoute(
                    path: AppRoutes.orders.path,
                    name: AppRoutes.orders.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        OrderListPage(title: context.l10n.profileOrderHistory),
                  ),
                  GoRoute(
                    path: AppRoutes.activeOrders.path,
                    name: AppRoutes.activeOrders.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        OrderListPage(title: context.l10n.profileActiveOrders),
                  ),
                  GoRoute(
                    path: AppRoutes.editProfile.path,
                    name: AppRoutes.editProfile.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const EditProfilePage(),
                  ),
                  GoRoute(
                    path: AppRoutes.addresses.path,
                    name: AppRoutes.addresses.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => AddressListPage(
                      title: context.l10n.profileSavedLocations,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.notifications.path,
                    name: AppRoutes.notifications.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => NotificationPage(
                      title: context.l10n.profileNotifications,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.announcements.path,
                    name: AppRoutes.announcements.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => NotificationPage(
                      title: context.l10n.profileAnnouncements,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.faq.path,
                    name: AppRoutes.faq.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const FaqPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.terms.path,
                    name: AppRoutes.terms.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const TermsPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.privacy.path,
                    name: AppRoutes.privacy.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PrivacyPage(),
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
