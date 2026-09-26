import '../../../../core/network/api_response.dart';
import '../../../brand/data/models/brand_model.dart';
import '../../../category/data/models/category_model.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_attribute.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/product_variant.dart';

abstract final class ProductModel {
  static Product fromJson(Map<String, dynamic> json) {
    final brand = json.mapOrNull('brand');
    return Product(
      id: json.intVal('id'),
      slug: json.str('slug'),
      sku: json.str('sku'),
      name: json.str('name'),
      price: json.numVal('price'),
      oldPrice: json.numOrNull('old_price'),
      stock: json.intVal('stock'),
      hasVariants: json.boolVal('has_variants'),
      // Product photos already come back as absolute URLs.
      mainImage: json.strOrNull('main_image'),
      rating: json.doubleOrNull('rating'),
      ordersCount: json.intVal('orders_count'),
      isFeatured: json.boolVal('is_featured'),
      categoryId: json.intOrNull('category_id'),
      brand: brand == null ? null : BrandModel.fromJson(brand),
    );
  }

  static ProductDetail detailFromJson(Map<String, dynamic> json) {
    final category = json.mapOrNull('category');
    return ProductDetail(
      product: fromJson(json),
      description: json.strOrNull('description'),
      category: category == null
          ? null
          : CategoryModel.crumbFromJson(category),
      breadcrumbs: json
          .listOf('breadcrumbs')
          .map(CategoryModel.crumbFromJson)
          .toList(),
      images: json.listOf('images').map(imageFromJson).toList(),
      variants: json.listOf('variants').map(variantFromJson).toList(),
      attributes: json.listOf('attributes').map(attributeFromJson).toList(),
    );
  }

  static ProductImage imageFromJson(Map<String, dynamic> json) => ProductImage(
    id: json.intVal('id'),
    url: json.str('url'),
    isMain: json.boolVal('is_main'),
    sortOrder: json.intVal('sort_order'),
  );

  static ProductVariant variantFromJson(Map<String, dynamic> json) =>
      ProductVariant(
        id: json.intVal('id'),
        sku: json.str('sku'),
        price: json.numVal('price'),
        oldPrice: json.numOrNull('old_price'),
        stock: json.intVal('stock'),
        image: json.strOrNull('image'),
        attributes: json.listOf('attributes').map(attributeFromJson).toList(),
      );

  static ProductAttribute attributeFromJson(Map<String, dynamic> json) =>
      ProductAttribute(name: json.str('name'), value: json.str('value'));
}
