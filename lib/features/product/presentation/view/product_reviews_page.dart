import 'package:flutter/material.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../domain/entities/product_reviews.dart';
import '../../domain/repositories/product_repository.dart';
import '../widgets/product_review_button.dart';
import '../widgets/product_review_dialog.dart';
import '../widgets/product_reviews_section.dart';
import '../widgets/product_section_card.dart';

class ProductReviewsPage extends StatefulWidget {
  const ProductReviewsPage({super.key, required this.productId});
  final String productId;

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  static const _pageSize = 20;
  ProductReviews? _reviews;
  List<ProductReviewEntry> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _saving = false;
  int _request = 0;

  int get _id => int.parse(widget.productId);
  ProductRepository get _repo => getIt<ProductRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ProductReviewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _loadingMore = false;
    });
    final result = await _repo.reviews(_id, page: 1, size: _pageSize);
    if (!mounted || request != _request) return;
    setState(() {
      _loading = false;
      _reviews = result.dataOrNull;
      _items = _reviews?.items ?? [];
    });
  }

  Future<void> _loadMore() async {
    final current = _reviews;
    if (current == null ||
        _loadingMore ||
        _items.length >= current.totalCount) {
      return;
    }
    final request = _request;
    setState(() => _loadingMore = true);
    final result = await _repo.reviews(
      _id,
      page: current.page + 1,
      size: _pageSize,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _loadingMore = false;
      if (result.dataOrNull case final next?) {
        _reviews = next;
        _items = [..._items, ...next.items];
      }
    });
    if (result.isError) _message(context.l10n.reviewLoadError);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _write() async {
    final saved = await showProductReviewDialog(
      context,
      productId: _id,
      review: _reviews?.myReview,
    );
    if (saved && mounted) await _load();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.reviewDeleteConfirm),
        content: Text(context.l10n.reviewDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.reviewDelete),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _saving = true);
    final result = await _repo.deleteMyReview(_id);
    if (!mounted) return;
    setState(() => _saving = false);
    _message(
      result.isSuccess
          ? context.l10n.reviewDeleted
          : context.l10n.reviewActionError,
    );
    if (result.isSuccess) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppPageAppBar(title: context.l10n.productReviews),
      body: _loading && reviews == null
          ? const Center(child: AppLoader())
          : reviews == null
          ? Center(
              child: TextButton(
                onPressed: _load,
                child: Text(context.l10n.reviewLoadError),
              ),
            )
          : AppRefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.xxl,
                ),
                children: [
                  ProductSectionCard(
                    child: reviews.summary.count == 0
                        ? Text(context.l10n.reviewEmpty)
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductReviewScore(
                                rating: reviews.summary.average ?? 0,
                                ratingCount: reviews.summary.count,
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: ProductReviewDistribution(
                                  shares: reviews.summary.shares,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final review in _items) ...[
                    ProductReviewCard(
                      review: displayReview(context, review),
                      width: null,
                      maxLines: 100,
                      color: AppColors.background,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (_items.length < reviews.totalCount)
                    TextButton(
                      onPressed: _loadingMore ? null : _loadMore,
                      child: _loadingMore
                          ? const AppLoader()
                          : Text(context.l10n.reviewLoadMore),
                    ),
                  ProductReviewButton(
                    onPressed: _saving || _loading ? null : _write,
                    label: reviews.myReview == null
                        ? context.l10n.reviewWrite
                        : context.l10n.reviewEdit,
                  ),
                  if (reviews.myReview != null)
                    TextButton(
                      onPressed: _saving || _loading ? null : _delete,
                      child: Text(context.l10n.reviewDelete),
                    ),
                ],
              ),
            ),
    );
  }
}
