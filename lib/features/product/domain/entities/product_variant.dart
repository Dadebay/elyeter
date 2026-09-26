import 'package:equatable/equatable.dart';

import 'product_attribute.dart';

/// A selectable option (colour, size). Its own price and stock override the
/// product's once it is chosen, and its id is mandatory at checkout when the
/// product has variants.
class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.sku,
    required this.price,
    this.oldPrice,
    this.stock = 0,
    this.image,
    this.attributes = const [],
  });

  final int id;
  final String sku;
  final num price;
  final num? oldPrice;
  final int stock;
  final String? image;
  final List<ProductAttribute> attributes;

  /// `Reňk: Gara` — what the option chip shows.
  String get label =>
      attributes.map((a) => '${a.name}: ${a.value}').join(', ');

  bool get inStock => stock > 0;

  @override
  List<Object?> get props => [id, sku, price, oldPrice, stock, image, attributes];
}
