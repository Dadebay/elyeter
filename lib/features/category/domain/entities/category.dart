import 'package:equatable/equatable.dart';

/// A node of `GET /categories/tree`, names already resolved to the language
/// sent in `Content-Language`.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.imageLarge,
    this.imageSmall,
    this.productsCount = 0,
    this.children = const [],
    this.breadcrumbs = const [],
  });

  final int id;
  final int? parentId;
  final String name;
  final String slug;

  /// Already resolved against the file server when the API sent a path.
  final String? imageLarge;
  final String? imageSmall;

  /// Published products in this exact category, descendants not included.
  final int productsCount;

  final List<Category> children;

  /// Root -> current; only `GET /categories/:slug` fills this.
  final List<CategoryCrumb> breadcrumbs;

  bool get hasChildren => children.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    parentId,
    name,
    slug,
    imageLarge,
    imageSmall,
    productsCount,
    children,
    breadcrumbs,
  ];
}

/// One step of a category's breadcrumb trail.
class CategoryCrumb extends Equatable {
  const CategoryCrumb({
    required this.id,
    required this.slug,
    required this.name,
  });

  final int id;
  final String slug;
  final String name;

  @override
  List<Object?> get props => [id, slug, name];
}
