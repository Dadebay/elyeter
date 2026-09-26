import '../../../../core/utils/result.dart';
import '../entities/category.dart';

abstract interface class CategoryRepository {
  /// `GET /categories/tree` — the full tree of active categories.
  Future<Result<List<Category>>> tree();

  /// `GET /categories/:slug` — one category plus its breadcrumbs.
  Future<Result<Category>> bySlug(String slug);
}
