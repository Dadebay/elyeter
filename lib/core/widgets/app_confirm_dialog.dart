import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

/// The app's yes/no dialog: a badge, one question, and two ways out.
///
/// Built on [Dialog] rather than [AlertDialog] for the same reasons the
/// language and about dialogs are: Material 3 tints an [AlertDialog]'s
/// surface with the seed colour, which turns a white card pink under this
/// app's orange, and its action bar wraps wide buttons into a ragged
/// column. Here the actions are stacked on purpose — the primary one
/// full-width, the way out quiet underneath it.
///
/// Returns true only when the customer confirmed; dismissing by tapping
/// outside or pressing back returns false.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required Widget icon,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _AppConfirmDialog(
      icon: icon,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return confirmed ?? false;
}

class _AppConfirmDialog extends StatelessWidget {
  const _AppConfirmDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
  });

  /// Side of the round badge above the title.
  static const _badge = 64.0;

  /// Tinted by the caller to match [destructive]; the dialog only supplies
  /// the disc behind it.
  final Widget icon;

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Paints the badge and the confirm button in the error colour — for
  /// signing out, deleting an address, emptying the cart.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = destructive ? AppColors.error : AppColors.primary;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: _badge,
                height: _badge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                ),
                child: icon,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(50),
                shape: const StadiumBorder(),
                textStyle: context.textTheme.labelLarge,
              ),
              child: Text(confirmLabel),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.grey500,
                minimumSize: const Size.fromHeight(46),
                shape: const StadiumBorder(),
                textStyle: context.textTheme.labelLarge,
              ),
              child: Text(cancelLabel),
            ),
          ],
        ),
      ),
    );
  }
}
