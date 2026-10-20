import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

abstract interface class CategoryRemoteDataSource {
  Future<List<Category>> tree({bool featuredOnly = false});
  Future<Category> byId(int id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<Category>> tree({bool featuredOnly = false}) async {
    dynamic data;
    try {
      data = await _client.get(
        ApiEndpoints.categoriesTree,
        queryParameters: featuredOnly ? {'is_featured': true} : null,
      );
    } on ValidationException catch (error) {
      if (!featuredOnly || !error.message.contains('is_featured')) rethrow;
      data = await _client.get(ApiEndpoints.categoriesTree);
    }
    return parseList(data, CategoryModel.fromJson);
  }

  @override
  Future<Category> byId(int id) async {
    final data = await _client.get(ApiEndpoints.category(id));
    return CategoryModel.fromJson(asMap(data));
  }
}
