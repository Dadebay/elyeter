import '../../../../core/network/api_response.dart';
import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_detail.dart';
import '../entities/product_query.dart';
import '../entities/product_variant.dart';

abstract interface class ProductRepository {
  /// `GET /products` — both `page` and `size` are required by the API.
  Future<Result<Paginated<Product>>> list({
    required ProductQuery query,
    int page,
    int size,
  });

  /// `GET /products/:slug`
  Future<Result<ProductDetail>> bySlug(String slug);

  /// `GET /products/:id/variants` — note this one takes the numeric id.
  Future<Result<List<ProductVariant>>> variants(int productId);
}
