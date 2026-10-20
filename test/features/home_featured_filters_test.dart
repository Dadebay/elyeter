import 'package:dio/dio.dart';
import 'package:elyeter/core/error/exceptions.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/features/brand/data/datasources/brand_remote_data_source.dart';
import 'package:elyeter/features/category/data/datasources/category_remote_data_source.dart';
import 'package:elyeter/features/category/data/repositories/category_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingClient extends ApiClient {
  _RecordingClient({this.rejectFeatured = false}) : super(Dio());

  final bool rejectFeatured;
  final requests = <(String, Map<String, dynamic>?)>[];

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    requests.add((path, queryParameters));
    if (rejectFeatured && queryParameters?['is_featured'] == true) {
      throw const ValidationException('property is_featured should not exist');
    }
    return const [];
  }
}

void main() {
  test('home refresh bypasses the cached featured category tree', () async {
    final client = _RecordingClient();
    final repository = CategoryRepositoryImpl(
      CategoryRemoteDataSourceImpl(client),
    );

    await repository.tree(featuredOnly: true);
    await repository.tree(featuredOnly: true);
    await repository.tree(featuredOnly: true, forceRefresh: true);
    await repository.tree(featuredOnly: true);

    expect(client.requests.length, 2);
    expect(
      client.requests.every((request) => request.$2?['is_featured'] == true),
      isTrue,
    );
  });

  test('home category tree requests only featured categories', () async {
    final client = _RecordingClient();
    final source = CategoryRemoteDataSourceImpl(client);

    await source.tree(featuredOnly: true);
    await source.tree();

    expect(client.requests.length, 2);
    expect(client.requests.map((request) => request.$1), [
      '/categories/tree',
      '/categories/tree',
    ]);
    expect(client.requests.first.$2, {'is_featured': true});
    expect(client.requests.last.$2, isNull);
  });

  test('home brands request only featured brands', () async {
    final client = _RecordingClient();
    final source = BrandRemoteDataSourceImpl(client);

    await source.list(featuredOnly: true);
    await source.list();

    expect(client.requests.length, 2);
    expect(client.requests.map((request) => request.$1), [
      '/brands',
      '/brands',
    ]);
    expect(client.requests.first.$2, {'search': null, 'is_featured': true});
    expect(client.requests.last.$2, {'search': null});
  });

  test(
    'unsupported featured filter retries without it during rollout',
    () async {
      final brandsClient = _RecordingClient(rejectFeatured: true);
      final categoriesClient = _RecordingClient(rejectFeatured: true);

      await BrandRemoteDataSourceImpl(brandsClient).list(featuredOnly: true);
      await CategoryRemoteDataSourceImpl(
        categoriesClient,
      ).tree(featuredOnly: true);

      expect(
        brandsClient.requests.map((request) => request.$2?['is_featured']),
        [true, null],
      );
      expect(
        categoriesClient.requests.map((request) => request.$2?['is_featured']),
        [true, null],
      );
    },
  );
}
