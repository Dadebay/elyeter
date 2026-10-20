import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';

/// Opens the floating price breakdown above the app's bottom navigation.
Future<void> showProductPriceDetailsSheet(
  BuildContext context, {
  required String name,
  required num price,
  num? oldPrice,
}) => showGeneralDialog<void>(
  context: context,
  useRootNavigator: true,
  barrierDismissible: true,
  barrierLabel: context.l10n.commonClose,
  barrierColor: Colors.black.withValues(alpha: 0.24),
  transitionDuration: const Duration(milliseconds: 260),
  transitionBuilder: (context, animation, secondaryAnimation, child) => child,
  pageBuilder: (context, animation, secondaryAnimation) => _PriceSheetOverlay(
    animation: animation,
    name: name,
    price: price,
    oldPrice: oldPrice,
  ),
);

class _PriceSheetOverlay extends StatelessWidget {
  const _PriceSheetOverlay({
    required this.animation,
    required this.name,
    required this.price,
    required this.oldPrice,
  });

  final Animation<double> animation;
  final String name;
  final num price;
  final num? oldPrice;

  @override
  Widget build(BuildContext context) {
    final bottomGap = math.max(12.0, MediaQuery.viewPaddingOf(context).bottom);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: animation,
      child: _PriceSheet(name: name, price: price, oldPrice: oldPrice),
      builder: (context, sheet) {
        final progress = animation.status == AnimationStatus.reverse
            ? Curves.easeInCubic.transform(animation.value)
            : Curves.easeOutCubic.transform(animation.value);
        return SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: progress,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, bottomGap),
                  child: Opacity(
                    opacity: progress,
                    child: Transform.translate(
                      offset: Offset(0, reduceMotion ? 0 : (1 - progress) * 32),
                      child: sheet,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceSheet extends StatelessWidget {
  const _PriceSheet({
    required this.name,
    required this.price,
    required this.oldPrice,
  });

  static const _priceColor = Color(0xFFAD1F2A);
  final String name;
  final num price;
  final num? oldPrice;

  @override
  Widget build(BuildContext context) {
    final regular = oldPrice != null && oldPrice! > price ? oldPrice! : price;
    final savings = regular - price;
    final percent = savings > 0 ? (savings / regular * 100).round() : 0;

    return Material(
      key: const Key('product-price-details-sheet'),
      color: AppColors.white,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.productPriceDetails,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Material(
                      color: AppColors.background,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: context.l10n.commonClose,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const HugeIcon(
                          icon: AppIcons.close,
                          size: 18,
                          color: AppColors.grey700,
                        ),
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              CurrencyFormatter.amount(
                                price,
                                locale: context.l10n.localeName,
                              ),
                              style: context.textTheme.headlineLarge?.copyWith(
                                color: _priceColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppConstants.currencySymbol,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: _priceColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          context.l10n.productPricePerItem,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: _priceColor,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _PriceRow(
                          label: context.l10n.productRegularPrice,
                          value: CurrencyFormatter.format(
                            regular,
                            locale: context.l10n.localeName,
                            decimals: 0,
                          ),
                          strikeThrough: savings > 0,
                        ),
                        if (savings > 0) ...[
                          const SizedBox(height: 6),
                          _PriceRow(
                            label: context.l10n.productDiscountPercent(percent),
                            value: CurrencyFormatter.format(
                              savings,
                              locale: context.l10n.localeName,
                              decimals: 0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.strikeThrough = false,
  });

  final String label;
  final String value;
  final bool strikeThrough;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(color: AppColors.black),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Text(
        value,
        style: context.textTheme.bodySmall?.copyWith(
          color: AppColors.black,
          decoration: strikeThrough ? TextDecoration.lineThrough : null,
        ),
      ),
    ],
  );
}
