import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Pill search box with a camera (visual search) action.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key, this.onTap, this.onCameraTap, this.controller});

  final VoidCallback? onTap;
  final VoidCallback? onCameraTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTap: onTap,
      readOnly: onTap != null,
      textInputAction: TextInputAction.search,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: context.l10n.homeSearchHint,
        hintStyle: context.textTheme.bodyMedium?.copyWith(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        fillColor: AppColors.white,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0).copyWith(right: 8.0),
          child: const _SearchIcon(AppAssets.iconSearch, color: AppColors.black),
        ),
        suffixIcon: IconButton(
          padding: const EdgeInsets.all(10.0).copyWith(right: 16.0),
          onPressed: onCameraTap,
          icon: const _SearchIcon(AppAssets.iconCamera, color: AppColors.black),
        ),
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
      ),
    );
  }

  static final OutlineInputBorder _border = OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.pill), borderSide: BorderSide.none);
}

/// One of the field's SVG icons, tinted and sized like the [Icon]s the rest
/// of the form uses.
class _SearchIcon extends StatelessWidget {
  const _SearchIcon(this.asset, {required this.color});

  final String asset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(asset, width: _size, height: _size, fit: BoxFit.contain, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
  }

  /// Matches the default [IconThemeData.size] the icons replace.
  static const double _size = 24;
}
