import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../home/presentation/view/home_placeholder_data.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../cubit/favorite_cubit.dart';

/// The products the customer has favourited.
///
/// Resolves ids against the catalog, so a product that disappears from the
/// catalog simply stops being listed here.
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.favoriteTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: BlocBuilder<FavoriteCubit, Set<String>>(
        builder: (context, favorites) {
          final products = HomePlaceholderData.catalog.where((product) => favorites.contains(product.id)).toList();

          if (products.isEmpty) {
            return const AppEmptyView(icon: Icons.favorite_border_rounded);
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              // Clearance for the floating bottom navigation bar.
              120,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.xl,
              crossAxisSpacing: AppSpacing.md,
              // Image (square) + price + two title lines + button.
              childAspectRatio: 0.58,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return BlocBuilder<CartCubit, CartState>(
                buildWhen: (before, after) => before.contains(product.id) != after.contains(product.id),
                builder: (context, cart) => ProductCard(
                  data: product,
                  onTap: () => context.pushNamed(
                    AppRoutes.productDetail.name,
                    pathParameters: {'id': product.id},
                  ),
                  isFavorite: true,
                  isInCart: cart.contains(product.id),
                  onFavoriteTap: () => context.read<FavoriteCubit>().toggle(product.id),
                  onAddToCart: () => context.read<CartCubit>().toggle(product.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
