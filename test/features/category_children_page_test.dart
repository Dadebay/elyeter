import 'dart:async';

import 'package:elyeter/app/router/app_routes.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/category/data/models/category_model.dart';
import 'package:elyeter/features/category/domain/entities/category.dart';
import 'package:elyeter/features/category/domain/repositories/category_repository.dart';
import 'package:elyeter/features/category/presentation/view/category_detail_page.dart';
import 'package:elyeter/features/category/presentation/widgets/category_filter_bar.dart';
import 'package:elyeter/features/category/presentation/widgets/category_products_empty.dart';
import 'package:elyeter/features/category/presentation/widgets/category_search_button.dart';
import 'package:elyeter/features/category/presentation/widgets/subcategory_grid.dart';
import 'package:elyeter/features/brand/domain/entities/brand.dart';
import 'package:elyeter/features/brand/domain/repositories/brand_repository.dart';
import 'package:elyeter/features/product/domain/entities/product.dart';
import 'package:elyeter/features/product/domain/entities/product_query.dart';
import 'package:elyeter/features/product/domain/repositories/product_repository.dart';
import 'package:elyeter/features/product/presentation/widgets/catalog_product_grid.dart';
import 'package:elyeter/features/search/presentation/widgets/search_reveal_transition.dart';
import 'package:elyeter/features/product/presentation/widgets/product_grid_shimmer.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _CategoryRepository implements CategoryRepository {
  _CategoryRepository(this.category);

  final Category category;

  @override
  Future<Result<List<Category>>> tree({
    bool featuredOnly = false,
    bool forceRefresh = false,
  }) async => Success([category]);

  @override
  Future<Result<Category>> byId(int id) async => Success(category);
}

class _ProductRepository implements ProductRepository {
  ProductQuery? lastQuery;
  Completer<void>? ready;

