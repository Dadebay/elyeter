import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/counting_number.dart';

/// The pill that floats over the list: how many products are ticked and what
/// they come to, with the undiscounted total struck out beside it.
///
/// A translucent material rather than a solid bar — the cart scrolls
/// underneath it and stays legible through the blur, so the pill reads as a
/// layer above the list instead of a strip cut out of it.
class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    super.key,
    required this.productCount,
    required this.total,
    required this.oldTotal,
    this.onTap,
  });

  /// A wide surface should read as thick — a heavier blur than a small chip
  /// would take.
  static const _blur = 30.0;

  /// Enough tint to keep the brand colour and carry text, sheer enough that
  /// the product photos still move underneath, blurred, through the glass.
  static const _tint = 0.78;

  final int productCount;
  final num total;

  /// Total before discounts; struck out when it is higher than [total].
  final num oldTotal;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl);

    // Accessibility setting for reduced transparency: frost the surface
    // solid rather than asking anyone to read through a blur.
    final opaque = MediaQuery.highContrastOf(context);

    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: _Row(
            productCount: productCount,
            total: total,
            oldTotal: oldTotal,
          ),
        ),
      ),
    );

    // Frosted orange glass: the brand colour, brightest at the top and
    // settling toward the bottom, with a hair of white at the edge where
    // light catches it.
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        gradient: opaque
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.22),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
        color: opaque
            ? AppColors.primarySoft
            : AppColors.primary.withValues(alpha: _tint),
        borderRadius: radius,
        border: opaque
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: content,
    );

    return DecoratedBox(
      // Outside the clip, so the shadow is not cut away with the blur.
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          // Just enough to lift the pill off the list; the design shows
          // separation, not a drop shadow.
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: opaque
            ? surface
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                child: surface,
              ),
      ),
    );
  }
}

/// Count on the left, totals on the right.
///
/// Type over a translucent surface carries a little more weight than it
/// would on a solid one — light and flat goes muddy once the photos
/// underneath start moving.
class _Row extends StatelessWidget {
  const _Row({
    required this.productCount,
    required this.total,
    required this.oldTotal,
  });

  final int productCount;
  final num total;
  final num oldTotal;

  @override
  Widget build(BuildContext context) {
    final saved = oldTotal > total;

    return Row(
      children: [
        // Its own width and no more. As a Flexible it was handed half the free
        // space whether it used it or not, which left a gap at the right end
        // that the totals could not reach.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            context.l10n.cartProductCount(productCount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // The totals keep their place; they shrink before the label gets
        // clipped.
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (saved) ...[
                  CountingNumber(
                    value: oldTotal,
                    builder: (shown) => Text(
                      '${CurrencyFormatter.amount(shown)} '
                      '${AppConstants.currencySymbol}',
                      style: context.textTheme.bodySmall?.copyWith(
                        // Red would sink into the orange; a muted ink reads on it.
                        color: AppColors.black.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.black.withValues(
                          alpha: 0.55,
                        ),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                CountingNumber(
                  value: total,
                  builder: (shown) => Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: CurrencyFormatter.amount(shown)),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: AppConstants.currencySymbol,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w800,
                      // Large, heavy figures read too loose at their default
                      // tracking; tighten as the size goes up.
                      letterSpacing: -0.2,
                      // Digits all as wide as each other, so the figure does
                      // not shimmy sideways while it counts.
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
