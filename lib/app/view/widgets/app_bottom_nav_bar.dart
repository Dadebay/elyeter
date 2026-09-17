import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// A single destination of [AppBottomNavBar].
class AppNavItem {
  const AppNavItem({required this.asset, required this.label});

  /// Path to an SVG in `assets/icons`.
  final String asset;
  final String label;
}

/// Floating pill-shaped navigation bar: the active tab sits in a soft orange
/// capsule with its icon and label tinted to the brand color.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTap, required this.items, this.accentColor = AppColors.primary});

  /// Tab icons in navigation order. Labels come from the caller so they can be
  /// localized — see `HomeShell`.
  static const List<String> assets = [AppAssets.iconHome, AppAssets.iconCategory, AppAssets.iconCart, AppAssets.iconFavorite, AppAssets.iconProfile];

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Sit above the home indicator instead of running underneath it: the
    // system inset is added as outside padding, not consumed by the bar.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, (bottomInset > 0 ? bottomInset : 12) + 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(34),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 28, offset: Offset(0, 10)),
            BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(item: items[i], selected: i == currentIndex, accentColor: accentColor, onTap: () => onTap(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.accentColor, required this.onTap});

  final AppNavItem item;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 240);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idleColor = isDark ? AppColors.white : const Color(0xFF171717);
    final color = selected ? accentColor : idleColor;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        splashColor: accentColor.withValues(alpha: 0.10),
        highlightColor: accentColor.withValues(alpha: 0.05),
        // Selected tab: icon and label share one capsule.
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          padding: const EdgeInsets.symmetric(vertical: 6),
          // An ellipse, not a rounded rectangle: OvalBorder fits the tab's
          // box, so the highlight stays oval at any width.
          decoration: ShapeDecoration(
            color: selected ? accentColor.withValues(alpha: isDark ? 0.22 : 0.12) : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            shadows: selected ? [BoxShadow(color: accentColor.withValues(alpha: 0.14), blurRadius: 18, offset: const Offset(0, 4))] : null,
          ),
          child: Column(
            mainAxisSize: .min,
            children: [
              SvgPicture.asset(item.asset, width: 26, height: 26, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
              const SizedBox(height: AppSpacing.xxs),
              AnimatedDefaultTextStyle(
                duration: _duration,
                curve: _curve,
                // Design spec: Inter Display 10px / Medium 500 /
                // line height 100% / letter spacing 0 / centered.
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  letterSpacing: 0,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: color,
                ),
                child: Text(item.label, maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
