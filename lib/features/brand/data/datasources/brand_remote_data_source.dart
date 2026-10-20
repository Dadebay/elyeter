import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/brand.dart';
import '../models/brand_model.dart';

abstract interface class BrandRemoteDataSource {
  Future<List<Brand>> list({String? search, bool featuredOnly = false});
  Future<Brand> byId(int id);
}

class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  BrandRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<Brand>> list({String? search, bool featuredOnly = false}) async {
    dynamic data;
    try {
      data = await _client.get(
        ApiEndpoints.brands,
        queryParameters: {
          'search': search,
          if (featuredOnly) 'is_featured': true,
        },
      );
    } on ValidationException catch (error) {
      if (!featuredOnly || !error.message.contains('is_featured')) rethrow;
      data = await _client.get(
        ApiEndpoints.brands,
        queryParameters: {'search': search},
      );
    }
    return parseList(data, BrandModel.fromJson);
  }

  @override
  Future<Brand> byId(int id) async {
    final data = await _client.get(ApiEndpoints.brand(id));
    return BrandModel.fromJson(asMap(data));
  }
}
