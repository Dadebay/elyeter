import '../../../../core/utils/result.dart';
import '../entities/brand.dart';

abstract interface class BrandRepository {
  /// `GET /brands` — not paginated; only brands with published products.
  Future<Result<List<Brand>>> list({String? search});

  /// `GET /brands/:slug`
  Future<Result<Brand>> bySlug(String slug);
}
