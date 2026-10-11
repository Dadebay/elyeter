import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The app bar's title slot on the category page: the category's name, which
/// gives way to a search field that grows out of the search button.
///
/// The field is always laid out at its full width and only the clip grows, so
/// the text never reflows while the pill is opening.
class CategorySearchTitle extends StatelessWidget {
  const CategorySearchTitle({
    super.key,
    required this.title,
    required this.open,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
  });

  static const duration = Duration(milliseconds: 340);

  /// Taller than the buttons beside it: this is the control being typed in.
  static const height = 48.0;

  /// Space between the pill and the close button.
  static const gap = AppSpacing.lg;

  final String title;
  final bool open;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The pill stops this far short of the close button beside it.
        // (Taking the gap off the width alone would leave it on the left,
        // since the pill is anchored to the right.)
        final full = (constraints.maxWidth - gap).clamp(0.0, double.infinity);

        return Stack(
          alignment: Alignment.centerRight,
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: open ? 0 : 1,
                duration: const Duration(milliseconds: 180),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            ExcludeFocus(
              excluding: !open,
              child: IgnorePointer(
                ignoring: !open,
                // Closed, the pill is zero wide; fading it out keeps any sliver of
                // it from showing at the edge.
                child: Padding(
                  padding: const EdgeInsets.only(right: gap),
                  child: AnimatedOpacity(
                    opacity: open ? 1 : 0,
                    duration: const Duration(milliseconds: 120),
                    child: AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      width: open ? full : 0,
                      height: height,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey900 : AppColors.grey100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: OverflowBox(
                        alignment: Alignment.centerRight,
                        minWidth: full,
                        maxWidth: full,
                        child: _Field(
                          controller: controller,
                          focusNode: focusNode,
                          hint: hint,
                          isDark: isDark,
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// What sits inside the pill: a brand-tinted magnifier tile, the text, and a
/// clear button that appears once there is something to clear.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.isDark,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(width: AppSpacing.sm),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.xs + 2),
          ),
          child: const Center(
            child: HugeIcon(
              icon: AppIcons.search,
              size: 18,
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.search,
            cursorColor: AppColors.primary,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.white : AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.grey500,
              ),
              filled: false,
              isCollapsed: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: value.text.isEmpty
                ? const SizedBox(width: AppSpacing.lg, key: ValueKey('none'))
                : _ClearButton(
                    key: const ValueKey('clear'),
                    onTap: () {
                      controller.clear();
                      onChanged('');
                      onSubmitted('');
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.grey300,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 20,
            child: Center(
              child: HugeIcon(
                icon: AppIcons.close,
                size: 12,
                strokeWidth: 2.5,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
