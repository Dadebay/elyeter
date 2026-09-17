import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../model/product_detail_data.dart';
import 'product_section_card.dart';

/// Score, the per-star bars and a strip of the most recent reviews.
class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({super.key, required this.detail, this.onReadAll});

  /// Height of the review strip: stars, four lines of text and the author
  /// row, with the card's own padding — no more, or every card trails an
  /// empty band under its author.
  static const _stripHeight = 150.0;

  final ProductDetailData detail;
  final VoidCallback? onReadAll;

  @override
  Widget build(BuildContext context) {
    // One block, button included: the reviews and the way into the rest of
    // them are the same thing, and a second card underneath read as a
    // separate section.
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.productReviews,
            style: context.textTheme.titleMedium?.copyWith(color: AppColors.black),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductReviewScore(
                rating: detail.rating,
                ratingCount: detail.ratingCount,
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: _Bars(shares: detail.ratingBreakdown)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: _stripHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: detail.reviews.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) =>
                  ProductReviewCard(review: detail.reviews[index]),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ReadAllButton(onTap: onReadAll),
        ],
      ),
    );
  }
}

/// The way through to the full list: a white bar lifted off the grey block
/// by its shadow rather than outlined against it.
class _ReadAllButton extends StatelessWidget {
  const _ReadAllButton({required this.onTap});

  static const _height = 52.0;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);

    return DecoratedBox(
      // Outside the Material, which clips its own children to the shape.
      // Kept shallow so the block's own clip does not shave it off.
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: _height,
            width: double.infinity,
            child: Center(
              child: Text(
                context.l10n.productReadAllReviews,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The headline score: the number, its stars and how many ratings it is from.
class ProductReviewScore extends StatelessWidget {
  const ProductReviewScore({super.key, required this.rating, required this.ratingCount});

  final double rating;
  final int ratingCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: context.textTheme.displayLarge?.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: AppSpacing.xs),
        ProductStars(rating: rating, size: 18),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.productRatingCount(ratingCount),
          style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey500),
        ),
      ],
    );
  }
}

/// One bar per star, five first — the share of ratings that gave it.
class _Bars extends StatelessWidget {
  const _Bars({required this.shares});

  static const _barHeight = 8.0;

  final List<double> shares;

  @override
  Widget build(BuildContext context) {
    if (shares.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < shares.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  child: Text(
                    '${shares.length - i}',
                    style: context.textTheme.labelMedium?.copyWith(color: AppColors.grey700),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: shares[i],
                      minHeight: _barHeight,
                      // White track, not grey: the card underneath is already
                      // grey, so a grey track would disappear into it.
                      backgroundColor: AppColors.white,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A single review, as the strip and the full list both draw it.
class ProductReviewCard extends StatelessWidget {
  const ProductReviewCard({
    super.key,
    required this.review,
    this.width = 260,
    this.maxLines = 4,
    this.color = AppColors.white,
  });

  final ProductReview review;

  /// White on the detail page's grey block; grey on the white reviews page.
  final Color color;

  /// Null stretches the card to whatever room it is given.
  final double? width;

  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ProductStars(rating: review.rating, size: 14),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: Text(
              review.text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey700),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Avatar(name: review.author),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${review.author} • ${review.date}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(color: AppColors.grey500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The reviewer's initial on a tinted disc — no photos to load.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  static const _size = 24.0;

  /// Deterministic from the name, so a reviewer keeps the same colour.
  static const _tints = [
    Color(0xFFEDE7FF),
    Color(0xFFFFE9DD),
    Color(0xFFE2F5EA),
    Color(0xFFFFE6EF),
  ];

  final String name;

  @override
  Widget build(BuildContext context) {
    final tint = _tints[name.hashCode.abs() % _tints.length];

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
      child: Text(
        name.characters.first.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(color: AppColors.grey900),
      ),
    );
  }
}

/// Five stars, filled up to [rating].
class ProductStars extends StatelessWidget {
  const ProductStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= 5; i++)
        Icon(
          Icons.star_rounded,
          size: size,
          color: i <= rating.round() ? AppColors.primary : AppColors.grey300,
        ),
    ],
  );
}
