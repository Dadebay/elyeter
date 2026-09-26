import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

abstract interface class CategoryRemoteDataSource {
  Future<List<Category>> tree();
  Future<Category> bySlug(String slug);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<Category>> tree() async {
    final data = await _client.get(ApiEndpoints.categoriesTree);
    return parseList(data, CategoryModel.fromJson);
  }

  @override
  Future<Category> bySlug(String slug) async {
    final data = await _client.get(ApiEndpoints.category(slug));
    return CategoryModel.fromJson(asMap(data));
  }
}
