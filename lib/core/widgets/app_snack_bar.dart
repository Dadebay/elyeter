import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../constants/app_icons.dart';

/// The app's one confirmation toast.
///
/// The floating shape, the inset from both screen edges and the rounding
/// come from `snackBarTheme` in [AppTheme], so a plain `SnackBar(...)` looks
/// the same as this one. What this adds is the leading glyph, the clearance
/// over the floating nav bar on the tab roots, and type taken straight from
/// [AppTypography] rather than from whatever theme happens to be in scope.
abstract final class AppSnackBar {
  /// Height of the floating nav bar, so the toast clears it.
  static const _navBarClearance = 96.0;

  static void show(
    BuildContext context,
    String message, {
    AppIconData icon = AppIcons.checkCircle,
    Color iconColor = AppColors.success,
    Duration duration = const Duration(seconds: 2),

    /// Pass true on the tab roots, which carry the shell's floating nav bar.
    bool overNavBar = false,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        build(
          message,
          icon: icon,
          iconColor: iconColor,
          duration: duration,
          overNavBar: overNavBar,
        ),
      );
  }

  /// The bar itself, for a caller that already holds a `ScaffoldMessenger`
  /// — the usual reason being that it captured one before an `await` and no
  /// longer has a context it may use.
  static SnackBar build(
    String message, {
    AppIconData icon = AppIcons.checkCircle,
    Color iconColor = AppColors.success,
    Duration duration = const Duration(seconds: 2),
    bool overNavBar = false,
  }) => SnackBar(
    content: Row(
      children: [
        HugeIcon(icon: icon, size: 20, color: iconColor),
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
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    // The only geometry worth overriding: on a tab root the toast has to
    // clear the floating nav bar. Everything else — the float, the side
    // insets, the rounding — is the theme's.
    margin: EdgeInsets.fromLTRB(
      AppSpacing.page,
      0,
      AppSpacing.page,
      overNavBar ? _navBarClearance : AppSpacing.lg,
    ),
  );
}
