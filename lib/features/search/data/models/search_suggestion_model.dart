import '../../../../core/network/api_response.dart';
import '../../domain/entities/search_suggestion.dart';

abstract final class SearchSuggestionModel {
  static SearchSuggestions fromJson(Map<String, dynamic> json) =>
      SearchSuggestions(
        products: json.listOf('products').map(productFromJson).toList(),
        categories: json.listOf('categories').map(categoryFromJson).toList(),
      );

  static ProductSuggestion productFromJson(Map<String, dynamic> json) =>
      ProductSuggestion(
        id: json.intVal('id'),
        slug: json.str('slug'),
        name: json.str('name'),
        price: json.numVal('price'),
        mainImage: json.strOrNull('main_image'),
      );

  static CategorySuggestion categoryFromJson(Map<String, dynamic> json) =>
      CategorySuggestion(
        id: json.intVal('id'),
        slug: json.str('slug'),
        name: json.str('name'),
      );
}
