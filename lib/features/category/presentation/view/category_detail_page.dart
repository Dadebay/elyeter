import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../brand/domain/entities/brand.dart';
import '../../../brand/domain/repositories/brand_repository.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/presentation/widgets/catalog_product_grid.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../widgets/category_brand_sheet.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/category_products_empty.dart';
import '../widgets/category_price_filter_sheet.dart';
import '../widgets/category_sort_sheet.dart';
import '../widgets/category_search_button.dart';
import '../widgets/category_search_results.dart';
import '../widgets/category_search_title.dart';
import '../widgets/subcategory_grid.dart';
import '../widgets/subcategory_header.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key, required this.id, this.title});
  final String id;
  final String? title;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  static const _brandFacetId = 'brand';

  Category? _category;
  bool _loadingCategory = true;
  ProductSort _sort = ProductSort.newest;
  num? _minPrice;
  num? _maxPrice;
  bool _onlyFeatured = false;
  List<Brand> _brands = const [];
  bool _brandsLoading = true;
  Set<String> _brandSlugs = const {};

  bool _searchOpen = false;
  String _search = '';
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _loadBrands();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CategoryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _category = null;
      _loadingCategory = true;
      _brandSlugs = const {};
      _loadCategory();
    }
  }

  Future<void> _loadCategory() async {
    final slug = widget.id;
    final repository = getIt<CategoryRepository>();
    final tree = await repository.tree();
    var category = _findCategory(tree.dataOrNull ?? const [], slug);
    category ??= (await repository.bySlug(slug)).dataOrNull;
    if (mounted && widget.id == slug) {
      setState(() {
        _category = category;
        _loadingCategory = false;
      });
    }
  }

  /// `GET /brands` is not paginated and not scoped to a category, so the
  /// list is fetched once. Without it the brand chip simply is not offered.
  Future<void> _loadBrands() async {
    final result = await getIt<BrandRepository>().list();
    if (!mounted) return;
    setState(() {
      _brands = result.dataOrNull ?? const [];
      _brandsLoading = false;
    });
  }

  void _toggleSearch() {
    if (_searchOpen) {
      _closeSearch();
      return;
    }
    setState(() => _searchOpen = true);
    // Held back until the pill has mostly grown, so the keyboard does not
    // fight the animation for the frame.
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (mounted && _searchOpen) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchDebounce?.cancel();
    _searchFocus.unfocus();
    _searchController.clear();
    setState(() {
      _searchOpen = false;
      _search = '';
    });
  }

  /// Waits for a pause in typing before asking the server again.
  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _applySearch(text),
    );
  }

  void _applySearch(String text) {
    _searchDebounce?.cancel();
    final trimmed = text.trim();
    if (mounted && trimmed != _search) setState(() => _search = trimmed);
  }

  ProductQuery _query({String? search}) => ProductQuery(
    categorySlug: widget.id,
    sort: _sort,
    brandSlugs: _brandSlugs.toList(),
    minPrice: _minPrice,
    maxPrice: _maxPrice,
    onlyFeatured: _onlyFeatured,
    search: search,
  );

  List<CategoryFacet> _facets(BuildContext context) => [
    if (_brands.isNotEmpty)
      CategoryFacet(
        id: _brandFacetId,
        // The chosen brand names itself on the chip.
        label: _brandFacetLabel(context),
        selectedCount: _brandSlugs.length,
      ),
  ];

  /// One brand names itself on the chip; several are counted by its badge.
  String _brandFacetLabel(BuildContext context) {
    if (_brandSlugs.length == 1) {
      for (final brand in _brands) {
        if (brand.slug == _brandSlugs.single) return brand.name;
      }
    }
    return context.l10n.categoryFilterBrand;
  }

  Future<void> _chooseBrand() async {
    final picked = await CategoryBrandSheet.show(
      context,
      brands: _brands,
      selectedSlugs: _brandSlugs,
    );
    if (picked != null && mounted) setState(() => _brandSlugs = picked);
  }

  Category? _findCategory(List<Category> nodes, String slug) {
    for (final node in nodes) {
      if (node.slug == slug) return node;
      final child = _findCategory(node.children, slug);
      if (child != null) return child;
    }
    return null;
  }

  bool get _filtersActive =>
      _brandSlugs.isNotEmpty ||
      _minPrice != null ||
      _maxPrice != null ||
      _onlyFeatured;

  Future<void> _chooseSort() async {
    final selected = await CategorySortSheet.show(context, current: _sort);
    if (selected != null && mounted) setState(() => _sort = selected);
  }

  Future<void> _chooseFilter() async {
    final selected = await CategoryPriceFilterSheet.show(
      context,
      min: _minPrice,
      max: _maxPrice,
      onlyFeatured: _onlyFeatured,
    );
    if (selected != null && mounted) {
      setState(() {
        _minPrice = selected.min;
        _maxPrice = selected.max;
        _onlyFeatured = selected.onlyFeatured;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;
    final children = category?.children ?? const <Category>[];
    // The header has to know its height up front to collapse smoothly: the
    // grid's own, plus the padding around it below.
    final subcategoriesExtent =
        SubcategoryGrid.heightFor(
          context,
          width: MediaQuery.sizeOf(context).width - 2 * AppSpacing.page,
          itemCount: children.length,
        ) +
        AppSpacing.md +
        AppSpacing.lg;
    final subcategories = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.lg,
      ),
      child: SubcategoryGrid(
        items: [
          for (final child in children)
            SubcategoryItem(
              id: child.slug,
              name: child.name,
              imageUrl: child.imageSmall ?? child.imageLarge,
            ),
        ],
        onTap: (child) => context.pushNamed(
          AppRoutes.categoryDetail.name,
          pathParameters: {'id': child.id},
          extra: child.name,
        ),
      ),
    );

    return PopScope(
      // Back first closes the search, and only then leaves the page.
      canPop: !_searchOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Scaffold(
        appBar: AppBar(
          // The back button makes way while searching, so the field can run
          // the full width of the bar, from the page inset to the close
          // button.
          leadingWidth: _searchOpen
              ? AppSpacing.page
              : AppBackButton.leadingWidth,
          leading: _searchOpen
              ? const SizedBox.shrink()
              : const AppBackButton.appBarLeading(),
          titleSpacing: 0,
          centerTitle: true,
          title: CategorySearchTitle(
            title: category?.name ?? widget.title ?? widget.id,
            open: _searchOpen,
            controller: _searchController,
            focusNode: _searchFocus,
            hint: context.l10n.categorySearch,
            onChanged: _onSearchChanged,
            onSubmitted: _applySearch,
          ),
          actions: [
            CategorySearchButton(
              tooltip: context.l10n.categorySearch,
              open: _searchOpen,
              onPressed: _toggleSearch,
            ),
          ],
        ),
        body: _loadingCategory
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // No glow, stretch or bounce on the page's own scrolling: they
                  // act on the whole nested view, so every fling at the end of
                  // the list made the pinned filter bar above it shudder.
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      overscroll: false,
                      physics: const ClampingScrollPhysics(),
                    ),
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        if (children.isNotEmpty)
                          SliverPersistentHeader(
                            delegate: SubcategoryHeaderDelegate(
                              extent: subcategoriesExtent,
                              child: subcategories,
                            ),
                          ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _FilterHeaderDelegate(
                            onSort: _chooseSort,
                            onFilter: _chooseFilter,
                            sortActive: _sort != ProductSort.newest,
                            filterActive:
                                _minPrice != null ||
                                _maxPrice != null ||
                                _onlyFeatured,
                            facets: _facets(context),
                            facetsLoading: _brandsLoading,
                            onFacetTap: (_) => _chooseBrand(),
                          ),
                        ),
                      ],
                      body: CatalogProductGrid(
                        query: _query(),
                        pageSize: 10,
                        emptyState: CategoryProductsEmpty(
                          filtered: _filtersActive,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CategorySearchResults(
                      open: _searchOpen,
                      // Scrolling the results puts the keyboard away.
                      child: NotificationListener<ScrollStartNotification>(
                        onNotification: (_) {
                          _searchFocus.unfocus();
                          return false;
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: CategoryFilterBar(
                                facets: _facets(context),
                                loading: _brandsLoading,
                                onSort: _chooseSort,
                                onFilter: _chooseFilter,
                                onFacetTap: (_) => _chooseBrand(),
                                sortActive: _sort != ProductSort.newest,
                                filterActive:
                                    _minPrice != null ||
                                    _maxPrice != null ||
                                    _onlyFeatured,
                              ),
                            ),
                            Expanded(
                              child: CatalogProductGrid(
                                query: _query(search: _search),
                                pageSize: 10,
                                emptyState: CategoryProductsEmpty(
                                  filtered:
                                      _filtersActive || _search.isNotEmpty,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({
    required this.onSort,
    required this.onFilter,
    required this.onFacetTap,
    required this.facets,
    required this.sortActive,
    required this.filterActive,
    required this.facetsLoading,
  });

  final VoidCallback onSort;
  final VoidCallback onFilter;
  final ValueChanged<CategoryFacet> onFacetTap;
  final List<CategoryFacet> facets;
  final bool sortActive;
  final bool filterActive;
  final bool facetsLoading;

  @override
  double get minExtent => CategoryFilterBar.height + AppSpacing.xxl;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: CategoryFilterBar(
          facets: facets,
          loading: facetsLoading,
          onSort: onSort,
          onFilter: onFilter,
          onFacetTap: onFacetTap,
          sortActive: sortActive,
          filterActive: filterActive,
        ),
      ),
    );
  }

  @override
  // The chips' state lives in the page, so any rebuild of it may change them.
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
}
