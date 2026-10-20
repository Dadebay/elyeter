import '../../../../core/utils/result.dart';
import '../entities/category.dart';

abstract interface class CategoryRepository {
  /// `GET /categories/tree` — optionally limited to home-screen categories.
  Future<Result<List<Category>>> tree({
    bool featuredOnly = false,
    bool forceRefresh = false,
  });

  /// `GET /categories/:id` — one category plus its breadcrumbs.
  Future<Result<Category>> byId(int id);
}
