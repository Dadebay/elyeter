import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<Result<Paginated<Product>>> list({
    required ProductQuery query,
    int page = 1,
    int size = AppConstants.pageSize,
  }) => _guard(
    () => _remote.list(
      query: query,
      page: page < 1 ? 1 : page,
      // The API returns 400 above 100.
      size: size.clamp(1, AppConstants.maxPageSize),
    ),
  );

  @override
  Future<Result<ProductDetail>> bySlug(String slug) =>
      _guard(() => _remote.bySlug(slug));

  @override
  Future<Result<List<ProductVariant>>> variants(int productId) =>
      _guard(() => _remote.variants(productId));

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
