import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._remote, this._storage);

  /// Beyond this the list stops being "recent".
  static const _maxRecent = 10;

  final SearchRemoteDataSource _remote;
  final LocalStorage _storage;

  @override
  Future<Result<SearchSuggestions>> suggest(
    String query, {
    int limit = AppConstants.suggestLimit,
  }) async {
    if (query.trim().isEmpty) return const Success(SearchSuggestions.empty);
    try {
      return Success(await _remote.suggest(query.trim(), limit: limit));
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }

  @override
  List<String> recentSearches() =>
      _storage.getStringList(StorageKeys.recentSearches) ?? const [];

  @override
  Future<void> remember(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final next = [trimmed, ...recentSearches().where((q) => q != trimmed)];
    await _storage.setStringList(
      StorageKeys.recentSearches,
      next.take(_maxRecent).toList(),
    );
  }

  @override
  Future<void> clearRecent() => _storage.remove(StorageKeys.recentSearches);
}
