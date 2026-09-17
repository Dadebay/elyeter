import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// A titled group of rows drawn as one rounded card, dividers between rows.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(color: AppColors.grey500),
          ),
        ),
        Material(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    // The gap between rows is the page colour showing
                    // through, as in the design — not a grey rule.
                    color: isDark ? AppColors.backgroundDark : AppColors.white,
                    height: 2,
                    thickness: 2,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
