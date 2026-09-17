import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The strip under the subcategories: the two controls that act on the whole
/// list, then one chip per facet.
///
/// Scrolls sideways, because the chips are localized and a language with
/// longer words must not push the last one off the screen.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.facets,
    this.onFilter,
    this.onSort,
    this.onFacetTap,
  });

  static const height = 40.0;

  /// The strip's resting fill, shared by the two round controls and the
  /// inactive chips, so the row reads as one family.
  static const fill = AppColors.background;

  final List<CategoryFacet> facets;
  final VoidCallback? onFilter;
  final VoidCallback? onSort;
  final ValueChanged<CategoryFacet>? onFacetTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: [
          _IconButton(
            icon: HugeIcons.strokeRoundedFilterHorizontal,
            onTap: onFilter,
          ),
          const SizedBox(width: AppSpacing.sm),
          _IconButton(
            icon: HugeIcons.strokeRoundedArrowUpDown,
            onTap: onSort,
          ),
          const SizedBox(width: AppSpacing.sm),
          for (final facet in facets) ...[
            _FacetChip(
              facet: facet,
              onTap: onFacetTap == null ? null : () => onFacetTap!(facet),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// One facet of the list, and how many of its values are picked.
class CategoryFacet {
  const CategoryFacet({
    required this.id,
    required this.label,
    this.selectedCount = 0,
  });

  final String id;
  final String label;

  /// Zero leaves the chip plain; anything more turns it on and is counted in
  /// a badge, so the customer can see a filter is narrowing the list.
  final int selectedCount;

  bool get isActive => selectedCount > 0;
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  /// A `HugeIcons.*` constant — the package supplies glyphs as data.
  final List<List<dynamic>> icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CategoryFilterBar.fill,
      clipBehavior: Clip.antiAlias,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: CategoryFilterBar.height,
          height: CategoryFilterBar.height,
          child: Center(
            child: HugeIcon(icon: icon, size: 18, color: AppColors.black),
          ),
        ),
      ),
    );
  }
}

class _FacetChip extends StatelessWidget {
  const _FacetChip({required this.facet, required this.onTap});

  final CategoryFacet facet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = facet.isActive;
    final foreground = active ? AppColors.white : AppColors.black;

    return Material(
      color: active ? AppColors.black : CategoryFilterBar.fill,
      clipBehavior: Clip.antiAlias,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                facet.label,
                // Regular while the facet is off; weight is how an active
                // filter announces itself, so spending it on every chip
                // leaves nothing to say it with.
                style: context.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (active) ...[
                const SizedBox(width: AppSpacing.xs),
                _CountBadge(count: facet.selectedCount),
              ],
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How many values of this facet are picked.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  static const _size = 18.0;

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    width: _size,
    height: _size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: AppColors.white,
      shape: BoxShape.circle,
    ),
    child: Text(
      '$count',
      style: context.textTheme.labelSmall?.copyWith(
        color: AppColors.black,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
