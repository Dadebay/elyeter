import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';

/// A promo banner.
///
/// Artwork that already carries its own headline passes only an image; the
/// [title]/[subtitle] overlay is for banners whose text comes from the API.
class PromoBanner {
  const PromoBanner({required this.id, this.title, this.subtitle, this.imageUrl, this.imageAsset});

  final String id;
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? imageAsset;

  /// Whether anything is drawn on top of the artwork.
  bool get hasOverlay => title != null || subtitle != null;
}

/// One banner on its own: rounded artwork, optional headline over it.
///
/// Usable outside [PromoCarousel] — it fills whatever box it is given, so the
/// caller decides size and spacing.
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, required this.banner, this.onTap, this.radius = AppRadius.lg, this.fit = BoxFit.cover, this.alignment = Alignment.centerLeft});

  final PromoBanner banner;
  final VoidCallback? onTap;
  final double radius;

  /// How the artwork fills the card. Applies whether the banner comes from an
  /// asset or from the network.
  final BoxFit fit;

  /// Which part of the artwork survives when [fit] has to crop. These banners
  /// carry their headline on the left, so that edge is kept by default and the
  /// crop is taken off the right.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.imageAsset != null) Image.asset(banner.imageAsset!, fit: fit, alignment: alignment) else AppNetworkImage(url: banner.imageUrl, fit: fit, alignment: alignment, radius: 0),
            if (banner.hasOverlay) _BannerText(banner: banner),
          ],
        ),
      ),
    );
  }
}

/// Headline and subtitle over artwork that does not carry its own.
class _BannerText extends StatelessWidget {
  const _BannerText({required this.banner});

  /// How much of the card's width the text is allowed to take.
  static const _widthFraction = 0.52;

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          // Keeps the headline readable over any artwork.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xB3000000), Color(0x00000000)]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: constraints.maxWidth * _widthFraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (banner.title != null) Text(banner.title!, style: textTheme.headlineSmall?.copyWith(color: AppColors.white)),
                  if (banner.subtitle != null) ...[const SizedBox(height: AppSpacing.sm), Text(banner.subtitle!, style: textTheme.bodySmall?.copyWith(color: AppColors.white.withValues(alpha: 0.9)))],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
