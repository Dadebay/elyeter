import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'visual_search_source_sheet.dart' show HugeIconData;

/// Close button, title and flash toggle across the top of the camera.
class VisualSearchTopBar extends StatelessWidget {
  const VisualSearchTopBar({super.key, required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          _GlassButton(icon: HugeIcons.strokeRoundedCancel01, onTap: onClose),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.titleSmall?.copyWith(color: AppColors.white),
            ),
          ),
          // Balances the close button so the title stays optically centred.
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// Flash, shutter and camera flip along the bottom of the camera.
class VisualSearchShutterBar extends StatelessWidget {
  const VisualSearchShutterBar({
    super.key,
    required this.busy,
    required this.enabled,
    required this.flashOn,
    required this.onCapture,
    this.onFlash,
    this.onSwitch,
  });

  final bool busy;
  final bool enabled;
  final bool flashOn;
  final VoidCallback onCapture;

  /// Null while the preview is not live yet.
  final VoidCallback? onFlash;

  /// Null on devices with a single camera.
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassButton(
            icon: flashOn ? HugeIcons.strokeRoundedFlash : HugeIcons.strokeRoundedFlashOff,
            onTap: busy ? null : onFlash,
            active: flashOn,
          ),
          _Shutter(busy: busy, onTap: enabled && !busy ? onCapture : null),
          _GlassButton(icon: HugeIcons.strokeRoundedCameraRotated01, onTap: busy ? null : onSwitch),
        ],
      ),
    );
  }
}

/// Retake / use the shot just taken.
class VisualSearchConfirmBar extends StatelessWidget {
  const VisualSearchConfirmBar({super.key, required this.onRetake, required this.onUse});

  final VoidCallback onRetake;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onRetake,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.white),
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(context.l10n.visualSearchRetake),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton(
              onPressed: onUse,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: Text(context.l10n.visualSearchUse),
            ),
          ),
        ],
      ),
    );
  }
}

/// Translucent circular control, the standard camera-overlay affordance.
class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap, this.active = false});

  final HugeIconData icon;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: active ? AppColors.white : AppColors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          // Centred, not a direct child: a tight 44x44 box would stretch the
          // icon's own SizedBox to fill it and ignore `size`.
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: 20,
              color: active
                  ? AppColors.black
                  : AppColors.white.withValues(alpha: enabled ? 1 : 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

/// The shutter: a white ring around a filled disc, as on the system camera.
class _Shutter extends StatelessWidget {
  const _Shutter({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: onTap == null ? 0.4 : 1), width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
                )
              : DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: onTap == null ? 0.4 : 1),
                  ),
                ),
        ),
      ),
    );
  }
}
