import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/elyeter_shimmer.dart';
import '../widgets/category_grid_tile.dart';

/// The Category tab: every department as a square card.
///
/// Cards without artwork yet are drawn as shimmering wordmarks rather than
/// blank boxes, so a half-loaded grid still looks deliberate.
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  /// Slots kept in the grid while the rest of the catalog loads.
  static const _placeholderCount = 17;

  @override
  Widget build(BuildContext context) {
    final items = _demoCategories;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            titleSpacing: AppSpacing.page,

            title: Text(
              context.l10n.categoryTitle,
              style: context.textTheme.headlineLarge?.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              // Clearance for the floating navigation bar.
              120,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md),
              delegate: SliverChildBuilderDelegate(
                (context, index) => index < items.length
                    ? CategoryGridTile(
                        item: items[index],
                        onTap: () => context.pushNamed(AppRoutes.categoryDetail.name, pathParameters: {'id': items[index].id}, queryParameters: {'title': items[index].name}),
                      )
                    : const ElyeterShimmerBox(),
                childCount: items.length + _placeholderCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stand-in until the category API lands; replace with `CategoryBloc` state.
/// Kept in step with the home strip — the same category reads the same in
/// both places.
const _demoCategories = [
  CategoryGridItem(id: 'makeup', name: 'Make Up', imageAsset: AppAssets.categoryMakeUp),
  CategoryGridItem(id: 'electronics', name: 'Electronics', imageAsset: AppAssets.categoryElectronics),
  CategoryGridItem(id: 'automotive', name: 'Automotive', imageAsset: AppAssets.categoryAutomotive),
  CategoryGridItem(id: 'stationery', name: 'Stationery', imageAsset: AppAssets.categoryStationery),
  CategoryGridItem(id: 'jewellery', name: 'Jewellery', imageAsset: AppAssets.categoryJewellery),
];
