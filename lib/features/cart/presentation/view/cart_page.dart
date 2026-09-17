import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../home/presentation/view/home_placeholder_data.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_line_tile.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/swipe_to_delete.dart';

/// The cart: one line per product, a running total over the list.
///
/// Resolves ids against the catalog, so a product that leaves the catalog
/// simply stops being listed — the stored line does no harm.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  /// Resting height of the summary pill. Only feeds the scroll clearance, so
  /// a pixel either way just changes how much empty space trails the list.
  static const _summaryHeight = 56.0;

  /// Gap under the pill, and again under the list.
  static const _gap = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    // The pill sits clear of the nav bar rather than a fixed distance off the
    // screen edge, so it lands right on a home-indicator phone and on one
    // without alike.
    final summaryBottom = context.navBarHeight + _gap;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        final lines = HomePlaceholderData.catalog
            .where((product) => cart.contains(product.id))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.white,
          // Stays put while the list scrolls under it, so the count and the
          // "Select All" tick are always in reach.
          appBar: _CartAppBar(count: lines.length, allSelected: cart.allSelected),
          body: lines.isEmpty
              ? const AppEmptyView(icon: Icons.shopping_bag_outlined)
              : Stack(
                  children: [
                    ListView.separated(
                      // The last line scrolls out from under the pill instead
                      // of stopping behind it.
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        summaryBottom + _summaryHeight + _gap,
                      ),
                      itemCount: lines.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColors.grey100),
                      itemBuilder: (context, index) =>
                          _Line(product: lines[index], cart: cart),
                    ),
                    Positioned(
                      left: AppSpacing.page,
                      right: AppSpacing.page,
                      bottom: summaryBottom,
                      child: _Summary(cart: cart, lines: lines),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// Product count on the left, "Select All" pinned to the right edge.
class _CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CartAppBar({required this.count, required this.allSelected});

  static const _height = 76.0;

  final int count;
  final bool allSelected;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // The list slides under the bar without tinting it.
      scrolledUnderElevation: 0,
      toolbarHeight: _height,
      titleSpacing: AppSpacing.page,
      automaticallyImplyLeading: false,
      title: Text(
        context.l10n.cartProductCount(count),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // Tracking is size-specific: at this size the default spacing reads
        // too loose, so it tightens as the type grows.
        style: context.textTheme.headlineLarge?.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      // An action rather than part of the title, so it ends up hard against
      // the right margin however long the count reads.
      actions: count == 0
          ? null
          : [
              _SelectAll(allSelected: allSelected),
              const SizedBox(width: AppSpacing.page),
            ],
    );
  }
}

/// The "Select All" label and its tick, as one control: tapping either ticks
/// every line, and tapping again clears them.
class _SelectAll extends StatelessWidget {
  const _SelectAll({required this.allSelected});

  final bool allSelected;

  @override
  Widget build(BuildContext context) {
    void toggle() => context.read<CartCubit>().toggleSelectAll();

    return GestureDetector(
      onTap: toggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.cartSelectAll,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          CartTickBox(value: allSelected, onTap: toggle),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.product, required this.cart});

  final ProductCardData product;
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return BlocBuilder<FavoriteCubit, Set<String>>(
      buildWhen: (before, after) =>
          before.contains(product.id) != after.contains(product.id),
      builder: (context, favorites) => SwipeToDelete(
        onDelete: () => cubit.remove(product.id),
        child: CartLineTile(
          product: product,
          quantity: cart.quantityOf(product.id),
          selected: cart.isSelected(product.id),
          isFavorite: favorites.contains(product.id),
          onIncrease: () => cubit.increase(product.id),
          onDecrease: () => cubit.decrease(product.id),
          onSelectedChanged: () => cubit.toggleSelected(product.id),
          onFavoriteTap: () => context.read<FavoriteCubit>().toggle(product.id),
        ),
      ),
    );
  }
}

/// Totals the ticked lines only — unticking a line is how the customer
/// leaves it out without giving it up.
class _Summary extends StatelessWidget {
  const _Summary({required this.cart, required this.lines});

  final CartState cart;
  final List<ProductCardData> lines;

  @override
  Widget build(BuildContext context) {
    var total = 0.0;
    var oldTotal = 0.0;
    var count = 0;

    for (final product in lines) {
      if (!cart.isSelected(product.id)) continue;
      final quantity = cart.quantityOf(product.id);
      total += product.price * quantity;
      oldTotal += (product.oldPrice ?? product.price) * quantity;
      count++;
    }

    return CartSummaryBar(
      productCount: count,
      total: total,
      oldTotal: oldTotal,
      // Nothing ticked is nothing to order, so the pill stays inert rather
      // than opening an empty order.
      onTap: count == 0
          ? null
          : () => context.pushNamed(AppRoutes.orderDetail.name),
    );
  }
}
