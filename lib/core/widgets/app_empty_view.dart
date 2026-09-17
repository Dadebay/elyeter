import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, this.message, this.icon});

  final String? message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: .min,
        children: [
          Icon(icon ?? Icons.inbox_outlined, size: 48, color: AppColors.grey500),
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
