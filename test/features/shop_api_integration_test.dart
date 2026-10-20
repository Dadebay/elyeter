import 'package:dio/dio.dart';
import 'package:elyeter/core/error/failure.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/features/auth/domain/entities/app_user.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _Client extends ApiClient {
  _Client() : super(Dio());
  final requests = <String>[];
  final responses = <String, dynamic>{};

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    requests.add('GET $path ${queryParameters ?? {}}');
    return responses[path];
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    requests.add('POST $path');
    return responses['POST $path'];
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    CancelToken? cancelToken,
  }) async {
    requests.add('DELETE $path');
    return responses['DELETE $path'];
  }
}

class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'public banners keep the API order and accept a missing title',
    () async {
      final client = _Client()
        ..responses['/banners'] = [
          {
            'id': 5,
            'title': null,
            'image': 'https://example.com/phone.webp',
            'target_type': 'product',
            'target': '1234',
          },
          {
            'id': 3,
            'title': 'Hepdäniň arzanladyşlary',
            'image': 'https://example.com/sale.webp',
            'target_type': 'category',
            'target': 'elektronika',
          },
        ];

      final banners = await ShopApi(client).banners();

      expect(client.requests, ['GET /banners {}']);
      expect(banners.map((banner) => banner.id), [5, 3]);
      expect(banners.first.title, isNull);
      expect(banners.first.target, '1234');
      expect(banners.last.image, 'https://example.com/sale.webp');
      expect(banners.last.targetType, 'category');
    },
  );

  test(
    'favourites use numeric product IDs and clear when the account ends',
    () async {
      final client = _Client()
        ..responses['/favorites/ids'] = [12, 7]
        ..responses['POST /favorites/5'] = {'is_favorite': true};
      final auth = AuthCubit(_UnusedAuthRepository());
      final cubit = FavoriteCubit(ShopApi(client), auth);
      auth.onSignedIn(const AppUser(id: 1, phone: '+99365000000'));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, {'12', '7'});
      expect(await cubit.toggle('5'), isTrue);
      expect(cubit.state, contains('5'));
      expect(client.requests, contains('POST /favorites/5'));
      auth.onSessionExpired(const UnauthorizedFailure());
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isEmpty);
      await cubit.close();
      await auth.close();
    },
  );

  test(
    'address and notification payloads stay typed, with required pagination',
    () async {
      final client = _Client()
        ..responses['/locations'] = [
          {
            'id': 3,
            'name': 'Home',
            'latitude': 37.96,
            'longitude': 58.32,
            'is_default': true,
            'address': 'Street 12',
          },
        ]
        ..responses['/notifications'] = {
          'totalCount': 21,
          'page': 1,
          'items': [
            {
              'id': 12,
              'title': 'Sale',
              'body': 'Today',
              'target_type': 'product',
              'target': 'product-slug',
            },
          ],
        };
      final api = ShopApi(client);
      final locations = await api.locations();
      expect(locations.single.isDefault, isTrue);
      expect(locations.single.latitude, closeTo(37.96, 0.001));
      final notifications = await api.notifications();
      expect(notifications.items.single.target, 'product-slug');
      expect(notifications.hasMore(20), isTrue);
      expect(client.requests.last, contains('page: 1'));
      expect(client.requests.last, contains('size: 20'));
    },
  );
}
