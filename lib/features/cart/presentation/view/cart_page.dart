import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/shop_api.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../order/domain/entities/pre_order_line.dart';
import '../../../order/domain/repositories/pre_order_repository.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../home/presentation/view/home_placeholder_data.dart';
import '../../../product/domain/entities/product_detail.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_empty_view.dart';
import '../widgets/cart_line_tile.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/swipe_to_delete.dart';

/// The cart: one line per product, a running total over the list.
///
/// The cart only remembers slugs, quantities and chosen variants, so each
/// line is filled in from the product's own page (`GET /products/:slug`) —
/// its name, photo, and the price of the variant that was picked. A slug the
/// API no longer knows is dropped from the cart; one that merely could not be
/// fetched is left alone and tried again on a pull to refresh.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  /// Resting height of the summary pill. Only feeds the scroll clearance, so
  /// a pixel either way just changes how much empty space trails the list.
  static const _summaryHeight = 56.0;

  /// Gap under the pill, and again under the list.
  static const _gap = AppSpacing.md;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  /// Products already fetched, by slug.
  final Map<String, ProductDetail> _details = {};

  /// Slugs a request has been made for, so one is made only once at a time.
  final Set<String> _requested = {};

  /// Slugs whose fetch failed for a reason other than "not found".
  final Set<String> _failed = {};

  void _ensureLoaded(Iterable<String> slugs) {
    for (final slug in slugs) {
      final known =
          _details.containsKey(slug) ||
          HomePlaceholderData.productById(slug) != null;
      if (known || !_requested.add(slug)) continue;
      _fetch(slug);
    }
  }

  Future<void> _fetch(String slug) async {
    final result = await getIt<ProductRepository>().bySlug(slug);
    if (!mounted) return;
    final detail = result.dataOrNull;
    if (detail != null) {
      setState(() => _details[slug] = detail);
      return;
    }
    if (result.failureOrNull is NotFoundFailure) {
      context.read<CartCubit>().remove(slug);
    } else {
      setState(() => _failed.add(slug));
    }
  }

  Future<void> _retry() async {
    setState(() {
      _requested.removeAll(_failed);
      _failed.clear();
    });
  }

  /// The line for [slug], or null while it is still being fetched.
  ProductCardData? _line(String slug, CartState cart) {
    final placeholder = HomePlaceholderData.productById(slug);
    if (placeholder != null) return placeholder;
    final detail = _details[slug];
    if (detail == null) return null;

    final product = detail.product;
    final variant = detail.variants
        .where((v) => v.id == cart.variants[slug])
        .firstOrNull;
    // The product's own photo comes from our file server. A variant's photo is
    // a supplier's link, which does not load everywhere, so it is only the
    // fallback — a blank tile in the cart is worse than a photo of the same
    // product in another colour.
    final image =
        product.mainImage ?? detail.gallery.firstOrNull ?? variant?.image;
    return ProductCardData(
      id: slug,
      slug: slug,
      apiId: product.id,
      hasVariants: product.hasVariants,
      title: product.name,
      price: variant?.price ?? product.price,
      oldPrice: variant?.oldPrice ?? product.oldPrice,
      images: image == null ? const [] : [image],
      specs: [if (variant != null && variant.label.isNotEmpty) variant.label],
    );
  }

  @override
  Widget build(BuildContext context) {
    // The pill sits clear of the nav bar rather than a fixed distance off the
    // screen edge, so it lands right on a home-indicator phone and on one
    // without alike.
    final summaryBottom = context.navBarHeight + CartPage._gap;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        _ensureLoaded(cart.quantities.keys);
        final lines = [
          for (final slug in cart.quantities.keys) ?_line(slug, cart),
        ];
        // Still fetching: the cart is not empty, so do not say it is.
        final loading =
            lines.isEmpty &&
            cart.quantities.isNotEmpty &&
            _failed.length < cart.quantities.length;

        return Scaffold(
          backgroundColor: AppColors.white,
          // Stays put while the list scrolls under it, so the count and the
          // "Select All" tick are always in reach.
          appBar: _CartAppBar(
            count: cart.lineCount,
            allSelected: cart.allSelected,
          ),
          body: cart.quantities.isEmpty
              ? const CartEmptyView()
              : loading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _retry,
                      child: ListView.separated(
                        // The last line scrolls out from under the pill instead
                        // of stopping behind it.
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.page,
                          0,
                          AppSpacing.page,
                          summaryBottom +
                              CartPage._summaryHeight +
                              CartPage._gap,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: lines.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppColors.grey100),
                        itemBuilder: (context, index) =>
                            _Line(product: lines[index], cart: cart),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.page,
                      right: AppSpacing.page,
                      bottom: summaryBottom,
                      child: _Summary(
                        cart: cart,
                        lines: lines,
                        summaryHeight: CartPage._summaryHeight,
                        gap: CartPage._gap,
                      ),
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
        // An empty cart has no count worth printing: just the heading.
        count == 0
            ? context.l10n.cartTitle
            : context.l10n.cartProductCount(count),
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
          before.contains(product.favoriteKey) !=
          after.contains(product.favoriteKey),
      builder: (context, favorites) => SwipeToDelete(
        onDelete: () => cubit.remove(product.id),
        child: CartLineTile(
          product: product,
          quantity: cart.quantityOf(product.id),
          selected: cart.isSelected(product.id),
          isFavorite: favorites.contains(product.favoriteKey),
          onIncrease: () => cubit.increase(product.id),
          onDecrease: () => cubit.decrease(product.id),
          onSelectedChanged: () => cubit.toggleSelected(product.id),
          onFavoriteTap: () =>
              context.read<FavoriteCubit>().toggle(product.favoriteKey),
        ),
      ),
    );
  }
}

