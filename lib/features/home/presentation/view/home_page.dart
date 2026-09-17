import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../search/presentation/view/visual_search_page.dart';
import '../../../search/presentation/widgets/visual_search_source_sheet.dart';
import '../widgets/brand_strip.dart';
import '../widgets/category_strip.dart';
import '../widgets/home_header.dart';
import '../widgets/location_picker_dialog.dart';
import '../widgets/marketplace_strip.dart';
import '../widgets/promo_carousel.dart';
import 'home_placeholder_data.dart';

/// Home page layout. Content is passed in as plain lists, so wiring a
/// `HomeBloc` later means replacing [HomePlaceholderData] with state — no
/// layout changes.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DeliveryLocation _location = HomePlaceholderData.defaultLocation;

  Future<void> _pickLocation() async {
    final picked = await LocationPickerDialog.show(context, locations: HomePlaceholderData.locations, selectedId: _location.id);
    // The dialog is awaited, so the page may be gone by the time it closes.
    if (picked != null && mounted) setState(() => _location = picked);
  }

  /// Asks camera or gallery, then gets the photo. Feeding it to a
  /// visual-search request is the next step, once that endpoint exists —
  /// [photo] already carries the file to send.
  Future<void> _searchByPhoto() async {
    final source = await VisualSearchSourceSheet.show(context);
    if (source == null || !mounted) return;

    final XFile? photo;
    if (source == VisualSearchSource.camera) {
      photo = await VisualSearchPage.open(context);
    } else {
      photo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    }
    if (photo == null || !mounted) return;
    AppLogger.d('Visual search photo: ${photo.path}');
    // The home tab has the floating nav bar, so the toast sits above it.
    AppSnackBar.show(context, context.l10n.visualSearchReady, overNavBar: true);
  }

  void _openProduct(String id) => context.pushNamed(
    AppRoutes.productDetail.name,
    pathParameters: {'id': id},
  );

  void _openCategory(CategoryItem item) => context.pushNamed(AppRoutes.categoryDetail.name, pathParameters: {'id': item.id}, extra: item.name);

  void _openBrand(BrandItem item) => context.pushNamed(
    AppRoutes.brand.name,
    pathParameters: {'id': item.id},
    extra: item.name,
  );

  void _openMarketplace(MarketplaceItem item) => context.pushNamed(AppRoutes.marketplace.name, pathParameters: {'id': item.id}, extra: item.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(
              marketplaces: HomePlaceholderData.marketplaces,
              categories: HomePlaceholderData.categories,
              city: _location.city,
              address: _location.address,
              onCategoryTap: _openCategory,
              onLocationTap: _pickLocation,
              onCameraTap: _searchByPhoto,
              onMarketplaceTap: _openMarketplace,
            ),
          ),
          const SliverToBoxAdapter(child: PromoCarousel(banners: HomePlaceholderData.banners)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(
            child: BrandStrip(items: HomePlaceholderData.brands, onTap: _openBrand),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.xl,
                crossAxisSpacing: AppSpacing.md,
                // Image (square) + price + two title lines + button.
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = HomePlaceholderData.products[index];
                // Two small builders rather than one: a card rebuilds only
                // when its own flag flips, not on every list change.
                return BlocBuilder<FavoriteCubit, Set<String>>(
                  buildWhen: (before, after) =>
                      before.contains(product.id) != after.contains(product.id),
                  builder: (context, favorites) => BlocBuilder<CartCubit, CartState>(
                    buildWhen: (before, after) =>
                        before.contains(product.id) != after.contains(product.id),
                    builder: (context, cart) => ProductCard(
                      data: product,
                      onTap: () => _openProduct(product.id),
                      isFavorite: favorites.contains(product.id),
                      isInCart: cart.contains(product.id),
                      onFavoriteTap: () => context.read<FavoriteCubit>().toggle(product.id),
                      onAddToCart: () => context.read<CartCubit>().toggle(product.id),
                    ),
                  ),
                );
              }, childCount: HomePlaceholderData.products.length),
            ),
          ),
          // Clearance for the floating bottom navigation bar.
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
