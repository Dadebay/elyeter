import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_asset_image.dart';

/// The app's back affordance: a white stadium with the chevron from
/// `assets/icons/back.svg`, lifted by a faint shadow so it reads on a photo
/// and on a white page alike.
///
/// Use [AppBackButton.appBarLeading] inside an [AppBar] together with
/// [AppBackButton.leadingWidth]; the bare constructor suits a [Stack] over
/// artwork.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.width = defaultWidth,
    this.tint,
  });

  /// Wrapped in the page inset, for `AppBar.leading`.
  const factory AppBackButton.appBarLeading({
    Key? key,
    VoidCallback? onPressed,
    Color? tint,
  }) = _AppBarBackButton;

  /// The control's resting width. Exposed so a page drawing its own
  /// counterpart at the other end of the bar can match it — the category
  /// page's search button does.
  static const double defaultWidth = 60;
  static const double height = 44;
  static const double iconSize = 22;

  /// What `AppBar.leadingWidth` must be for the button to sit at the page
  /// inset without being squeezed by the toolbar's default 56pt slot.
  static const double leadingWidth = defaultWidth + AppSpacing.page + AppSpacing.sm;

  /// Deliberately faint: heavier reads as a smudge rather than a lift.
  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  final VoidCallback? onPressed;
  final double width;

  /// Chevron colour; defaults to the theme's ink.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: isDark ? null : shadow,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed ?? () => Navigator.of(context).maybePop(),
            child: SizedBox(
              width: width,
              height: height,
              child: Center(
                child: AppAssetImage(
                  AppAssets.iconBack,
                  width: iconSize,
                  height: iconSize,
                  color: tint ?? (isDark ? AppColors.white : AppColors.ink),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarBackButton extends AppBackButton {
  const _AppBarBackButton({super.key, super.onPressed, super.tint});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.page),
    child: Align(
      alignment: Alignment.centerLeft,
      child: AppBackButton(onPressed: onPressed, tint: tint),
    ),
  );
}
