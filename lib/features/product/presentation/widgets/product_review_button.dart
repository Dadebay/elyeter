import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_loader.dart';

class ProductReviewButton extends StatelessWidget {
  const ProductReviewButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: onPressed != null || loading ? AppColors.primaryGradient : null,
      color: AppColors.primaryFade,
      borderRadius: BorderRadius.circular(28),
    ),
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        disabledForegroundColor: AppColors.white,
        shadowColor: Colors.transparent,
        minimumSize: const Size(double.infinity, 56),
        shape: const StadiumBorder(),
        textStyle: context.textTheme.titleMedium,
      ),
      child: loading
          ? const AppLoader(size: 22, color: AppColors.white)
          : Text(label),
    ),
  );
}
