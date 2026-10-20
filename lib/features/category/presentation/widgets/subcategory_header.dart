import 'package:flutter/material.dart';

/// The subcategories as a header that scrolls away with a little ceremony:
/// the block shrinks out of the way like any scrolled item, but its contents
/// also fade, drift up and settle back in scale as it goes, instead of simply
/// being cut off at the edge.
///
/// [extent] must be the height of [child]; the block is laid out at that
/// height throughout and only revealed, so nothing reflows while it collapses.
class SubcategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SubcategoryHeaderDelegate({required this.extent, required this.child});

  final double extent;
  final Widget child;

  /// How far the contents drift up by the time they are gone.
  static const _drift = 16.0;

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / extent).clamp(0.0, 1.0);
    // Fully gone a little before the block is, so the last of it is not a
    // faint smear against the filter bar.
    final fade = Curves.easeIn.transform((progress * 1.25).clamp(0.0, 1.0));

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: extent,
        maxHeight: extent,
        child: Opacity(
          opacity: 1 - fade,
          child: Transform.translate(
            offset: Offset(0, -_drift * progress),
            child: Transform.scale(
              scale: 1 - 0.06 * progress,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SubcategoryHeaderDelegate oldDelegate) =>
      extent != oldDelegate.extent || child != oldDelegate.child;
}
