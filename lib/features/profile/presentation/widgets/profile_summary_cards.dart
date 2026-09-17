import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';

/// The two cards at the top of the profile page: who is signed in, and a
/// shortcut into the order list.
class ProfileSummaryCards extends StatelessWidget {
  const ProfileSummaryCards({
    super.key,
    required this.name,
    required this.editLabel,
    required this.ordersTitle,
    required this.ordersSubtitle,
    this.avatarUrl,
    this.avatarPath,
    this.onEditProfile,
    this.onOrders,
  });

  final String name;
  final String editLabel;
  final String ordersTitle;
  final String ordersSubtitle;
  final String? avatarUrl;

  /// Local file of a photo picked on the edit page.
  final String? avatarPath;
  final VoidCallback? onEditProfile;
  final VoidCallback? onOrders;

  /// "Myradow Maksat" -> "MM"
  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight so both cards match the taller one; a bare stretch Row
    // would ask for infinite height inside a scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Card(
              onTap: onEditProfile,
              leading: _Avatar(
              initials: _initials,
              imageUrl: avatarUrl,
              imagePath: avatarPath,
            ),
              title: name,
              subtitle: editLabel,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Card(
              onTap: onOrders,
              leading: const _OrdersGlyph(),
              title: ordersTitle,
              subtitle: ordersSubtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, this.imageUrl, this.imagePath});

  final String initials;
  final String? imageUrl;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        image: switch ((imagePath, imageUrl)) {
          (final String path, _) => DecorationImage(
            image: FileImage(File(path)),
            fit: BoxFit.cover,
          ),
          (_, final String url) => DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
          _ => null,
        },
      ),
      child: imagePath != null || imageUrl != null
          ? null
          : Text(
              initials,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.black),
            ),
    );
  }
}

class _OrdersGlyph extends StatelessWidget {
  const _OrdersGlyph();

  @override
  Widget build(BuildContext context) =>
      const AppAssetImage(AppAssets.iconCubic, width: 44, height: 44);
}
