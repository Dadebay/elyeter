import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_asset_image.dart';

/// Tappable avatar with a camera badge — initials until a photo is picked.
class EditProfileAvatar extends StatelessWidget {
  const EditProfileAvatar({
    super.key,
    required this.name,
    required this.onTap,
    this.imagePath,
    this.size = 96,
  });

  final String name;
  final String? imagePath;
  final VoidCallback onTap;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final badge = size * 0.32;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size + badge / 2,
          height: size + badge / 2,
          child: Stack(
            children: [
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: imagePath == null
                    ? Text(
                        _initials,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.black),
                      )
                    : Image.file(
                        File(imagePath!),
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: badge,
                  height: badge,
                  padding: EdgeInsets.all(badge * 0.22),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const AppAssetImage(
                    AppAssets.iconCamera,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
