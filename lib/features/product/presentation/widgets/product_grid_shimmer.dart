import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/elyeter_shimmer.dart';

/// Matches the two-column catalogue while its first response is pending.
class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({
    super.key,
    this.shrinkWrap = false,
    this.itemCount = 6,
    this.padding = const EdgeInsets.all(AppSpacing.page),
  });

  const ProductGridShimmer.more({super.key})
    : shrinkWrap = true,
      itemCount = 2,
      padding = const EdgeInsets.symmetric(horizontal: AppSpacing.page);

  final bool shrinkWrap;
  final int itemCount;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: TickerMode(
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          primary: shrinkWrap ? false : null,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.57,
          ),
          itemCount: itemCount,
          itemBuilder: (_, _) => const _CardPlaceholder(),
        ),
      ),
    ),
  );
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: ElyeterShimmerBox(wordmarkSize: 24),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Shimmer.fromColors(
          baseColor: isDark ? AppColors.grey900 : AppColors.grey100,
          highlightColor: isDark ? AppColors.grey700 : AppColors.white,
          period: const Duration(milliseconds: 1400),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bar(height: 28, widthFactor: 0.45),
              SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Bar(height: 14),
                    _Bar(height: 14, widthFactor: 0.75),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _Bar(height: 40, radius: AppRadius.md),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.height,
    this.widthFactor = 1,
    this.radius = AppRadius.xs,
  });

  final double height;
  final double widthFactor;
  final double radius;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: widthFactor,
    alignment: Alignment.centerLeft,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}
