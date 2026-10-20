import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._remote);

  final CategoryRemoteDataSource _remote;

  /// Keep the home subset separate from the full category tree.
  final Map<bool, List<Category>> _cachedTrees = {};

  @override
  Future<Result<List<Category>>> tree({
    bool featuredOnly = false,
    bool forceRefresh = false,
  }) async {
    final cached = _cachedTrees[featuredOnly];
    if (!forceRefresh && cached != null) return Success(cached);
    try {
      final tree = await _remote.tree(featuredOnly: featuredOnly);
      _cachedTrees[featuredOnly] = tree;
      return Success(tree);
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }

  @override
  Future<Result<Category>> byId(int id) async {
    try {
      return Success(await _remote.byId(id));
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
