import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';
import '../constants/app_icons.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, this.message, this.icon});

  final String? message;

  /// A `AppIcons.*` constant — Hugeicons supplies glyphs as data, not as a
  /// font, so this is not Material's `IconData`.
  final AppIconData? icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: .min,
        children: [
          HugeIcon(
            icon: icon ?? AppIcons.empty,
            size: 48,
            color: AppColors.grey500,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message ?? context.l10n.commonEmpty,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    ),
  );
}
