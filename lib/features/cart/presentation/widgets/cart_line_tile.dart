import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../product/presentation/widgets/product_card.dart';

/// One line of the cart: photo, title and specs, a quantity stepper, the line
/// price and the tick that keeps it in the total.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    super.key,
    required this.product,
    required this.quantity,
    required this.selected,
    required this.isFavorite,
    required this.onIncrease,
    required this.onDecrease,
    required this.onSelectedChanged,
    required this.onFavoriteTap,
  });

  static const _photoSize = 104.0;

  /// How many spec lines fit before the row gets taller than its photo.
  static const _maxSpecs = 2;

  final ProductCardData product;
  final int quantity;
  final bool selected;
  final bool isFavorite;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onSelectedChanged;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Photo(product: product, isFavorite: isFavorite, onFavoriteTap: onFavoriteTap),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        // Weight, not size, is what lifts the product name
                        // above its specs — it gains presence without
                        // taking another line.
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _Tick(value: selected, onTap: onSelectedChanged),
                  ],
                ),
                for (final spec in product.specs.take(_maxSpecs)) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    spec,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Stepper(quantity: quantity, onIncrease: onIncrease, onDecrease: onDecrease),
                    const SizedBox(width: AppSpacing.sm),
                    // The stepper keeps its size; the price takes what is
                    // left and scales down rather than overflowing on a
                    // narrow screen or a five-figure line total.
                    Expanded(
                      child: _LinePrice(product: product, quantity: quantity),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The product photo with the favourite toggle over its corner.
class _Photo extends StatelessWidget {
  const _Photo({required this.product, required this.isFavorite, required this.onFavoriteTap});

  final ProductCardData product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final image = product.images.isEmpty ? null : product.images.first;

    return SizedBox(
      width: CartLineTile._photoSize,
      height: CartLineTile._photoSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: image == null
                  ? const Icon(Icons.image_outlined, color: AppColors.grey500)
                  : Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Image.asset(image, fit: BoxFit.contain),
                    ),
            ),
          ),
          // The catalog card's heart, so the same product reads the same in
          // the grid and in the cart.
          Positioned(
            top: FavoriteButton.cornerInset,
            right: FavoriteButton.cornerInset,
            child: FavoriteButton(active: isFavorite, onTap: onFavoriteTap),
          ),
        ],
      ),
    );
  }
}

/// `-  n  +`: two raised white discs riding a soft grey track, as the design
/// draws it.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.quantity, required this.onIncrease, required this.onDecrease});

  /// Height of the track; the discs sit inside it with [_inset] to spare.
  static const _trackHeight = 40.0;
  static const _inset = 3.0;

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _trackHeight,
      padding: const EdgeInsets.all(_inset),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(
          _StepButton._radius + _inset,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove_rounded, onTap: onDecrease),
          // Fixed width so the pill does not resize between 9 and 10.
          SizedBox(
            width: 34,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _StepButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  static const _size = _Stepper._trackHeight - _Stepper._inset * 2;

  /// Rounded square rather than a disc, as the design draws it.
  static const _radius = AppRadius.md;

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Icon(icon, size: 18, color: AppColors.grey700),
        ),
      ),
    );
  }
}

/// Line total, with the old price and the saving under it.
class _LinePrice extends StatelessWidget {
  const _LinePrice({required this.product, required this.quantity});

  final ProductCardData product;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ShrinkToFit(
          child: Text(
            '${CurrencyFormatter.amount(product.price * quantity)} ${AppConstants.currencySymbol}',
            maxLines: 1,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (discount != null) ...[
          const SizedBox(height: 2),
          _ShrinkToFit(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${CurrencyFormatter.amount(product.oldPrice! * quantity)} '
                  '${AppConstants.currencySymbol}',
                  maxLines: 1,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.error,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '-$discount%',
                  style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Right-aligned, and never wider than the room it is given.
class _ShrinkToFit extends StatelessWidget {
  const _ShrinkToFit({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: child);
}

/// Square tick box, filled black when the line counts towards the total.
class _Tick extends StatelessWidget {
  const _Tick({required this.value, required this.onTap});

  static const size = 24.0;

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: value ? AppColors.black : AppColors.grey300, width: 1.5),
        ),
        child: value ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white) : null,
      ),
    );
  }
}

/// Exposed so the page's "Select All" box matches the per-line ones.
class CartTickBox extends StatelessWidget {
  const CartTickBox({super.key, required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Tick(value: value, onTap: onTap);
}
