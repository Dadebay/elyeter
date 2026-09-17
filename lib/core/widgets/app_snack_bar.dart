import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The app's one confirmation toast.
///
/// Material's default snack bar is a square-cornered bar pinned to the very
/// bottom, which collides with the floating nav bar and ignores the app's
/// rounding. This one floats, is rounded like every other surface, and takes
/// its type straight from [AppTypography] rather than inheriting whatever the
/// surrounding theme happens to set.
abstract final class AppSnackBar {
  /// Height of the floating nav bar, so the toast clears it.
  static const _navBarClearance = 96.0;

  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Color iconColor = AppColors.success,
    Duration duration = const Duration(seconds: 2),

    /// Pass false on pages without the shell's nav bar.
    bool overNavBar = false,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.grey900,
          elevation: 6,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          margin: EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            overNavBar ? _navBarClearance : AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
  }
}
