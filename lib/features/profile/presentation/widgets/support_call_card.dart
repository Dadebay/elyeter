import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Blue support panel at the bottom of the profile page.
class SupportCallCard extends StatelessWidget {
  const SupportCallCard({
    super.key,
    required this.title,
    required this.phone,
    required this.hours,
    required this.actionLabel,
    this.hoursHighlight,
    this.onCall,
  });

  /// Side of the white chip the icon sits in.
  static const _chipSize = 36.0;

  final String title;
  final String phone;
  final String hours;
  final String actionLabel;

  /// Part of [hours] to set in bold — the opening times themselves, which
  /// are what anyone reading the line is actually looking for. Ignored when
  /// it does not occur in [hours].
  final String? hoursHighlight;

  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.info,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // A white chip rather than a bare glyph: the icon reads as a
              // badge on the panel instead of floating loose on the blue.
              Container(
                width: _chipSize,
                height: _chipSize,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCustomerService01,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    // The number never wraps; it shrinks if the button and
                    // a long translation squeeze the row.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        phone,
                        maxLines: 1,
                        softWrap: false,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          // Heavy figures at this size read too loose at
                          // their default tracking.
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: onCall,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.black,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: textTheme.labelLarge,
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Hours(
            text: hours,
            highlight: hoursHighlight,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// The opening-hours line, with the times themselves picked out in bold.
class _Hours extends StatelessWidget {
  const _Hours({required this.text, required this.highlight, this.style});

  final String text;
  final String? highlight;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final mark = highlight;
    // A translation that phrases the times differently simply reads plain
    // rather than emphasising the wrong words.
    final at = mark == null || mark.isEmpty ? -1 : text.indexOf(mark);

    if (at < 0) return Text(text, style: style);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, at)),
          TextSpan(
            text: mark,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(at + mark!.length)),
        ],
      ),
      style: style,
    );
  }
}
