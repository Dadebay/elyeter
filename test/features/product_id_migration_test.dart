import 'dart:async';

import 'package:dio/dio.dart';
import 'package:elyeter/app/router/app_router.dart';
import 'package:elyeter/app/router/app_routes.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/exceptions.dart';
import 'package:elyeter/core/error/failure.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elyeter/features/cart/presentation/view/cart_page.dart';
import 'package:elyeter/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elyeter/features/notification/presentation/services/notification_navigation.dart';
import 'package:elyeter/features/order/domain/entities/pre_order.dart';
import 'package:elyeter/features/order/presentation/model/order_detail_data.dart';
import 'package:elyeter/features/order/presentation/widgets/order_items_sheet.dart';
import 'package:elyeter/features/product/data/datasources/product_remote_data_source.dart';
import 'package:elyeter/features/product/data/repositories/product_repository_impl.dart';
import 'package:elyeter/features/product/domain/entities/product_id.dart';
import 'package:elyeter/features/product/domain/repositories/product_repository.dart';
import 'package:elyeter/features/product/presentation/widgets/product_card.dart';
import 'package:elyeter/features/product/presentation/widgets/product_photos.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _Storage implements Storage {
  final values = <String, dynamic>{};
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

class _Client extends ApiClient {
  _Client() : super(Dio());
  final requests = <String>[];
  final pages = <int, List<Map<String, dynamic>>>{};
  final responses = <String, dynamic>{};
  int total = 1;
  bool offline = false;
  Completer<void>? gate;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    requests.add(path);
    if (gate != null) await gate!.future;
    if (offline) throw const NetworkException();
    if (path == '/products') {
      expect(queryParameters?['size'], 100);
      final page = queryParameters!['page'] as int;
      return {'items': pages[page] ?? [], 'page': page, 'totalCount': total};
    }
    final response = responses[path];
    if (response is AppException) throw response;
    if (response == null) throw StateError('Unexpected request: $path');
    return response;
  }
}

Map<String, dynamic> _product(int id, String slug) => {
  'id': id,
  'slug': slug,
  'name': 'Product $id',
  'price': 20,
  'sku': 'SKU$id',
};

ProductRepository _repository(_Client client) =>
    ProductRepositoryImpl(ProductRemoteDataSourceImpl(client));

CartCubit _oldCart(_Storage storage, {String slug = 'old-product'}) {
  storage.values['CartCubit'] = {
    'quantities': {slug: 3},
    'variants': {slug: 91},
    'deselected': [slug],
    'seeded': true,
  };
  return CartCubit();
}

