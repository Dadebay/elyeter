import 'package:equatable/equatable.dart';

import '../../../category/domain/entities/category.dart';
import 'product.dart';
import 'product_attribute.dart';
import 'product_image.dart';
import 'product_variant.dart';

/// `GET /products/:slug` — the list item plus everything the detail page adds.
class ProductDetail extends Equatable {
  const ProductDetail({
    required this.product,
    this.description,
    this.category,
    this.breadcrumbs = const [],
    this.images = const [],
    this.variants = const [],
    this.attributes = const [],
  });

  final Product product;

  /// HTML — render it in an HTML-capable widget, not as plain text.
  final String? description;

  final CategoryCrumb? category;
  final List<CategoryCrumb> breadcrumbs;
  final List<ProductImage> images;

  /// Selectable options; each carries its own price and stock.
  final List<ProductVariant> variants;

  /// Plain spec rows for the "About this item" block.
  final List<ProductAttribute> attributes;

  /// Every photo in display order, main first.
  List<String> get gallery {
    final sorted = [...images]..sort((a, b) {
      if (a.isMain != b.isMain) return a.isMain ? -1 : 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    final urls = sorted.map((image) => image.url).toList();
    final main = product.mainImage;
    if (urls.isEmpty && main != null) return [main];
    return urls;
  }

  @override
  List<Object?> get props => [
    product,
    description,
    category,
    breadcrumbs,
    images,
    variants,
    attributes,
  ];
}
