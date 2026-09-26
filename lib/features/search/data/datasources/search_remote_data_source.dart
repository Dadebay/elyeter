import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/search_suggestion.dart';
import '../models/search_suggestion_model.dart';

abstract interface class SearchRemoteDataSource {
  Future<SearchSuggestions> suggest(
    String query, {
    required int limit,
    CancelToken? cancelToken,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<SearchSuggestions> suggest(
    String query, {
    required int limit,
    CancelToken? cancelToken,
  }) async {
    final data = await _client.get(
      ApiEndpoints.searchSuggest,
      queryParameters: {'q': query, 'limit': limit},
      cancelToken: cancelToken,
    );
    return SearchSuggestionModel.fromJson(asMap(data));
  }
}
