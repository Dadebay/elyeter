import 'package:equatable/equatable.dart';

/// A brand as `GET /brands` returns it, and as it is nested on a product.
class Brand extends Equatable {
  const Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.productsCount = 0,
  });

  final int id;
  final String name;
  final String slug;

  /// Already resolved against the file server when the API sent a path.
  final String? logo;

  final int productsCount;

  @override
  List<Object?> get props => [id, name, slug, logo, productsCount];
}
