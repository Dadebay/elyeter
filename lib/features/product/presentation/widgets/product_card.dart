import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/cart_fly_animation.dart';
import '../../../../core/widgets/favorite_button.dart';

/// Minimal shape a card needs to render. Swap for the real entity once the
/// product API lands — only this type changes, not the layout.
class ProductCardData {
  const ProductCardData({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    this.images = const [],
    this.specs = const [],
    this.attributes = const {},
  });

  final String id;
  final String title;
  final num price;

  /// Price before the discount; drives the `-20%` badge.
  final num? oldPrice;

  /// Every photo of the product, in order. An entry is a bundled asset when
  /// it starts with `assets/`, otherwise a URL — so placeholder artwork and
  /// API images can sit in the same list.
  final List<String> images;

  /// Short attribute lines ("Material: Jewelry Alloy"). Listed on a cart
  /// line; the catalog card has no room for them.
  final List<String> specs;

  /// Facet id to value, e.g. `{'brand': 'Apple', 'color': 'Black'}`. What the
  /// category filters match on — derived facet options come from these, so a
  /// filter can never offer a value nothing carries. Empty until the API
  /// supplies them, which simply leaves the product out of every facet.
  final Map<String, String> attributes;

  /// Whole percent off, or null when the product is not discounted.
  int? get discountPercent {
    final was = oldPrice;
    if (was == null || was <= price) return null;
    return ((was - price) / was * 100).round();
  }
}

/// Catalog tile: swipeable photos, price, title, add-to-cart — the card used
/// in the home grid, category lists and search results.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.data,
    this.onTap,
    this.onAddToCart,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.isInCart = false,
    this.addToCartLabel,
    this.addedLabel,
  });

  final ProductCardData data;

  /// Whether this product is in the customer's favourites. Owned by the page,
  /// so the same product reads the same everywhere it is listed.
  final bool isFavorite;

  /// Whether this product is already in the cart; flips the button to its
  /// "Added" state.
  final bool isInCart;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavoriteTap;
  /// Both default to the localized strings; pass them only to override.
  final String? addToCartLabel;
  final String? addedLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loose Flexible: the image keeps its square shape when there is
          // room and gives some back when the grid cell is short, instead of
          // overflowing the column.
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: _Gallery(
                images: data.images,
                discountPercent: data.discountPercent,
                isFavorite: isFavorite,
                onFavoriteTap: onFavoriteTap,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _Price(price: data.price),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
          ),
          const SizedBox(height: AppSpacing.md),
          _AddToCartButton(
            label: isInCart
                ? (addedLabel ?? context.l10n.commonAdded)
                : (addToCartLabel ?? context.l10n.commonAddToCart),
            added: isInCart,
            // Only the photo of the product being added flies; taking it back
            // out gets no flourish.
            flyImage: data.images.isEmpty ? null : data.images.first,
            onTap: onAddToCart,
          ),
        ],
      ),
    );
  }
}

/// The photo area: swipeable images with the favourite button, the discount
/// badge and the page dots laid over them.
class _Gallery extends StatefulWidget {
  const _Gallery({
    required this.images,
    required this.discountPercent,
    required this.isFavorite,
    this.onFavoriteTap,
  });

  final List<String> images;
  final int? discountPercent;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: ColoredBox(
        color: AppColors.grey100,
        child: Stack(
          children: [
            Positioned.fill(
              child: count == 0
                  ? const AppNetworkImage(url: null, radius: 0)
                  : PageView.builder(
                      controller: _controller,
                      itemCount: count,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (context, index) => _Photo(widget.images[index]),
                    ),
            ),
            Positioned(
              // The button carries its own transparent padding, so it sits
              // closer to the corner than the badges do.
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: FavoriteButton(active: widget.isFavorite, onTap: widget.onFavoriteTap),
            ),
            if (widget.discountPercent != null)
              Positioned(
                // Nearly flush: the artwork brings most of the inset itself.
                left: 2,
                bottom: 2,
                child: _DiscountBadge(percent: widget.discountPercent!),
              ),
            if (count > 1)
              Positioned(
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: IgnorePointer(child: _Dots(count: count, index: _page)),
              ),
          ],
        ),
      ),
    );
  }
}

/// One photo, from the bundle or the network depending on the path.
class _Photo extends StatelessWidget {
  const _Photo(this.source);

  final String source;

  @override
  Widget build(BuildContext context) {
    return source.startsWith('assets/')
        ? Image.asset(source, fit: BoxFit.contain)
        : AppNetworkImage(url: source, fit: BoxFit.contain, radius: 0);
  }
}

/// `-20%`, bottom left of the photo: the supplied ticket artwork with the
/// live percentage drawn over it.
class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  /// The artwork is drawn smaller than its natural 70x40; at card size the
  /// full-size ticket crowds the photo. It keeps its aspect ratio, and with
  /// it the 8px of transparent shadow padding that scales to ~6px.
  static const _width = 56.0;
  static const _height = 32.0;

  /// Room the number has inside the ticket, clear of the two notches.
  static const _textInset = 13.0;

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(AppAssets.iconDiscountBanner, width: _width, height: _height),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _textInset),
            child: FittedBox(
              // -5% and -100% both have to sit inside a fixed-width ticket.
              child: Text(
                '-$percent%',
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Which photo is showing, bottom right of the photo.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  /// Beyond this the dots stop being readable at card size.
  static const _maxDots = 5;

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, _maxDots);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < shown; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: i == index ? 10 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: i == index ? AppColors.grey900 : AppColors.grey300,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `7 526 TMT` — the amount and the currency are styled separately.
class _Price extends StatelessWidget {
  const _Price({required this.price});

  final num price;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          CurrencyFormatter.amount(price),
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          AppConstants.currencySymbol,
          style: context.textTheme.labelSmall?.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}

/// Grey while the product can still be added, brand-orange with a tick once
/// it is in the cart. Tapping it again takes the product back out.
class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({required this.label, required this.added, this.flyImage, this.onTap});

  /// The glyph box, sized so both states lay out identically.
  static const _iconSlot = 20.0;
  static const _iconSize = 18.0;

  final String label;
  final bool added;

  /// Photo that flies to the cart tab when the product is added.
  final String? flyImage;

  final VoidCallback? onTap;

  /// Runs the flourish from this button, then does the actual add. The
  /// button's own context is the flight's starting point.
  void _handleTap(BuildContext context) {
    if (!added) CartFlyAnimation.runFrom(fromContext: context, image: flyImage);
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final foreground = added ? AppColors.white : AppColors.black;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: added ? AppColors.primary : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null ? null : () => _handleTap(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // A fixed slot for either glyph: the two states differ in
                // artwork, so without it the button's height would jump as it
                // flips.
                SizedBox(
                  width: _iconSlot,
                  height: _iconSlot,
                  child: Center(
                    child: added
                        ? Icon(Icons.check_rounded, size: _iconSize, color: foreground)
                        : SvgPicture.asset(
                            AppAssets.iconCart,
                            width: _iconSize,
                            height: _iconSize,
                            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge?.copyWith(color: foreground),
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

