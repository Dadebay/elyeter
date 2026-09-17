import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../model/category_filters.dart';
import '../widgets/category_facet_sheet.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/category_filter_sheet.dart';
import '../widgets/category_sort_sheet.dart';
import '../widgets/subcategory_grid.dart';
import 'category_placeholder_data.dart';

/// One category: its subcategories across the top, the facets that narrow it,
/// then everything it lists.
class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key, required this.id, this.title});

  /// Slug from the route, e.g. `makeup`.
  final String id;

  /// Display name passed by the caller; falls back to [id].
  final String? title;

  /// Clearance for the floating navigation bar.
  static const _bottomInset = 120.0;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  CategoryFilters _filters = const CategoryFilters();

  Future<void> _openFilters(List<FacetDefinition> facets) async {
    final picked = await CategoryFilterSheet.show(
      context,
      facets: facets,
      filters: _filters,
    );
    if (picked != null) setState(() => _filters = picked);
  }

  Future<void> _openSort() async {
    final picked = await CategorySortSheet.show(context, current: _filters.sort);
    if (picked != null) setState(() => _filters = _filters.withSort(picked));
  }

  Future<void> _openFacet(FacetDefinition facet) async {
    final picked = await CategoryFacetSheet.show(
      context,
      facet: facet,
      selected: _filters.selected(facet.id),
    );
    if (picked != null) {
      setState(() => _filters = _filters.withFacet(facet.id, picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all = CategoryPlaceholderData.products;
    final products = _filters.apply(all);
    final subcategories = CategoryPlaceholderData.subcategoriesFor(widget.id);

    // Built from the whole list, not the filtered one: options must not
    // vanish as soon as they are used, or a filter cannot be widened again.
    final facets = CategoryFacets.of(
      all,
      brandLabel: l10n.categoryFilterBrand,
      materialLabel: l10n.categoryFilterMaterial,
      colorLabel: l10n.categoryFilterColor,
    );

    return Scaffold(
      // White, not the page grey: the subcategory artwork carries a grey
      // plate of exactly that shade, which would vanish into it.
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: AppBackButton.leadingWidth,
        leading: const AppBackButton.appBarLeading(),
        title: Text(widget.title ?? widget.id),
        actions: [
          _SearchButton(onTap: () => context.pushNamed(AppRoutes.search.name)),
          const SizedBox(width: AppSpacing.page),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Left out entirely rather than built empty: an empty box still
          // carries its padding, and the filters would sit in a gap.
          if (subcategories.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: SubcategoryGrid(
                  items: subcategories,
                  onTap: (item) => context.pushNamed(
                    AppRoutes.categoryDetail.name,
                    pathParameters: {'id': item.id},
                    queryParameters: {'title': item.name},
                  ),
                ),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(
            child: CategoryFilterBar(
              facets: [
                for (final facet in facets)
                  CategoryFacet(
                    id: facet.id,
                    label: facet.label,
                    selectedCount: _filters.countFor(facet.id),
                  ),
              ],
              onFilter: () => _openFilters(facets),
              onSort: _openSort,
              onFacetTap: (chip) => _openFacet(
                facets.firstWhere((facet) => facet.id == chip.id),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          if (products.isEmpty)
            SliverToBoxAdapter(child: _NoResults(l10n: l10n))
          else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.xl,
                crossAxisSpacing: AppSpacing.md,
                // Image (square) + price + two title lines + button, as the
                // home grid sizes it.
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _Card(product: products[index]),
                childCount: products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: CategoryDetailPage._bottomInset),
          ),
        ],
      ),
    );
  }
}

/// Shown when the filters leave nothing — with the reason, so the customer
/// knows it is their own narrowing rather than an empty category.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxxl,
        AppSpacing.xxxl,
        AppSpacing.xxxl,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.filter_alt_off_outlined,
            size: 44,
            color: AppColors.grey300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.categoryNoResults,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.categoryNoResultsHint,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

/// The app bar's search control, drawn to match the back button opposite it:
/// the same stadium, footprint, lift and dark-mode behaviour.
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        // The shadow only reads on a light page; on a dark one it is a
        // smudge, which is why the back button drops it too.
        boxShadow: isDark ? null : AppBackButton.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: AppBackButton.defaultWidth,
            height: AppBackButton.height,
            child: Center(
              child: SvgPicture.asset(
                AppAssets.iconSearch,
                width: AppBackButton.iconSize,
                height: AppBackButton.iconSize,
                colorFilter: ColorFilter.mode(
                  isDark ? AppColors.white : AppColors.ink,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A catalogue tile that keeps its own favourite and cart state in step.
class _Card extends StatelessWidget {
  const _Card({required this.product});

  final ProductCardData product;

  @override
  Widget build(BuildContext context) {
    // Two small builders rather than one: a card rebuilds only when its own
    // flag flips, not on every list change.
    return BlocBuilder<FavoriteCubit, Set<String>>(
      buildWhen: (before, after) =>
          before.contains(product.id) != after.contains(product.id),
      builder: (context, favorites) => BlocBuilder<CartCubit, CartState>(
        buildWhen: (before, after) =>
            before.contains(product.id) != after.contains(product.id),
        builder: (context, cart) => ProductCard(
          data: product,
          isFavorite: favorites.contains(product.id),
          isInCart: cart.contains(product.id),
          onTap: () => context.pushNamed(
            AppRoutes.productDetail.name,
            pathParameters: {'id': product.id},
          ),
          onFavoriteTap: () => context.read<FavoriteCubit>().toggle(product.id),
          onAddToCart: () => context.read<CartCubit>().toggle(product.id),
        ),
      ),
    );
  }
}
