import 'package:elyeter/core/storage/local_storage.dart';
import 'package:elyeter/features/search/data/datasources/search_remote_data_source.dart';
import 'package:elyeter/features/search/data/repositories/search_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Remote extends Mock implements SearchRemoteDataSource {}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'search phrases survive preferences reload and repository recreation',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final repository = SearchRepositoryImpl(
        _Remote(),
        LocalStorageImpl(preferences),
      );
      await repository.remember('  iphone 17 pro  ');
      await repository.remember('car organizer');

      await preferences.reload();
      final reopened = SearchRepositoryImpl(
        _Remote(),
        LocalStorageImpl(preferences),
      );
      expect(reopened.recentSearches(), ['car organizer', 'iphone 17 pro']);
    },
  );

  test(
    'recent searches ignore blanks and keep ten unique phrases, newest first',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final repository = SearchRepositoryImpl(
        _Remote(),
        LocalStorageImpl(preferences),
      );
      for (var index = 0; index < 12; index++) {
        await repository.remember('query $index');
      }
      await repository.remember('  QUERY 10  ');
      await repository.remember('   ');

      expect(repository.recentSearches(), [
        'QUERY 10',
        'query 11',
        'query 9',
        'query 8',
        'query 7',
        'query 6',
        'query 5',
        'query 4',
        'query 3',
        'query 2',
      ]);
      await repository.clearRecent();
      expect(repository.recentSearches(), isEmpty);
    },
  );
}
