import '../../../../core/network/api_response.dart';

/// One page from `GET /products/:id/reviews`, including the rating summary.
class ProductReviews {
  const ProductReviews({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.summary,
    this.myReview,
  });

  factory ProductReviews.fromJson(Map<String, dynamic> json) => ProductReviews(
    items: json.listOf('items').map(ProductReviewEntry.fromJson).toList(),
    totalCount: json.intVal('totalCount'),
    page: json.intVal('page', 1),
    summary: ProductReviewSummary.fromJson(json.mapOrNull('summary') ?? {}),
    myReview: switch (json.mapOrNull('my_review')) {
      final Map<String, dynamic> value => ProductReviewEntry.fromJson(value),
      _ => null,
    },
  );

  final List<ProductReviewEntry> items;
  final int totalCount;
  final int page;
  final ProductReviewSummary summary;
  final ProductReviewEntry? myReview;
}

class ProductReviewSummary {
  const ProductReviewSummary({
    required this.average,
    required this.count,
    required this.distribution,
  });

  factory ProductReviewSummary.fromJson(Map<String, dynamic> json) {
    final counts = json.mapOrNull('distribution') ?? {};
    return ProductReviewSummary(
      average: json.doubleOrNull('average'),
      count: json.intVal('count'),
      distribution: {
        for (var stars = 1; stars <= 5; stars++)
          stars: (counts['$stars'] as num?)?.toInt() ?? 0,
      },
    );
  }

  final double? average;
  final int count;
  final Map<int, int> distribution;

  /// Relative bar lengths, ordered from five stars down to one.
  List<double> get shares => [
    for (var stars = 5; stars >= 1; stars--)
      count == 0 ? 0 : (distribution[stars] ?? 0) / count,
  ];
}

class ProductReviewEntry {
  const ProductReviewEntry({
    required this.id,
    required this.rating,
    this.comment,
    this.author,
    this.createdAt,
    this.isMine = false,
  });

  factory ProductReviewEntry.fromJson(Map<String, dynamic> json) {
    final user = json.mapOrNull('user');
    return ProductReviewEntry(
      id: json.intVal('id'),
      rating: json.intVal('rating'),
      comment: json.strOrNull('comment'),
      author:
          json.strOrNull('author') ??
          json.strOrNull('username') ??
          user?.strOrNull('username') ??
          user?.strOrNull('name') ??
          user?.strOrNull('full_name') ??
          _fullName(user) ??
          json.strOrNull('name'),
      createdAt: json.dateOrNull('created_at'),
      isMine: json.boolVal('is_mine'),
    );
  }

  static String? _fullName(Map<String, dynamic>? user) {
    final name = [
      user?.strOrNull('first_name'),
      user?.strOrNull('last_name'),
    ].whereType<String>().join(' ');
    return name.isEmpty ? null : name;
  }

  final int id;
  final int rating;
  final String? comment;
  final String? author;
  final DateTime? createdAt;
  final bool isMine;
}
