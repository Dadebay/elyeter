import 'package:equatable/equatable.dart';

/// How `GET /products` may be ordered.
enum ProductSort {
  newest('new'),
  priceAsc('price_asc'),
  priceDesc('price_desc'),
  popular('popular');

  const ProductSort(this.value);

  final String value;
}

/// Every query parameter `GET /products` accepts.
///
/// Only the fields that are set are sent: the API rejects unknown or empty
/// query params rather than ignoring them.
class ProductQuery extends Equatable {
  const ProductQuery({
    this.categoryId,
    this.categorySlug,
    this.brandId,
    this.brandSlug,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.onlyFeatured = false,
    this.sort = ProductSort.newest,
  });

  /// A category id or slug matches that category **and all descendants**.
  final int? categoryId;
  final String? categorySlug;

  final int? brandId;
  final String? brandSlug;

  /// Matches product name (both languages) and SKU.
  final String? search;

  final num? minPrice;
  final num? maxPrice;

  /// Featured products only — what the home screen shows.
  final bool onlyFeatured;

  final ProductSort sort;

  Map<String, dynamic> toQueryParameters({
    required int page,
    required int size,
  }) => {
    'page': page,
    'size': size,
    'sort': sort.value,
    if (categoryId != null) 'category_id': categoryId,
    if (categorySlug != null) 'category_slug': categorySlug,
    if (brandId != null) 'brand_id': brandId,
    if (brandSlug != null) 'brand_slug': brandSlug,
    if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    if (minPrice != null) 'min_price': minPrice,
    if (maxPrice != null) 'max_price': maxPrice,
    // Only ever sent as `true`; the API has no "false" case for it.
    if (onlyFeatured) 'only_featured': true,
  };

  ProductQuery copyWith({
    int? categoryId,
    String? categorySlug,
    int? brandId,
    String? brandSlug,
    String? search,
    num? minPrice,
    num? maxPrice,
    bool? onlyFeatured,
    ProductSort? sort,
    bool clearPrices = false,
    bool clearSearch = false,
  }) => ProductQuery(
    categoryId: categoryId ?? this.categoryId,
    categorySlug: categorySlug ?? this.categorySlug,
    brandId: brandId ?? this.brandId,
    brandSlug: brandSlug ?? this.brandSlug,
    search: clearSearch ? null : (search ?? this.search),
    minPrice: clearPrices ? null : (minPrice ?? this.minPrice),
    maxPrice: clearPrices ? null : (maxPrice ?? this.maxPrice),
    onlyFeatured: onlyFeatured ?? this.onlyFeatured,
    sort: sort ?? this.sort,
  );

  @override
  List<Object?> get props => [
    categoryId,
    categorySlug,
    brandId,
    brandSlug,
    search,
    minPrice,
    maxPrice,
    onlyFeatured,
    sort,
  ];
}
