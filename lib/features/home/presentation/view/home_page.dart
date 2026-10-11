import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../brand/domain/repositories/brand_repository.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../search/presentation/view/visual_search_page.dart';
import '../../../search/presentation/widgets/visual_search_source_sheet.dart';
import '../widgets/brand_strip.dart';
import '../widgets/category_strip.dart';
import '../widgets/home_header.dart';
import 'home_placeholder_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryItem> _categories = [];
  List<BrandItem> _brands = [];
  List<ProductCardData> _products = [];
  SavedLocation? _location;
  bool _loading = true;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = getIt<AuthCubit>().stream.listen((state) {
      if (state.isAuthenticated) {
        _loadLocation();
      } else if (mounted) {
        setState(() => _location = null);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    if (!getIt<AuthCubit>().state.isAuthenticated) return;
    try {
      final locations = await getIt<ShopApi>().locations();
      if (mounted &&
          getIt<AuthCubit>().state.isAuthenticated &&
          locations.isNotEmpty) {
        setState(() => _location = locations.first);
      }
    } on Object {
      /* Location is optional on the home screen. */
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final categoryResult = await getIt<CategoryRepository>().tree();
    final brandResult = await getIt<BrandRepository>().list();
    final productResult = await getIt<ProductRepository>().list(
      query: const ProductQuery(onlyFeatured: true),
      page: 1,
      size: 20,
    );
    if (!mounted) return;
    setState(() {
      _categories = [
        for (final item in categoryResult.dataOrNull ?? [])
          CategoryItem(
            id: item.slug,
            name: item.name,
            imageUrl: item.imageSmall ?? item.imageLarge,
          ),
      ];
      _brands = [
        for (final item in brandResult.dataOrNull ?? [])
          BrandItem(id: item.slug, name: item.name, logoUrl: item.logo),
      ];
      _products = [
        for (final item in productResult.dataOrNull?.items ?? [])
          ProductCardData.fromProduct(item),
      ];
      _error =
          productResult.failureOrNull?.message ??
          categoryResult.failureOrNull?.message ??
          brandResult.failureOrNull?.message;
      _loading = false;
    });
    await _loadLocation();
  }

  Future<void> _pickLocation() async {
    if (!context.read<AuthCubit>().state.isAuthenticated) {
      await promptSignIn(context);
      return;
    }
    final List<SavedLocation> locations;
    try {
      locations = await getIt<ShopApi>().locations();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return;
    }
    if (!mounted) return;
    if (locations.isEmpty) {
      unawaited(context.pushNamed(AppRoutes.addresses.name));
      return;
    }
    final picked = await showModalBottomSheet<SavedLocation>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final location in locations)
              ListTile(
                title: Text(location.name),
                subtitle: Text(location.address ?? ''),
                onTap: () => Navigator.pop(context, location),
              ),
            ListTile(
              title: Text(context.l10n.profileSavedLocations),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(AppRoutes.addresses.name);
              },
            ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _location = picked);
  }

  Future<void> _searchByPhoto() async {
    final pageContext = context;
    final source = await VisualSearchSourceSheet.show(pageContext);
    if (source == null) return;
    if (!pageContext.mounted) return;
    final XFile? photo;
    if (source == VisualSearchSource.camera) {
      photo = await VisualSearchPage.open(pageContext);
    } else {
      photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
    }
    if (photo != null && pageContext.mounted) {
      AppSnackBar.show(
        pageContext,
        pageContext.l10n.visualSearchReady,
        overNavBar: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(
              marketplaces: HomePlaceholderData.marketplaces,
              categories: _categories,
              city: _location?.name ?? 'Ashgabat',
              address: _location?.address ?? '',
              onCategoryTap: (item) => context.pushNamed(
                AppRoutes.categoryDetail.name,
                pathParameters: {'id': item.id},
                extra: item.name,
              ),
              onLocationTap: _pickLocation,
              onCameraTap: _searchByPhoto,
              onMarketplaceTap: (item) => context.pushNamed(
                AppRoutes.marketplace.name,
                pathParameters: {'id': item.id},
                extra: item.name,
              ),
            ),
          ),
          if (_brands.isNotEmpty)
            SliverToBoxAdapter(
              child: BrandStrip(
                items: _brands,
                onTap: (item) => context.pushNamed(
                  AppRoutes.brand.name,
                  pathParameters: {'id': item.id},
                  extra: item.name,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          if (_loading && _products.isEmpty)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null && _products.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: TextButton(onPressed: _load, child: Text(_error!)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.xl,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = _products[index];
                  return BlocBuilder<FavoriteCubit, Set<String>>(
                    builder: (context, favorites) =>
                        BlocBuilder<CartCubit, CartState>(
                          builder: (context, cart) => ProductCard(
                            data: product,
                            isFavorite: favorites.contains(product.favoriteKey),
                            isInCart: cart.contains(product.id),
                            onTap: () => context.pushNamed(
                              AppRoutes.productDetail.name,
                              pathParameters: {'id': product.id},
                            ),
                            onFavoriteTap: () async {
                              if (!context
                                  .read<AuthCubit>()
                                  .state
                                  .isAuthenticated) {
                                await promptSignIn(context);
                                return;
                              }
                              if (context.mounted) {
                                await context.read<FavoriteCubit>().toggle(
                                  product.favoriteKey,
                                );
                              }
                            },
                            onAddToCart: () => product.hasVariants
                                ? context.pushNamed(
                                    AppRoutes.productDetail.name,
                                    pathParameters: {'id': product.id},
                                  )
                                : context.read<CartCubit>().toggle(product.id),
                          ),
                        ),
                  );
                }, childCount: _products.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    ),
  );
}
