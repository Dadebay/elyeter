import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The quiet full-width action the detail page repeats: a white card lifted
/// off the grey block by a soft shadow rather than outlined.
class ProductOutlineButton extends StatelessWidget {
  const ProductOutlineButton({super.key, required this.label, this.onTap, this.height = 48});

  final String label;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(color: AppColors.black),
            ),
          ),
        ),
      ),
    );
  }
}
