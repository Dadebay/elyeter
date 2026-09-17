import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_network_image.dart';

/// One partner marketplace tile (AliExpress, Taobao, …).
class MarketplaceItem {
  const MarketplaceItem({required this.id, required this.name, this.logoUrl, this.logoAsset});

  /// Route slug — see `AppRoutes.marketplace`.
  final String id;

  final String name;
  final String? logoUrl;
  final String? logoAsset;
}

/// Horizontally scrolling row of partner marketplaces under the logo.
class MarketplaceStrip extends StatelessWidget {
  const MarketplaceStrip({super.key, required this.items, this.onTap, this.height = 64});

  final List<MarketplaceItem> items;
  final ValueChanged<MarketplaceItem>? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => _MarketplaceCard(
          item: items[index],
          onTap: onTap == null ? null : () => onTap!(items[index]),
        ),
      ),
    );
  }
}

class _MarketplaceCard extends StatelessWidget {
  const _MarketplaceCard({required this.item, this.onTap});

  final MarketplaceItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
      width: 104,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18)),
        child: switch (item) {
          MarketplaceItem(:final logoAsset?) => AppAssetImage(logoAsset),
          MarketplaceItem(:final logoUrl?) => AppNetworkImage(url: logoUrl, radius: 0),
          // Until a logo asset lands, the name keeps the layout honest.
          _ => Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
        },
      ),
    );
  }
}
