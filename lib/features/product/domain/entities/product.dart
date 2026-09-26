import 'package:equatable/equatable.dart';

import '../../../brand/domain/entities/brand.dart';

/// A catalog list item, as `GET /products` returns it.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.slug,
    required this.sku,
    required this.name,
    required this.price,
    this.oldPrice,
    this.stock = 0,
    this.hasVariants = false,
    this.mainImage,
    this.rating,
    this.ordersCount = 0,
    this.isFeatured = false,
    this.categoryId,
    this.brand,
  });

  final int id;
  final String slug;
  final String sku;
  final String name;
  final num price;

  /// Strike-through price; null when there is no discount.
  final num? oldPrice;

  /// A snapshot from the last supplier sync, never a guarantee — real
  /// availability is only confirmed by `POST /pre-orders/check`.
  final int stock;

  /// When true a `variant_id` is mandatory at checkout.
  final bool hasVariants;

  /// Already an absolute URL.
  final String? mainImage;

  final double? rating;
  final int ordersCount;
  final bool isFeatured;
  final int? categoryId;
  final Brand? brand;

  /// Whole percent off, or null when the product is not discounted.
  int? get discountPercent {
    final was = oldPrice;
    if (was == null || was <= price) return null;
    return ((was - price) / was * 100).round();
  }

  @override
  List<Object?> get props => [
    id,
    slug,
    sku,
    name,
    price,
    oldPrice,
    stock,
    hasVariants,
    mainImage,
    rating,
    ordersCount,
    isFeatured,
    categoryId,
    brand,
  ];
}