void main() {
  late _Storage storage;
  setUp(() {
    storage = _Storage();
    HydratedBloc.storage = storage;
  });
  tearDown(() async => getIt.reset());

  test(
    'details, card routes, photos and variants use ID, not response slug',
    () async {
      final client = _Client()
        ..responses['/products/1234'] = {
          ..._product(1234, 'a-completely-different-slug'),
          'images': [
            {
              'id': 1,
              'url': 'https://example.com/product.jpg',
              'is_main': true,
            },
          ],
        }
        ..responses['/products/1234/variants'] = [];
      final repository = _repository(client);
      getIt.registerSingleton<ProductRepository>(repository);
      final detail = (await repository.byId(1234)).dataOrNull!;
      final card = ProductCardData.fromProduct(detail.product);
      expect(card.id, '1234');
      expect(card.favoriteKey, '1234');
      expect(card.apiId, 1234);
      final photos = await Future.wait([
        ProductPhotos.load(1234),
        ProductPhotos.load(1234),
      ]);
      expect(photos.first, ['https://example.com/product.jpg']);
      expect(ProductPhotos.cached(1234), photos.first);
      await repository.variants(1234);
      expect(client.requests, [
        '/products/1234',
        '/products/1234',
        '/products/1234/variants',
      ]);
    },
  );

  test('unknown or inactive ID still produces a not-found result', () async {
    final client = _Client()
      ..responses['/products/404'] = const NotFoundException('Not found');
    final result = await _repository(client).byId(404);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('only positive decimal product IDs pass the route boundary', () {
    expect(ProductId.tryParse('1234'), 1234);
    expect(ProductId.tryParse('001234'), 1234);
    for (final target in [
      null,
      '',
      'old-slug',
      '12abc',
      '1.5',
      '+12',
      '-12',
      ' 12',
      '12\n',
      '0',
      '999999999999999999999999',
    ]) {
      expect(ProductId.tryParse(target), isNull, reason: '$target');
    }
  });

  test(
    'old cart migrates quantities, variants and deselection across pages',
    () async {
      final cubit = _oldCart(storage);
      final client = _Client()
        ..total = 101
        ..pages[1] = [_product(9, 'different')]
        ..pages[2] = [_product(1234, 'old-product')];
      await cubit.migrateLegacyProducts(_repository(client));
      expect(client.requests, ['/products', '/products']);
      expect(cubit.state.quantities, {'1234': 3});
      expect(cubit.state.variants, {'1234': 91});
      expect(cubit.state.deselected, {'1234'});
      final saved = cubit.toJson(cubit.state)!;
      expect(saved['version'], 2);
      expect(cubit.fromJson(saved), cubit.state);
      await cubit.migrateLegacyProducts(_repository(client));
      expect(client.requests.length, 2);
      await cubit.close();
    },
  );

  test(
    'numeric legacy slug is resolved rather than mistaken for an ID',
    () async {
      final cubit = _oldCart(storage, slug: '1234');
      cubit.setQuantity(
        '1234',
        2,
      ); // A new product with ID 1234 is a distinct line.
      final client = _Client()..pages[1] = [_product(55, '1234')];
      await cubit.migrateLegacyProducts(_repository(client));
      expect(cubit.state.quantities, {'1234': 2, '55': 3});
      expect(cubit.state.variants, {'55': 91});
      await cubit.close();
    },
  );

  test(
    'offline and missing legacy products survive retries and restart',
    () async {
      final cubit = _oldCart(storage);
      final client = _Client()..offline = true;
      await cubit.migrateLegacyProducts(_repository(client));
      final persisted = cubit.toJson(cubit.state)!;
      expect(cubit.fromJson(persisted), cubit.state);
      expect(cubit.state.quantities.values.single, 3);
      client.offline = false;
      await cubit.migrateLegacyProducts(_repository(client));
      expect(cubit.toJson(cubit.state), persisted);
      client.pages[1] = [_product(1234, 'old-product')];
      await cubit.migrateLegacyProducts(_repository(client));
      expect(cubit.state.quantities, {'1234': 3});
      await cubit.close();
    },
  );

  test(
    'merges a new ID line once and keeps its current variant and selection',
    () async {
      final cubit = _oldCart(storage);
      cubit.setQuantity('1234', 2);
      cubit.setVariant('1234', 92);
      final client = _Client()..pages[1] = [_product(1234, 'old-product')];
      await cubit.migrateLegacyProducts(_repository(client));
      await cubit.migrateLegacyProducts(_repository(client));
      expect(cubit.state.quantities, {'1234': 5});
      expect(cubit.state.variants, {'1234': 92});
      expect(cubit.state.isSelected('1234'), isTrue);
      await cubit.close();
    },
  );

  test(
    'migration does not restore a cart line removed during its request',
    () async {
      final cubit = _oldCart(storage);
      final client = _Client()
        ..gate = Completer<void>()
        ..pages[1] = [_product(1234, 'old-product')];
      final pending = cubit.migrateLegacyProducts(_repository(client));
      cubit.removeAll();
      client.gate!.complete();
      await pending;
      expect(cubit.state.quantities, isEmpty);
      await cubit.close();
    },
  );

  testWidgets('restored cart fetches and opens the migrated numeric product', (
    tester,
  ) async {
    final cubit = _oldCart(storage);
    final favorites = FavoriteCubit();
    final client = _Client()
      ..pages[1] = [_product(1234, 'old-product')]
      ..responses['/products/1234'] = _product(1234, 'old-product');
    getIt.registerSingleton<ProductRepository>(_repository(client));
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const CartPage()),
        GoRoute(
          path: '/product/:id',
          name: AppRoutes.productDetail.name,
          builder: (_, state) =>
              Text('Opened product ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(() async {
      router.dispose();
      await cubit.close();
      await favorites.close();
    });
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cubit),
          BlocProvider.value(value: favorites),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(client.requests, ['/products', '/products/1234']);
    expect(find.text('Product 1234'), findsOneWidget);
    await tester.tap(find.text('Product 1234'));
    await tester.pumpAndSettle();
    expect(find.text('Opened product 1234'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'new product notifications open IDs, old slugs are ignored, categories keep slugs',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          GoRoute(
            path: '/product/:id',
            name: AppRoutes.productDetail.name,
            builder: (_, state) =>
                Text('Product ${state.pathParameters['id']}'),
          ),
          GoRoute(
            path: '/category/:id',
            name: AppRoutes.categoryDetail.name,
            builder: (_, state) =>
                Text('Category ${state.pathParameters['id']}'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await NotificationNavigation.open('product', 'old-slug', router: router);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      await NotificationNavigation.open('product', '1234', router: router);
      await tester.pumpAndSettle();
      expect(find.text('Product 1234'), findsOneWidget);
      await NotificationNavigation.open('category', 'rings', router: router);
      await tester.pumpAndSettle();
      expect(find.text('Category rings'), findsOneWidget);
    },
  );

  testWidgets('actual product deep-link routes reject slugs before building', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );
    final config = AppRouter.router.configuration;
    final shell = config.routes.whereType<StatefulShellRoute>().single;
    final home = shell.branches.first.routes.single as GoRoute;
    final productRoutes = home.routes.whereType<GoRoute>().where(
      (route) =>
          route.name == AppRoutes.productDetail.name ||
          route.name == AppRoutes.productReviews.name,
    );
    for (final route in productRoutes) {
      GoRouterState state(String id) => GoRouterState(
        config,
        uri: Uri.parse('/product/$id'),
        matchedLocation: '/product/$id',
        fullPath: '/product/:id',
        pathParameters: {'id': id},
        pageKey: ValueKey(id),
      );
      expect(await route.redirect!(context, state('old-slug')), '/');
      expect(await route.redirect!(context, state('1234')), isNull);
    }
  });

  testWidgets(
    'preorder rows open product_id and null product_slug disables the row',
    (tester) async {
      const order = PreOrder(
        id: 1,
        number: 'PO1',
        status: PreOrderStatus.newOrder,
        totalPrice: 40,
        items: [
          PreOrderItem(
            id: 1,
            productId: 1234,
            productSlug: 'old-slug',
            name: 'Available',
            quantity: 1,
            price: 20,
            lineTotal: 20,
          ),
          PreOrderItem(
            id: 2,
            productId: 55,
            name: 'Removed',
            quantity: 1,
            price: 20,
            lineTotal: 20,
          ),
        ],
      );
      final opened = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showOrderItemsSheet(
                  context,
                  order: order,
                  photos: {},
                  onOpenProduct: opened.add,
                ),
                child: const Text('Open order'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open order'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Removed'));
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      await tester.tap(find.text('Available'));
      await tester.pumpAndSettle();
      expect(opened, [1234]);
      final data = OrderDetailData.fromPreOrder(order);
      expect(data.products.map((item) => item.id), ['1234', '55']);
    },
  );
}
