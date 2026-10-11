import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_back_button.dart';

/// The category page's search control: the back button's twin at the other
/// end of the bar — same pill, same width and height, same faint lift — with
/// a magnifier in place of the chevron. While the search field is [open] it
/// turns into the control that closes it.
class CategorySearchButton extends StatelessWidget {
  const CategorySearchButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.open = false,
  });

  final VoidCallback onPressed;
  final String? tooltip;

  /// The search field is out: the magnifier becomes a close mark.
  final bool open;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.page),
      child: Align(
        alignment: Alignment.centerRight,
        child: Semantics(
          button: true,
          label: tooltip,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: isDark ? Border.all(color: AppColors.grey700) : null,
              boxShadow: isDark ? null : AppBackButton.shadow,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: SizedBox(
                  width: AppBackButton.defaultWidth,
                  height: AppBackButton.height,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) =>
                          RotationTransition(
                            turns: Tween(
                              begin: 0.75,
                              end: 1.0,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                      child: HugeIcon(
                        key: ValueKey(open),
                        icon: open ? AppIcons.close : AppIcons.search,
                        size: AppBackButton.iconSize,
                        color: isDark ? AppColors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
