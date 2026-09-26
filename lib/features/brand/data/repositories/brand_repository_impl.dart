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
  Future<Result<List<Brand>>> list({String? search}) async {
    try {
      return Success(await _remote.list(search: search));
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }

  @override
  Future<Result<Brand>> bySlug(String slug) async {
    try {
      return Success(await _remote.bySlug(slug));
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
