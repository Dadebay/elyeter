import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../model/order_detail_data.dart';
import 'order_card.dart';

/// What the order came to, and what made it up.
class OrderTotalCard extends StatelessWidget {
  const OrderTotalCard({super.key, required this.order, this.onDownload});

  final OrderDetailData order;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return OrderCard(
      child: Column(
        children: [
          Text(l10n.orderTotalTitle, style: context.textTheme.labelSmall?.copyWith(color: AppColors.grey500)),
          const SizedBox(height: AppSpacing.xxs),
          _Total(amount: order.total),
          const SizedBox(height: AppSpacing.lg),
          _Line(label: l10n.orderProductsTotal, value: CurrencyFormatter.amount(order.productsTotal)),
          _Line(
            label: l10n.orderDeliveryLabel,
            // Free delivery is the point, so it is said in words and in the
            // colour of good news rather than as `0 TMT`.
            value: order.deliveryFee == 0 ? l10n.orderDeliveryFree : CurrencyFormatter.amount(order.deliveryFee),
            valueColor: order.deliveryFee == 0 ? AppColors.success : null,
            showCurrency: order.deliveryFee != 0,
          ),
          _Line(label: l10n.orderCargo, value: CurrencyFormatter.amount(order.cargoFee)),
          if (order.discount != 0) _Line(label: l10n.orderDiscount, value: '-${CurrencyFormatter.amount(order.discount)}', valueColor: AppColors.error),
          const SizedBox(height: AppSpacing.lg),
          _DownloadButton(onTap: onDownload),
        ],
      ),
    );
  }
}

/// The headline figure, with its currency set smaller beside it.
class _Total extends StatelessWidget {
  const _Total({required this.amount});

  final num amount;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: CurrencyFormatter.amount(amount, decimals: 2)),
            const TextSpan(text: ' '),
            TextSpan(
              text: AppConstants.currencySymbol,
              style: context.textTheme.titleMedium?.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        style: context.textTheme.displayMedium?.copyWith(color: AppColors.black, fontWeight: FontWeight.w700, letterSpacing: -0.6),
      ),
    );
  }
}

/// A label on the left, its amount on the right.
class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.valueColor, this.showCurrency = true});

  final String label;
  final String value;
  final Color? valueColor;

  /// Off for a value that is a word rather than a sum.
  final bool showCurrency;

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? AppColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: context.textTheme.labelSmall?.copyWith(fontSize: 16, color: color, fontWeight: FontWeight.w600),
                ),
                if (showCurrency) ...[
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: AppConstants.currencySymbol,
                    style: context.textTheme.labelSmall?.copyWith(color: color),
                  ),
                ],
              ],
            ),
            style: context.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey100,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.iconReceipt, width: 18, height: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(context.l10n.orderDownloadCheck, style: context.textTheme.titleSmall?.copyWith(color: AppColors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
