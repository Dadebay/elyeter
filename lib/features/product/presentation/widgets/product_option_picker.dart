import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The colourway strip: the product's own photos as selectable swatches.
class ProductColorPicker extends StatelessWidget {
  const ProductColorPicker({
    super.key,
    required this.images,
    required this.selected,
    required this.onSelected,
  });

  static const _size = 72.0;

  final List<String> images;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final active = index == selected;
          return GestureDetector(
            onTap: () => onSelected(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: _size,
              height: _size,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.md),
                // Black, not the brand orange: the swatch's own colour is
                // what the customer is choosing, so the marker stays neutral.
                border: Border.all(
                  color: active ? AppColors.black : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Image.asset(images[index], fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}

/// Size chips. One is always selected, as a size must be chosen to order.
class ProductSizePicker extends StatelessWidget {
  const ProductSizePicker({
    super.key,
    required this.sizes,
    required this.selected,
    required this.onSelected,
  });

  final List<String> sizes;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final size in sizes)
          GestureDetector(
            onTap: () => onSelected(size),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              constraints: const BoxConstraints(minWidth: 56),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: size == selected ? AppColors.black : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                size,
                textAlign: TextAlign.center,
                style: context.textTheme.titleSmall?.copyWith(color: AppColors.black),
              ),
            ),
          ),
      ],
    );
  }
}
