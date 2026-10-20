import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CategoryStripShimmer extends StatelessWidget {
  const CategoryStripShimmer({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 98,
    child: _HomeShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, _) => const SizedBox(
          width: 72,
          child: Column(
            children: [
              _Block(width: 72, height: 72, radius: AppRadius.lg),
              SizedBox(height: AppSpacing.xs),
              _Block(width: 56, height: 12, radius: AppRadius.xs),
            ],
          ),
        ),
      ),
    ),
  );
}

class BrandStripShimmer extends StatelessWidget {
  const BrandStripShimmer({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 66,
    margin: const EdgeInsets.only(top: AppSpacing.md),
    child: _HomeShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, _) =>
            const _Block(width: 107, height: 66, radius: AppRadius.lg),
      ),
    ),
  );
}

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: _HomeShimmer(
      child: FractionallySizedBox(
        widthFactor: 0.92,
        alignment: Alignment.centerLeft,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: _Block(radius: AppRadius.lg),
        ),
      ),
    ),
  );
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: TickerMode(
          enabled: !MediaQuery.disableAnimationsOf(context),
          child: Shimmer.fromColors(
            baseColor: isDark ? AppColors.grey900 : AppColors.grey100,
            highlightColor: isDark ? AppColors.grey700 : AppColors.white,
            period: const Duration(milliseconds: 1400),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({this.width, this.height, required this.radius});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
