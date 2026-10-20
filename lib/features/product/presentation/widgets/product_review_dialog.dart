import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../domain/entities/product_reviews.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_review_button.dart';

/// Returns true after saving so either product screen can refresh its reviews.
Future<bool> showProductReviewDialog(
  BuildContext context, {
  required int productId,
  ProductReviewEntry? review,
}) async {
  final repository = getIt<ProductRepository>();
  if (!context.read<AuthCubit>().state.isAuthenticated) {
    if (!await promptSignIn(context) || !context.mounted) return false;
    // Reviews loaded while signed out do not include the customer's review.
    final result = await repository.reviews(productId, page: 1, size: 1);
    if (!context.mounted) return false;
    if (result.isError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.reviewLoadError)));
      return false;
    }
    review = result.dataOrNull?.myReview;
  }
  if (!context.mounted) return false;
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProductReviewDialog(
      productId: productId,
      repository: repository,
      review: review,
    ),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.reviewSaved)));
  }
  return saved ?? false;
}

class _ProductReviewDialog extends StatefulWidget {
  const _ProductReviewDialog({
    required this.productId,
    required this.repository,
    this.review,
  });

  final int productId;
  final ProductRepository repository;
  final ProductReviewEntry? review;

  @override
  State<_ProductReviewDialog> createState() => _ProductReviewDialogState();
}

class _ProductReviewDialogState extends State<_ProductReviewDialog> {
  late int _rating = widget.review?.rating ?? 0;
  late final _comment = TextEditingController(text: widget.review?.comment);
  bool _saving = false;
  bool _failed = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _rating == 0) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _failed = false;
    });
    final comment = _comment.text.trim();
    final result = await widget.repository.saveReview(
      widget.productId,
      rating: _rating,
      comment: comment.isEmpty ? null : comment,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final ink = theme.colorScheme.onSurface;
    final muted = dark ? AppColors.grey300 : AppColors.grey700;
    final soft = dark ? AppColors.grey900 : AppColors.surfaceMuted;
    final accentSoft = dark
        ? AppColors.primaryVibrant.withValues(alpha: 0.12)
        : AppColors.primarySoft;
    final ratingLabels = [
      l10n.reviewRatingPrompt,
      l10n.reviewRatingPoor,
      l10n.reviewRatingFair,
      l10n.reviewRatingGood,
      l10n.reviewRatingVeryGood,
      l10n.reviewRatingExcellent,
    ];
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 160);
    return PopScope(
      canPop: !_saving,
      child: Dialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxl,
        ),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [accentSoft, theme.colorScheme.surface],
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.review == null
                                        ? l10n.reviewWrite
                                        : l10n.reviewEdit,
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _saving
                                      ? null
                                      : () => Navigator.pop(context),
                                  tooltip: l10n.commonClose,
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme.colorScheme.surface
                                        .withValues(alpha: 0.7),
                                    fixedSize: const Size(40, 40),
                                  ),
                                  icon: HugeIcon(
                                    icon: AppIcons.close,
                                    color: muted,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                for (var star = 1; star <= 5; star++)
                                  Expanded(
                                    child: Semantics(
                                      selected: _rating == star,
                                      child: IconButton(
                                        key: ValueKey('review-star-$star'),
                                        tooltip:
                                            '$star / 5 · ${ratingLabels[star]}',
                                        onPressed: _saving
                                            ? null
                                            : () => setState(
                                                () => _rating = star,
                                              ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 44,
                                          minHeight: 56,
                                        ),
                                        icon: AnimatedScale(
                                          scale: _rating == star ? 1.18 : 1,
                                          duration: motion,
                                          curve: Curves.easeOutBack,
                                          child: Icon(
                                            star <= _rating
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: star <= _rating
                                                ? const Color(0xFFFFB400)
                                                : dark
                                                ? AppColors.grey500
                                                : const Color(0xFFD9C5B9),
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AnimatedSwitcher(
                              duration: motion,
                              child: Wrap(
                                key: ValueKey(_rating),
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: AppSpacing.sm,
                                children: [
                                  Text(
                                    ratingLabels[_rating],
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: _rating == 0
                                              ? muted
                                              : AppColors.primaryVibrant,
                                        ),
                                  ),
                                  if (_rating > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryVibrant
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.pill,
                                        ),
                                      ),
                                      child: Text(
                                        '$_rating/5',
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                              color: AppColors.primaryVibrant,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: TextFormField(
                          controller: _comment,
                          enabled: !_saving,
                          maxLength: 2000,
                          buildCounter:
                              (
                                context, {
                                required currentLength,
                                required isFocused,
                                required maxLength,
                              }) => currentLength < 1800
                              ? null
                              : Text(
                                  '$currentLength/$maxLength',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: muted,
                                  ),
                                ),
                          minLines: 4,
                          maxLines: 6,
                          textCapitalization: TextCapitalization.sentences,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: ink,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.reviewComment,
                            hintStyle: context.textTheme.bodyMedium?.copyWith(
                              color: muted,
                            ),
                            counterStyle: context.textTheme.labelSmall
                                ?.copyWith(color: muted),
                            filled: true,
                            fillColor: soft,
                            contentPadding: const EdgeInsets.all(AppSpacing.lg),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: const BorderSide(
                                color: AppColors.primaryVibrant,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_failed) ...[
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const HugeIcon(
                                icon: AppIcons.error,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  l10n.reviewActionError,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    ProductReviewButton(
                      label: widget.review == null
                          ? l10n.reviewSubmit
                          : l10n.commonSave,
                      loading: _saving,
                      onPressed: _rating == 0 ? null : _save,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
