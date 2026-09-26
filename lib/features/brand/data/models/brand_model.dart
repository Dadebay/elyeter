import '../../../../core/network/api_response.dart';
import '../../../../core/utils/media_url.dart';
import '../../domain/entities/brand.dart';

abstract final class BrandModel {
  static Brand fromJson(Map<String, dynamic> json) => Brand(
    id: json.intVal('id'),
    name: json.str('name'),
    slug: json.str('slug'),
    // A brand logo may be a storage path rather than a URL.
    logo: MediaUrl.resolve(json.strOrNull('logo')),
    productsCount: json.intVal('products_count'),
  );
}
