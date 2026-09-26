import '../../../../core/network/api_response.dart';
import '../../../../core/utils/media_url.dart';
import '../../domain/entities/category.dart';

abstract final class CategoryModel {
  static Category fromJson(Map<String, dynamic> json) => Category(
    id: json.intVal('id'),
    parentId: json.intOrNull('parent_id'),
    name: json.str('name'),
    slug: json.str('slug'),
    // Category artwork may be a storage path rather than a URL.
    imageLarge: MediaUrl.resolve(json.strOrNull('image_large')),
    imageSmall: MediaUrl.resolve(json.strOrNull('image_small')),
    productsCount: json.intVal('products_count'),
    children: json.listOf('children').map(fromJson).toList(),
    breadcrumbs: json.listOf('breadcrumbs').map(crumbFromJson).toList(),
  );

  static CategoryCrumb crumbFromJson(Map<String, dynamic> json) =>
      CategoryCrumb(
        id: json.intVal('id'),
        slug: json.str('slug'),
        name: json.str('name'),
      );
}
