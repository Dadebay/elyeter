import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../error/failure.dart';
import '../localization/failure_localizer.dart';
import '../theme/app_spacing.dart';
import '../utils/extensions/context_extensions.dart';
import '../constants/app_icons.dart';

/// Standard failure state — one look for every screen.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: .min,
          children: [
            HugeIcon(
              icon: AppIcons.error,
              size: 48,
              color: context.colors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              failure.localize(l10n),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
            ],
          ],
        ),
      ),
    );
  }
}
