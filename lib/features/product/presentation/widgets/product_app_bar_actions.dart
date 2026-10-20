import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_back_button.dart';

/// The product page's two actions — share and favourite — in one pill at the
/// right of the bar, the back button's counterpart: same faint lift, same
/// outline in dark mode. The icons are the bundled SVGs, so the
/// pair matches the rest of the app's artwork.
class ProductAppBarActions extends StatelessWidget {
  const ProductAppBarActions({
    super.key,
    required this.favorite,
    required this.onShare,
    required this.onFavorite,
  });

  /// One slot's width. Together with [AppBackButton.height] this keeps the
  /// pill the same shape as the back button, only longer.
  static const double slotWidth = 44;

  static const double _iconSize = 20;

  /// Shorter than the back button beside it: two controls in one pill read
  /// as heavier than one, so the pill is kept lean.
  static const double height = 40;

  final bool favorite;
  final VoidCallback onShare;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppColors.white : AppColors.ink;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.page),
      child: Align(
        alignment: Alignment.centerRight,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Slot(
                  label: MaterialLocalizations.of(context).shareButtonLabel,
                  onTap: onShare,
                  child: AppAssetImage(
                    AppAssets.iconShare,
                    width: _iconSize,
                    height: _iconSize,
                    color: ink,
                  ),
                ),
                _Slot(
                  label: 'Favorite',
                  onTap: onFavorite,
                  // Filled once it is a favourite — the same artwork the
                  // catalogue cards use for that state.
                  child: favorite
                      ? const AppAssetImage(
                          AppAssets.iconFavoriteFull,
                          width: _iconSize,
                          height: _iconSize,
                        )
                      : AppAssetImage(
                          AppAssets.iconHeartLine,
                          width: _iconSize,
                          height: _iconSize,
                          color: ink,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.child, required this.onTap, required this.label});

  final Widget child;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: ProductAppBarActions.slotWidth,
          height: ProductAppBarActions.height,
          child: Center(child: child),
        ),
      ),
    );
  }
}
