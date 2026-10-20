import 'dart:async';

import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/failure.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elyeter/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:elyeter/features/product/domain/entities/product.dart';
import 'package:elyeter/features/product/domain/entities/product_detail.dart';
import 'package:elyeter/features/product/domain/entities/product_query.dart';
import 'package:elyeter/features/product/domain/repositories/product_repository.dart';
import 'package:elyeter/features/product/presentation/widgets/catalog_product_grid.dart';
import 'package:elyeter/features/product/presentation/widgets/product_card.dart';
import 'package:elyeter/features/product/presentation/widgets/product_grid_shimmer.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _MemoryStorage implements Storage {
  final Map<String, dynamic> values = {};

  @override
  dynamic read(String key) => values[key];

  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> close() async {}
}

class _Products implements ProductRepository {
  final requests = <(int, int)>[];
  final firstPageReady = Completer<void>();
  final secondPageReady = Completer<void>();
  Completer<Result<Paginated<Product>>>? refreshResult;
  final products = [
    for (var id = 1; id <= 25; id++)
      Product(
        id: id,
        slug: 'product-$id',
        sku: 'P$id',
        name: 'Product $id',
        price: id,
      ),
  ];

  @override
  Future<Result<Paginated<Product>>> list({
    required ProductQuery query,
    int page = 1,
    int size = 20,
  }) async {
    requests.add((page, size));
    if (page == 1 && refreshResult != null) return refreshResult!.future;
    if (page == 1) await firstPageReady.future;
    if (page == 2) await secondPageReady.future;
    final start = (page - 1) * size;
    return Success(
      Paginated(
        items: products.skip(start).take(size).toList(),
        totalCount: products.length,
        page: page,
      ),
    );
  }

  @override
  Future<Result<ProductDetail>> byId(int id) async => Success(
    ProductDetail(product: products.firstWhere((item) => item.id == id)),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());
  tearDown(() async => getIt.reset());

  for (final fail in [false, true]) {
    testWidgets('refresh replaces cards with shimmer, failure=$fail', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final products = _Products()..firstPageReady.complete();
      getIt.registerSingleton<ProductRepository>(products);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => FavoriteCubit()),
            BlocProvider(create: (_) => CartCubit()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: NestedScrollView(
                headerSliverBuilder: (_, _) => const [
                  SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
                body: const CatalogProductGrid(
                  query: ProductQuery(categoryId: 108),
                  pageSize: 10,
                  loadingState: ProductGridShimmer(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Product 1'), findsOneWidget);
      final refresh = Completer<Result<Paginated<Product>>>();
      products.refreshResult = refresh;

      await tester.drag(
        find.descendant(
          of: find.byType(CatalogProductGrid),
          matching: find.byType(CustomScrollView),
        ),
        const Offset(0, 400),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(products.requests, [(1, 10), (1, 10)]);
      expect(find.byType(ProductGridShimmer), findsOneWidget);
      expect(find.byType(ProductCard), findsNothing);

      refresh.complete(
        fail
            ? const Error(NetworkFailure())
            : Success(
                Paginated(
                  items: products.products.take(10).toList(),
                  totalCount: products.products.length,
                  page: 1,
                ),
              ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProductGridShimmer), findsNothing);
      expect(find.text('Product 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('loads pages while scrolling without a More button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final products = _Products();
    getIt.registerSingleton<ProductRepository>(products);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => FavoriteCubit()),
          BlocProvider(create: (_) => CartCubit()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: CatalogProductGrid(
              query: ProductQuery(categoryId: 18),
              pageSize: 10,
              loadingState: ProductGridShimmer(),
              loadingMoreState: ProductGridShimmer.more(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ProductGridShimmer), findsOneWidget);
    products.firstPageReady.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ProductGridShimmer), findsNothing);
    expect(products.requests, [(1, 10)]);
    expect(find.text('More'), findsNothing);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(products.requests, [(1, 10), (2, 10)]);
    await tester.scrollUntilVisible(
      find.byType(ProductGridShimmer),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(ProductGridShimmer), findsOneWidget);
    products.secondPageReady.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ProductGridShimmer), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Product 15'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(products.requests, [(1, 10), (2, 10), (3, 10)]);
    expect(find.text('More'), findsNothing);
  });
}
