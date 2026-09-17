import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../../home/presentation/view/home_placeholder_data.dart';
import '../model/product_detail_data.dart';
import '../widgets/product_reviews_section.dart';
import '../widgets/product_section_card.dart';

/// Every review for one product, behind the detail page's "Read all reviews".
class ProductReviewsPage extends StatelessWidget {
  const ProductReviewsPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final product = HomePlaceholderData.productById(productId);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppPageAppBar(title: context.l10n.productReviews),
      body: product == null
          ? const AppEmptyView(icon: Icons.search_off_rounded)
          : _Reviews(detail: HomePlaceholderData.detailFor(product)),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews({required this.detail});

  final ProductDetailData detail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      children: [
        ProductSectionCard(
          child: ProductReviewScore(rating: detail.rating, ratingCount: detail.ratingCount),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final review in detail.reviews) ...[
          // Full width and untruncated: this page exists to read them.
          ProductReviewCard(
            review: review,
            width: null,
            maxLines: 20,
            color: AppColors.background,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
