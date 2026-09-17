import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// One choice in [showLanguageDialog].
class LanguageOption {
  const LanguageOption({required this.code, required this.title, this.subtitle});

  final String code;

  /// The language in its own words — `Türkmençe`, not `Turkmen`.
  final String title;

  /// The same language named in the current app language. Dropped when it
  /// would just repeat [title] — "English / English" says nothing.
  final String? subtitle;

  String? get secondary => subtitle == null || subtitle == title ? null : subtitle;
}

/// Asks for the app language. Returns the chosen code, or null when the
/// dialog is dismissed without choosing.
Future<String?> showLanguageDialog(
  BuildContext context, {
  required String? current,
}) {
  final l10n = context.l10n;

  final options = <LanguageOption>[
    LanguageOption(code: 'tk', title: 'Türkmençe', subtitle: l10n.settingsLanguageTurkmen),
    LanguageOption(code: 'en', title: 'English', subtitle: l10n.settingsLanguageEnglish),
    LanguageOption(code: 'ru', title: 'Русский', subtitle: l10n.settingsLanguageRussian),
  ];

  return showDialog<String>(
    context: context,
    builder: (dialogContext) =>
        _LanguageDialog(options: options, current: current),
  );
}

class _LanguageDialog extends StatelessWidget {
  const _LanguageDialog({required this.options, required this.current});

  final List<LanguageOption> options;
  final String? current;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.settingsLanguage,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final option in options) ...[
              _LanguageRow(
                option: option,
                selected: option.code == current,
                onTap: () => Navigator.of(context).pop(option.code),
              ),
              if (option != options.last) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.backgroundDark : AppColors.surfaceMuted;

    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.10) : fill,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.title,
                      style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.primary
                            : (isDark ? AppColors.white : AppColors.ink),
                      ),
                    ),
                    if (option.secondary != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        option.secondary!,
                        style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // A check rather than a radio: the choice applies on tap, so
              // this marks what is active, not what is staged.
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                scale: selected ? 1 : 0,
                child: const _CheckDot(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckDot extends StatelessWidget {
  const _CheckDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.check_rounded, size: 15, color: AppColors.white),
  );
}
