import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'promo_banner_card.dart';

export 'promo_banner_card.dart' show PromoBanner, PromoBannerCard;

/// Swipeable banner deck. The page dots sit on the artwork itself, near the
/// bottom edge of the card.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
    required this.banners,
    this.height = 150,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.centerLeft,
  });

  final List<PromoBanner> banners;
  final double height;
  final ValueChanged<PromoBanner>? onTap;

  /// Spacing around the whole deck; the caller owns it.
  final EdgeInsetsGeometry margin;

  /// How each banner's artwork fills its card.
  final BoxFit fit;

  /// Which edge of the artwork is kept when [fit] crops.
  final Alignment alignment;

  /// Share of the viewport one card takes, leaving the next one peeking.
  static const _viewportFraction = 0.92;

  /// Half the gap between two cards.
  static const _cardGap = AppSpacing.xs;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController(viewportFraction: PromoCarousel._viewportFraction);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: widget.margin,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PromoCarousel._cardGap),
                  child: PromoBannerCard(
                    banner: banner,
                    fit: widget.fit,
                    alignment: widget.alignment,
                    onTap: widget.onTap == null ? null : () => widget.onTap!(banner),
                  ),
                );
              },
            ),
            // On the artwork rather than under it, so the deck is one block.
            if (widget.banners.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.md,
                child: IgnorePointer(
                  child: Center(
                    child: _Dots(count: widget.banners.length, index: _page),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Page dots in a translucent pill, so they read over any photo.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: AppColors.black.withValues(alpha: 0.28), borderRadius: BorderRadius.circular(AppRadius.pill)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              height: 6,
              width: i == index ? 16 : 6,
              decoration: BoxDecoration(color: i == index ? AppColors.white : AppColors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(AppRadius.pill)),
            ),
        ],
      ),
    ),
  );
}
