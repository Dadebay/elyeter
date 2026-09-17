import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../view/product_photo_viewer_page.dart';

/// The detail page's photo pager.
///
/// Each photo is its own card and the next one is left showing at the right
/// edge, so it is obvious there is more to swipe to without a row of dots.
class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key, required this.images, this.height = 320});

  final List<String> images;
  final double height;

  /// Share of the width one card takes; the rest is the next card peeking.
  static const _viewportFraction = 0.9;

  /// Margin down the left of every card, which is also the gap between two
  /// of them. The pager itself runs edge to edge so the peeking card reaches
  /// the screen's rim instead of stopping short of it.
  static const _cardMargin = AppSpacing.page;

  /// How far the photo counter sits from the right edge.
  static const _counterInset = 20.0;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final _controller = PageController(viewportFraction: ProductGallery._viewportFraction);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;
    if (count == 0) {
      return SizedBox(
        height: widget.height,
        child: const AppNetworkImage(url: null, radius: AppRadius.lg),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: count,
              onPageChanged: (index) => setState(() => _page = index),
              // Cards run from the left edge instead of being centred, so
              // the peeking one is always on the right.
              padEnds: false,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: ProductGallery._cardMargin),
                child: _Photo(
                  image: widget.images[index],
                  heroTag: 'product-photo-$index',
                  onTap: () => ProductPhotoViewerPage.open(
                    context,
                    images: widget.images,
                    initialIndex: index,
                  ),
                ),
              ),
            ),
          ),
          if (count > 1)
            Positioned(
              right: ProductGallery._counterInset,
              bottom: AppSpacing.md,
              // Outside the pager, so it holds its corner while the photos
              // slide past underneath.
              child: IgnorePointer(
                child: _Counter(index: _page + 1, total: count),
              ),
            ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({
    required this.image,
    required this.heroTag,
    required this.onTap,
  });

  final String image;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: ColoredBox(
          color: AppColors.grey100,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Hero(
              tag: heroTag,
              child: Image.asset(image, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

/// `1 of 6` — a counter rather than dots, which stay legible past five photos.
class _Counter extends StatelessWidget {
  const _Counter({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
        child: Text(
          '$index of $total',
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
