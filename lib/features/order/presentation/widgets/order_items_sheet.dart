import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../product/presentation/widgets/product_image_view.dart';
import '../../domain/entities/pre_order.dart';

/// Every line of an order, as it was when it was placed: photo, name, the
/// variant that was picked, quantity at price, and what the line came to.
///
/// [photos] maps a product slug to the photo to show for it; a line without
/// one falls back to the photo the order itself carries.
Future<void> showOrderItemsSheet(
  BuildContext context, {
  required PreOrder order,
  required Map<String, String> photos,
  required void Function(String slug) onOpenProduct,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    barrierColor: AppColors.black.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    builder: (sheetContext) => _ItemsSheet(
      order: order,
      photos: photos,
      onOpenProduct: (slug) {
        Navigator.of(sheetContext).pop();
        onOpenProduct(slug);
      },
    ),
  );
}

class _ItemsSheet extends StatelessWidget {
  const _ItemsSheet({
    required this.order,
    required this.photos,
    required this.onOpenProduct,
  });

  final PreOrder order;
  final Map<String, String> photos;
  final void Function(String slug) onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.textTheme;
    final units = order.items.fold<int>(0, (sum, i) => sum + i.quantity);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderProducts,
                        style: theme.titleLarge?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.orderItemCount(
                          order.items.isEmpty ? order.itemsCount : units,
                        ),
                        style: theme.labelMedium?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.background,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Center(
                        child: HugeIcon(
                          icon: AppIcons.close,
                          size: 14,
                          strokeWidth: 2.2,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.grey100),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              itemCount: order.items.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.grey100),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _ItemRow(
                  item: item,
                  currency: order.currency,
                  photo: photos[item.productSlug] ?? item.image,
                  onTap: item.productSlug == null
                      ? null
                      : () => onOpenProduct(item.productSlug!),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.grey100),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.orderTotalTitle,
                    style: theme.titleSmall?.copyWith(color: AppColors.grey700),
                  ),
                ),
                Text(
                  '${CurrencyFormatter.amount(order.totalPrice, decimals: 2)} ${order.currency}',
                  style: theme.titleLarge?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.currency,
    required this.photo,
    required this.onTap,
  });

  static const _thumb = 68.0;

  final PreOrderItem item;
  final String currency;
  final String? photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox.square(
                dimension: _thumb,
                child: ColoredBox(
                  color: AppColors.grey100,
                  child: photo == null
                      ? const Center(
                          child: HugeIcon(
                            icon: AppIcons.image,
                            size: 22,
                            color: AppColors.grey500,
                          ),
                        )
                      : ProductImageView(
                          source: photo!,
                          fit: BoxFit.cover,
                          fallbackIconSize: 22,
                        ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.variant != null && item.variant!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        child: Text(
                          item.variant!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.labelSmall?.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        '${item.quantity} × ${CurrencyFormatter.amount(item.price)} $currency',
                        style: theme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${CurrencyFormatter.amount(item.lineTotal)} ${AppConstants.currencySymbol}',
                        style: theme.titleSmall?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
