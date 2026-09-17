import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../model/category_filters.dart';
import 'category_sheet.dart';

/// Picks how the list is ordered.
///
/// One tap and the sheet closes: there is nothing to combine here, so a
/// confirming button would only add a step.
class CategorySortSheet extends StatelessWidget {
  const CategorySortSheet({super.key, required this.current});

  static Future<CategorySort?> show(
    BuildContext context, {
    required CategorySort current,
  }) {
    return CategorySheet.show<CategorySort>(
      context,
      builder: (_) => CategorySortSheet(current: current),
    );
  }

  final CategorySort current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String labelOf(CategorySort sort) => sort.labelIn(
      popular: l10n.categorySortPopular,
      priceAsc: l10n.categorySortPriceAsc,
      priceDesc: l10n.categorySortPriceDesc,
      discount: l10n.categorySortDiscount,
    );

    return CategorySheet(
      title: l10n.categorySortTitle,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          for (final sort in CategorySort.values)
            _Option(
              label: labelOf(sort),
              selected: sort == current,
              onTap: () => Navigator.of(context).pop(sort),
            ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.black,
                  // The chosen one carries weight as well as a tick, so it
                  // reads at a glance rather than only on inspection.
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
