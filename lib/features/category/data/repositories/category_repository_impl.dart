import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._remote);

  final CategoryRemoteDataSource _remote;

  /// The tree is the same for every screen that needs it and changes rarely,
  /// so it is fetched once per launch and served from memory afterwards.
  List<Category>? _cachedTree;

  @override
  Future<Result<List<Category>>> tree() async {
    final cached = _cachedTree;
    if (cached != null) return Success(cached);
    try {
      final tree = await _remote.tree();
      _cachedTree = tree;
      return Success(tree);
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }

  @override
  Future<Result<Category>> bySlug(String slug) async {
    try {
      return Success(await _remote.bySlug(slug));
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