  @override
  Future<Result<Paginated<Product>>> list({
    required ProductQuery query,
    int page = 1,
    int size = 20,
  }) async {
    lastQuery = query;
    await ready?.future;
    return Success(Paginated(items: const [], totalCount: 0, page: page));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BrandRepository implements BrandRepository {
  @override
  Future<Result<List<Brand>>> list({
    String? search,
    bool featuredOnly = false,
  }) async => Success(const []);

  @override
  Future<Result<Brand>> byId(int id) => throw UnimplementedError();
}

void main() {
  setUp(() => getIt.registerSingleton<BrandRepository>(_BrandRepository()));
  tearDown(() async => getIt.reset());

  testWidgets('category tree children appear and open their own category', (
    tester,
  ) async {
    final category = CategoryModel.fromJson({
      'id': 1,
      'name': 'Electronics',
      'slug': 'elektronika',
      'products_count': 0,
      'children': [
        {
          'id': 2,
          'name': 'Smartphones',
          'slug': 'telefony',
          'products_count': 0,
          'children': [
            {'id': 33, 'name': 'Phone cases', 'slug': 'phone-cases'},
          ],
        },
      ],
    });
    expect(category.children.single.children.single.slug, 'phone-cases');
    getIt.registerSingleton<CategoryRepository>(_CategoryRepository(category));
    final ready = Completer<void>();
    getIt.registerSingleton<ProductRepository>(
      _ProductRepository()..ready = ready,
    );
    final router = GoRouter(
      initialLocation: '/category/elektronika',
      routes: [
        GoRoute(
          path: '/category/:id',
          name: AppRoutes.categoryDetail.name,
          builder: (context, state) =>
              state.pathParameters['id'] == 'elektronika'
              ? const CategoryDetailPage(id: 'elektronika')
              : Scaffold(body: Text('Opened ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(ProductGridShimmer), findsOneWidget);
    ready.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ProductGridShimmer), findsNothing);

    expect(find.text('Electronics'), findsOneWidget);
    expect(find.byType(SubcategoryGrid), findsOneWidget);
    expect(find.text('Smartphones'), findsOneWidget);
    expect(find.byType(CatalogProductGrid), findsOneWidget);
    expect(find.byType(CategoryProductsEmpty), findsOneWidget);
    expect(find.text('No products yet'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(CategoryFilterBar)).dy,
      greaterThan(tester.getBottomLeft(find.byType(SubcategoryGrid)).dy),
    );

    await tester.tap(find.text('Smartphones'));
    await tester.pumpAndSettle();
    expect(find.text('Opened telefony'), findsOneWidget);
  });

  testWidgets('parent shows descendant products even with zero direct count', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final category = CategoryModel.fromJson({
      'id': 18,
      'name': 'Gözellik we saglyk',
      'slug': 'krasota-i-zdorove',
      'products_count': 0,
      'children': [
        {
          'id': 20,
          'name': 'Dekoratiw kosmetika',
          'slug': 'kosmetika',
          'products_count': 108,
          'children': [],
        },
      ],
    });
    final products = _ProductRepository();
    getIt.registerSingleton<CategoryRepository>(_CategoryRepository(category));
    getIt.registerSingleton<ProductRepository>(products);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CategoryDetailPage(id: 'krasota-i-zdorove'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dekoratiw kosmetika'), findsOneWidget);
    expect(find.byType(CatalogProductGrid), findsOneWidget);
    expect(products.lastQuery?.categoryId, 18);
    expect(
      products.lastQuery?.toQueryParameters(page: 1, size: 10),
      containsPair('category_id', 18),
    );
    expect(
      tester.getTopLeft(find.byType(CategoryFilterBar)).dy,
      greaterThan(tester.getBottomLeft(find.byType(SubcategoryGrid)).dy),
    );

    await tester.drag(find.byType(CatalogProductGrid), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.byType(SubcategoryGrid), findsNothing);
    expect(
      tester.getTopLeft(find.byType(CategoryFilterBar)).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(find.byType(AppBar)).dy),
    );
  });

  testWidgets('leaf places filters under the title and opens search', (
    tester,
  ) async {
    final category = CategoryModel.fromJson({
      'id': 20,
      'name': 'Dekoratiw kosmetika',
      'slug': 'kosmetika',
      'products_count': 0,
      'children': [],
    });
    getIt.registerSingleton<CategoryRepository>(_CategoryRepository(category));
    final products = _ProductRepository();
    getIt.registerSingleton<ProductRepository>(products);
    Rect? searchOrigin;
    final router = GoRouter(
      initialLocation: '/category/kosmetika',
      routes: [
        GoRoute(
          path: '/category/:id',
          name: AppRoutes.categoryDetail.name,
          builder: (context, state) =>
              const CategoryDetailPage(id: 'kosmetika'),
        ),
        GoRoute(
          path: '/search',
          name: AppRoutes.search.name,
          builder: (context, state) {
            searchOrigin = (state.extra as SearchButtonOrigin).bounds;
            return const Scaffold(body: Text('Search opened'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SubcategoryGrid), findsNothing);
    expect(find.byType(CategoryFilterBar), findsOneWidget);
    expect(find.text('No products yet'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(CategoryFilterBar)).dy, lessThan(130));

    Finder filterControls() => find.descendant(
      of: find.byType(CategoryFilterBar),
      matching: find.byType(InkWell),
    );
    await tester.tap(filterControls().first);
    await tester.pumpAndSettle();
    final priceFields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(priceFields.first, '50');
    await tester.enterText(priceFields.last, '100');
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(products.lastQuery?.minPrice, 50);
    expect(products.lastQuery?.maxPrice, 100);
    expect(find.text('Nothing matches these filters'), findsOneWidget);

    await tester.tap(filterControls().first);
    await tester.pumpAndSettle();
    expect(
      tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
      isFalse,
    );
    await tester.tap(find.text('Featured products only'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
      isTrue,
    );
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(products.lastQuery?.onlyFeatured, isTrue);
    expect(
      products.lastQuery?.toQueryParameters(page: 1, size: 20)['only_featured'],
      isTrue,
    );

    await tester.tap(filterControls().at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Popular'));
    await tester.pumpAndSettle();
    expect(products.lastQuery?.sort, ProductSort.popular);

    final searchButton = find.descendant(
      of: find.byType(CategorySearchButton),
      matching: find.byType(InkWell),
    );
    final buttonBounds = tester.getRect(searchButton);
    await tester.tap(searchButton);
    await tester.pumpAndSettle();
    expect(find.text('Search opened'), findsOneWidget);
    expect(searchOrigin, buttonBounds);
  });
}
