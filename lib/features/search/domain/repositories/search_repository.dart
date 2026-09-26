import '../../../../core/utils/result.dart';
import '../entities/search_suggestion.dart';

abstract interface class SearchRepository {
  /// `GET /search/suggest` — debounce calls by ~300 ms on the client.
  Future<Result<SearchSuggestions>> suggest(String query, {int limit});

  /// Recent queries, kept on the device.
  List<String> recentSearches();
  Future<void> remember(String query);
  Future<void> clearRecent();
}