/// The totals pill. Nothing ticked is nothing to order, so then it slips down
/// behind the navigation bar, and it rises out from behind it again as soon
/// as something is ticked.
class _Summary extends StatefulWidget {
  const _Summary({
    required this.cart,
    required this.lines,
    required this.summaryHeight,
    required this.gap,
  });

  final CartState cart;
  final List<ProductCardData> lines;
  final double summaryHeight;
  final double gap;

  @override
  State<_Summary> createState() => _SummaryState();
}

class _SummaryState extends State<_Summary> {
  /// What the pill last showed with something ticked. It keeps showing this
  /// on its way down, rather than flashing "0 Product" as it leaves.
  ({int count, double total, double oldTotal}) _shown = (
    count: 0,
    total: 0,
    oldTotal: 0,
  );

  bool _placing = false;

  /// What pressing the pill does: places the order for what is ticked and
  /// opens it.
  ///
  /// The name comes from the profile and the address from the saved default,
  /// so there is nothing to fill in. The ticked total goes along as the price
  /// the customer saw: if it has moved, or something has run out, the API
  /// refuses the order and the checkout page is opened to show why, rather
  /// than anything being placed at a price they did not agree to.
  Future<void> _placeOrder(BuildContext context) async {
    if (_placing) return;
    final cart = context.read<CartCubit>();
    final auth = context.read<AuthCubit>();
    final profile = context.read<ProfileCubit>().state;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (!auth.state.isAuthenticated) {
      if (!await promptSignIn(context) || !context.mounted) return;
    }

    final selected = [
      for (final line in widget.lines)
        if (widget.cart.isSelected(line.id) && line.apiId != null) line,
    ];
    if (selected.isEmpty) return;

    final orderLines = [
      for (final line in selected)
        PreOrderLine(
          productId: line.apiId!,
          quantity: widget.cart.quantityOf(line.id),
          variantId: widget.cart.variants[line.id],
        ),
    ];
    final expectedTotal = selected.fold<num>(
      0,
      (sum, line) => sum + line.price * widget.cart.quantityOf(line.id),
    );
    final name = profile.hasName ? profile.name : auth.state.user?.username;

    setState(() => _placing = true);
    // The order is placed with the supplier live, which takes a moment.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    String? address;
    try {
      final locations = await getIt<ShopApi>().locations();
      final home =
          locations.where((l) => l.isDefault).firstOrNull ??
          locations.firstOrNull;
      if (home != null) {
        address = [
          home.address,
          home.details,
        ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
      }
    } on Object {
      address = null; // The address is optional; the order goes without.
    }

    final result = await getIt<PreOrderRepository>().create(
      lines: orderLines,
      customerName: name,
      address: address,
      expectedTotal: expectedTotal,
    );

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _placing = false);

    final order = result.dataOrNull;
    if (order != null) {
      for (final line in selected) {
        cart.remove(line.id);
      }
      // The cart underneath, the order on top: back from the order lands on
      // the cart rather than leaving nothing to go back to.
      router.goNamed(AppRoutes.cart.name);
      unawaited(
        router.pushNamed(
          AppRoutes.orderDetail.name,
          pathParameters: {'id': order.id.toString()},
        ),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(result.failureOrNull?.message ?? '')),
    );
    unawaited(router.pushNamed(AppRoutes.checkout.name));
  }

  @override
  Widget build(BuildContext context) {
    var total = 0.0;
    var oldTotal = 0.0;
    var count = 0;

    for (final product in widget.lines) {
      if (!widget.cart.isSelected(product.id)) continue;
      final quantity = widget.cart.quantityOf(product.id);
      total += product.price * quantity;
      oldTotal += (product.oldPrice ?? product.price) * quantity;
      count++;
    }

    final visible = count > 0;
    if (visible) _shown = (count: count, total: total, oldTotal: oldTotal);

    // How far down it goes to be wholly out of sight: its own height, the gap
    // to the nav bar, and a little more so it sits inside the bar's capsule.
    final hiddenBy =
        (widget.summaryHeight + widget.gap + 3) / widget.summaryHeight;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 420),
        curve: visible ? Curves.easeOutCubic : Curves.easeInCubic,
        offset: Offset(0, visible ? 0 : hiddenBy),
        child: CartSummaryBar(
          productCount: _shown.count,
          total: _shown.total,
          oldTotal: _shown.oldTotal,
          onTap: visible ? () => _placeOrder(context) : null,
        ),
      ),
    );
  }
}
