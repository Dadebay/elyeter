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
    final brands = query.allBrandSlugs;
    if (brands.length > 1) return _listAcrossBrands(query, brands, page, size);

    final data = await _client.get(
      ApiEndpoints.products,
      queryParameters: query.toQueryParameters(page: page, size: size),
    );
    return Paginated.fromJson(data, ProductModel.fromJson);
  }

  /// The API filters by one brand per request, so several brands are asked
  /// for one by one, merged, put back in the order asked for, and cut into
  /// the requested page here.
  ///
  /// The server's own orderings are reproduced from what it returns: `new`
  /// is newest id first, `popular` is most orders first, and the two price
  /// orders are by price, ties settled by id. Each brand is read up to
  /// [_maxPagesPerBrand] pages of the API's largest page.
  Future<Paginated<Product>> _listAcrossBrands(
    ProductQuery query,
    List<String> brands,
    int page,
    int size,
  ) async {
    final perBrand = await Future.wait([
      for (final slug in brands) _listAllOfBrand(query.forBrand(slug)),
    ]);

    final byId = <int, Product>{
      for (final products in perBrand)
        for (final product in products) product.id: product,
    };
    final merged = byId.values.toList()
      ..sort((a, b) {
        final byOrder = switch (query.sort) {
          ProductSort.newest => b.id.compareTo(a.id),
          ProductSort.popular => b.ordersCount.compareTo(a.ordersCount),
          ProductSort.priceAsc => a.price.compareTo(b.price),
          ProductSort.priceDesc => b.price.compareTo(a.price),
        };
        return byOrder != 0 ? byOrder : b.id.compareTo(a.id);
      });

    final start = (page - 1) * size;
    return Paginated(
      items: start >= merged.length
          ? const []
          : merged.sublist(start, (start + size).clamp(0, merged.length)),
      totalCount: merged.length,
      page: page,
    );
  }

  static const _pageSize = 100;
  static const _maxPagesPerBrand = 3;

  Future<List<Product>> _listAllOfBrand(ProductQuery query) async {
    final products = <Product>[];
    for (var page = 1; page <= _maxPagesPerBrand; page++) {
      final data = await _client.get(
        ApiEndpoints.products,
        queryParameters: query.toQueryParameters(page: page, size: _pageSize),
      );
      final result = Paginated.fromJson(data, ProductModel.fromJson);
      products.addAll(result.items);
      if (!result.hasMore(_pageSize)) break;
    }
    return products;
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
