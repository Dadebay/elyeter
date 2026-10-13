import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The empty cart: a dedicated 3D basket and a way back to the catalogue.
class CartEmptyView extends StatelessWidget {
  const CartEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.textTheme;

    return Center(
      child: Transform.translate(
        offset: const Offset(0, -kToolbarHeight / 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 200,
                child: Image.asset(
                  AppAssets.cartEmpty3d,
                  fit: BoxFit.contain,
                  semanticLabel: l10n.cartEmpty,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.cartEmpty,
                textAlign: TextAlign.center,
                style: theme.titleLarge?.copyWith(
                  fontFamily: AppTypography.fontFamily,
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  l10n.cartEmptyMessage,
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium?.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    color: AppColors.grey500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: () => context.goNamed(AppRoutes.home.name),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl,
                  ),
                ),
                child: Text(
                  l10n.cartEmptyAction,
                  style: theme.labelLarge?.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
