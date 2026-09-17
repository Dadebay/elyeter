import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Cached product image with a shimmer placeholder and a safe fallback.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.radius = AppRadius.md,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Which part of the image survives when [fit] has to crop.
  final Alignment alignment;

  final double radius;

  @override
  Widget build(BuildContext context) {
    final child = url == null || url!.isEmpty
        ? _fallback()
        : CachedNetworkImage(
            imageUrl: url!,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            placeholder: (_, _) => _shimmer(),
            errorWidget: (_, _, _) => _fallback(),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: AppColors.grey100,
    highlightColor: AppColors.white,
    child: Container(width: width, height: height, color: AppColors.grey100),
  );

  Widget _fallback() => Container(
    width: width,
    height: height,
    color: AppColors.grey100,
    child: const Icon(Icons.image_outlined, color: AppColors.grey500),
  );
}
