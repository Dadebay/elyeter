import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Replaces Flutter's stock [showAboutDialog]: brand mark, one line about
/// what the app is for, and a version chip — no licence page.
Future<void> showAboutAppDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const _AboutAppDialog(),
);

class _AboutAppDialog extends StatelessWidget {
  const _AboutAppDialog();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The orange logo lockup, lifted off the white card.
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SvgPicture.asset(AppAssets.logoYellow, height: 40),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppConstants.appName,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.aboutTagline,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                l10n.profileVersion(AppConstants.appVersion),
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      ),
    );
  }
}
