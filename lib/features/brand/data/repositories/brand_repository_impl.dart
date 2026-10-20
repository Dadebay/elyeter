import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/brand_repository.dart';
import '../datasources/brand_remote_data_source.dart';

class BrandRepositoryImpl implements BrandRepository {
  BrandRepositoryImpl(this._remote);

  final BrandRemoteDataSource _remote;

  @override
  Future<Result<List<Brand>>> list({
    String? search,
    bool featuredOnly = false,
  }) async {
    try {
      return Success(
        await _remote.list(search: search, featuredOnly: featuredOnly),
      );
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }

  @override
  Future<Result<Brand>> byId(int id) async {
    try {
      return Success(await _remote.byId(id));
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
