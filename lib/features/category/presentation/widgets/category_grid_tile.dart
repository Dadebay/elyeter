import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_network_image.dart';

/// One card in the categories grid.
class CategoryGridItem {
  const CategoryGridItem({required this.id, required this.name, this.imageAsset, this.imageUrl});

  final String id;
  final String name;
  final String? imageAsset;
  final String? imageUrl;
}

/// Square card: the name sits top-left and the artwork fills the lower
/// half, bleeding past the card's edges so it reads as a photo cropped by
/// the card rather than an icon floating in a box.
class CategoryGridTile extends StatelessWidget {
  const CategoryGridTile({super.key, required this.item, this.onTap});

  final CategoryGridItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        // A white card on a white page needs a lift, not a border.
        boxShadow: isDark ? null : const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(_radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Deliberately overflowing on three sides; the card clips it.
              Positioned(
                top: 30,
                left: -2,
                right: -8,
                bottom: -10,
                child: switch (item) {
                  CategoryGridItem(:final imageAsset?) => AppAssetImage(imageAsset, fit: BoxFit.contain),
                  CategoryGridItem(:final imageUrl?) => AppNetworkImage(url: imageUrl, radius: 0),
                  _ => const SizedBox.shrink(),
                },
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.sm,
                top: AppSpacing.md,
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: isDark ? AppColors.white : AppColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _radius = 24.0;
}
