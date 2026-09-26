import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/brand.dart';
import '../models/brand_model.dart';

abstract interface class BrandRemoteDataSource {
  Future<List<Brand>> list({String? search});
  Future<Brand> bySlug(String slug);
}

class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  BrandRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<Brand>> list({String? search}) async {
    final data = await _client.get(
      ApiEndpoints.brands,
      queryParameters: {'search': search},
    );
    return parseList(data, BrandModel.fromJson);
  }

  @override
  Future<Brand> bySlug(String slug) async {
    final data = await _client.get(ApiEndpoints.brand(slug));
    return BrandModel.fromJson(asMap(data));
  }
}
