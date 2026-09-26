import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/product_variant.dart';
import '../models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<Paginated<Product>> list({
    required ProductQuery query,
    required int page,
    required int size,
  });
  Future<ProductDetail> bySlug(String slug);
  Future<List<ProductVariant>> variants(int productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Paginated<Product>> list({
    required ProductQuery query,
    required int page,
    required int size,
  }) async {
    final data = await _client.get(
      ApiEndpoints.products,
      queryParameters: query.toQueryParameters(page: page, size: size),
    );
    return Paginated.fromJson(data, ProductModel.fromJson);
  }

  @override
  Future<ProductDetail> bySlug(String slug) async {
    final data = await _client.get(ApiEndpoints.product(slug));
    return ProductModel.detailFromJson(asMap(data));
  }

  @override
  Future<List<ProductVariant>> variants(int productId) async {
    final data = await _client.get(ApiEndpoints.productVariants(productId));
    return parseList(data, ProductModel.variantFromJson);
  }
}
