import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_repository.dart';
import '../model/variant_options.dart';
import '../widgets/expandable_product_name.dart';
import '../widgets/product_app_bar_actions.dart';
import '../widgets/product_detail_sections.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_option_picker.dart';

/// A product's own page: photos, options, price, article, description and
/// specification, with a sticky add-to-cart button.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  /// The API uses a slug, despite the historical route parameter name.
  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  /// Clearance for the sticky button at the foot of the page.
  static const _bottomInset = 104.0;

  late Future<Result<ProductDetail>> _future;

  /// The variant the customer is looking at. Set once the product arrives:
  /// the one already in their cart if there is one, else the first in stock.
  ProductVariant? _variant;
  bool _variantChosen = false;

  @override
  void initState() {
    super.initState();
    _future = getIt<ProductRepository>().bySlug(widget.productId);
  }

  void _retry() => setState(() {
    _variantChosen = false;
    _future = getIt<ProductRepository>().bySlug(widget.productId);
  });

  void _pick(VariantOptions options, String name, String value) {
    final next = options.pick(name, value, _variant);
    if (next == null) return;
    setState(() => _variant = next);
    // A product already in the cart follows the choice; one that is not has
    // nothing to update, and must not leave a variant behind for later.
    final cart = context.read<CartCubit>();
    if (cart.contains(widget.productId)) {
      cart.setVariant(widget.productId, next.id);
    }
  }

  void _toggleCart() {
    final cart = context.read<CartCubit>();
    final variant = _variant;
    if (variant != null && !cart.contains(widget.productId)) {
      cart.setVariant(widget.productId, variant.id);
    }
    cart.toggle(widget.productId);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Result<ProductDetail>>(
    future: _future,
    builder: (context, snapshot) {
      final detail = snapshot.data?.dataOrNull;
      if (detail == null) {
        return _Placeholder(snapshot: snapshot, onRetry: _retry);
      }

      final options = VariantOptions(detail.variants);
      if (!_variantChosen) {
        _variantChosen = true;
        _variant = options.initial(
          preferredId: context
              .read<CartCubit>()
              .state
              .variants[widget.productId],
        );
      }

      final product = detail.product;
      final variant = _variant;
      final slug = product.slug;

      return Scaffold(
        // White page, tinted blocks — the inverse of the app's other
        // screens, which is what the design does here.
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: AppBackButton.leadingWidth,
          leading: const AppBackButton.appBarLeading(icon: AppIcons.back),
          actions: [
            BlocBuilder<FavoriteCubit, Set<String>>(
              builder: (context, favorites) => ProductAppBarActions(
                favorite: favorites.contains(product.id.toString()),
                onShare: () => SharePlus.instance.share(
                  ShareParams(text: '${product.name} · ${product.sku}'),
                ),
                onFavorite: () async {
                  if (!context.read<AuthCubit>().state.isAuthenticated) {
                    await promptSignIn(context);
                    return;
                  }
                  if (context.mounted) {
                    await context.read<FavoriteCubit>().toggle(
                      product.id.toString(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              // No horizontal padding: the gallery runs edge to edge and
              // carries its own card margin. Everything after it is padded
              // as a block.
              padding: const EdgeInsets.only(top: 16, bottom: _bottomInset),
              children: [
                ProductGallery(
                  images: detail.gallery,
                  focusImage: variant?.image,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      ExpandableProductName(
                        name: product.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.black),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ProductRatingRow(
                        rating: product.rating,
                        orderCount: product.ordersCount,
                      ),
                      for (final name in options.names)
                        if (options.valuesOf(name).length > 1) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _OptionRow(
                            name: name,
                            options: options,
                            variant: variant,
                            onPick: (value) => _pick(options, name, value),
                          ),
                        ],
                      const SizedBox(height: AppSpacing.xl),
                      // From here down the page is a stack of grey cards on
                      // the white background, so the gaps are card spacing.
                      ProductPriceCard(
                        price: variant?.price ?? product.price,
                        oldPrice: variant?.oldPrice ?? product.oldPrice,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ProductArticleCard(article: variant?.sku ?? product.sku),
                      if (ProductDescriptionCard.plainText(
                        detail.description ?? '',
                      ).isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        ProductDescriptionCard(
                          description: detail.description!,
                        ),
                      ],
                      if (detail.attributes.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        ProductCharacteristicsCard(
                          attributes: detail.attributes,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: AppSpacing.page,
              right: AppSpacing.page,
              bottom: AppSpacing.lg,
              child: BlocBuilder<CartCubit, CartState>(
                buildWhen: (before, after) =>
                    before.contains(slug) != after.contains(slug),
                builder: (context, cart) => ProductStickyAddToCart(
                  added: cart.contains(slug),
                  // A sold-out variant cannot be added, only taken out again.
                  enabled:
                      variant == null || variant.inStock || cart.contains(slug),
                  onTap: _toggleCart,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// One row of options — colour as photos, anything else as chips — with the
/// chosen value named underneath.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.name,
    required this.options,
    required this.variant,
    required this.onPick,
  });

  final String name;
  final VariantOptions options;
  final ProductVariant? variant;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final values = options.valuesOf(name);
    final selected = options.valueOf(variant, name);
    final unavailable = {
      for (var i = 0; i < values.length; i++)
        if (!options.isAvailable(name, values[i])) i,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (options.isVisual(name))
          ProductColorPicker(
            images: [for (final v in values) options.imageOf(name, v)!],
            selected: values.indexOf(selected ?? ''),
            unavailable: unavailable,
            onSelected: (index) => onPick(values[index]),
          )
        else
          ProductSizePicker(
            sizes: values,
            selected: selected ?? '',
            unavailable: {for (final i in unavailable) values[i]},
            onSelected: onPick,
          ),
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ProductOptionLabel('$name: $selected'),
        ],
      ],
    );
  }
}

/// Loading, or the error with a way to retry, before there is a product.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.snapshot, required this.onRetry});

  final AsyncSnapshot<Result<ProductDetail>> snapshot;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: AppBackButton.leadingWidth,
        leading: const AppBackButton.appBarLeading(icon: AppIcons.back),
      ),
      body: Center(
        child: snapshot.connectionState != ConnectionState.done
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: onRetry,
                child: Text(snapshot.data?.failureOrNull?.message ?? 'Retry'),
              ),
      ),
    );
  }
}
