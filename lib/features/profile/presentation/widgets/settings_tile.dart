import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';

/// What sits at the end of a settings row.
sealed class TileTrailing {
  const TileTrailing();
}

/// A plain chevron — the row opens another page.
class TileChevron extends TileTrailing {
  const TileChevron();
}

/// Current value plus the chevron, e.g. the selected language.
class TileValue extends TileTrailing {
  const TileValue(this.value);
  final String value;
}

/// An inline switch, e.g. dark mode.
class TileSwitch extends TileTrailing {
  const TileSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
}

/// Leaves the app — shown with an outward arrow.
class TileExternal extends TileTrailing {
  const TileExternal();
}

/// One row of a settings group.
class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.icon, required this.label, this.trailing = const TileChevron(), this.onTap});

  /// Path to an SVG in `assets/icons`.
  final String icon;
  final String label;
  final TileTrailing trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Design system: icons are `icon/soft-400`, labels are `ink`.
    final iconColor = isDark ? AppColors.grey500 : AppColors.iconSoft;
    final chevronColor = iconColor;
    final labelColor = isDark ? AppColors.white : AppColors.ink;

    return Ink(
      color: Color(0xfff5f5f5),
      child: InkWell(
        onTap: switch (trailing) {
          TileSwitch(:final value, :final onChanged) => () => onChanged(!value),
          _ => onTap,
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              AppAssetImage(icon, width: 22, height: 22, color: iconColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              switch (trailing) {
                TileChevron() => Icon(Icons.chevron_right_rounded, color: chevronColor),
                TileExternal() => Icon(Icons.north_east_rounded, size: 18, color: chevronColor),
                TileValue(:final value) => Row(
                  children: [
                    Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: labelColor)),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.unfold_more_rounded, size: 18, color: chevronColor),
                  ],
                ),
                // iOS-style on every platform, as the design shows it.
                TileSwitch(:final value, :final onChanged) => CupertinoSwitch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primary),
              },
            ],
          ),
        ),
      ),
    );
  }
}
