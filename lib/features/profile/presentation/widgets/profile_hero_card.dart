import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';

/// The panel at the top of the profile page, in its two states.
///
/// Both are the same object — one dark card with a brand-coloured glow —
/// so signing in changes what the card says, not what the page looks like.
/// The card is dark on purpose: white type on the brand orange does not
/// carry enough contrast at body sizes, and the ink lets the orange stay an
/// accent (the avatar ring, the stat glyphs) rather than a background.
class _HeroShell extends StatelessWidget {
  const _HeroShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.4 : 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [AppColors.surfaceDark, Color(0xFF2A2A2A)]
                  : const [AppColors.black, AppColors.grey900],
            ),
          ),
          child: Stack(
            children: [
              // A soft brand glow in the top corner, so the card reads as
              // Elyeter's rather than as a plain black rectangle.
              Positioned(
                top: -70,
                right: -50,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.45),
                        AppColors.primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Signed in: who the account belongs to, a way into the edit page, and the
/// two numbers worth seeing at a glance.
class AccountHeroCard extends StatelessWidget {
  const AccountHeroCard({
    super.key,
    required this.name,
    required this.phone,
    required this.ordersValue,
    required this.ordersLabel,
    required this.favoritesValue,
    required this.favoritesLabel,
    required this.editLabel,
    this.avatarUrl,
    this.avatarPath,
    this.onEditProfile,
    this.onOrders,
    this.onFavorites,
  });

  final String name;

  /// Already grouped for reading — see `PhoneFormatter`.
  final String phone;

  final String ordersValue;
  final String ordersLabel;
  final String favoritesValue;
  final String favoritesLabel;

  /// Tooltip and screen-reader label for the pencil button.
  final String editLabel;

  final String? avatarUrl;

  /// Local file of a photo picked on the edit page; it wins over the one
  /// the account carries, since it is the more recent choice.
  final String? avatarPath;

  final VoidCallback? onEditProfile;
  final VoidCallback? onOrders;
  final VoidCallback? onFavorites;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _HeroShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: name, imageUrl: avatarUrl, imagePath: avatarPath),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.65),
                        // Figures read too tight against the name above
                        // without a little tracking.
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _GlassButton(
                icon: AppAssets.iconPencil,
                semanticLabel: editLabel,
                onTap: onEditProfile,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _StatStrip(
            children: [
              _Stat(
                icon: AppAssets.iconCubic,
                value: ordersValue,
                label: ordersLabel,
                onTap: onOrders,
              ),
              _Stat(
                icon: AppAssets.iconHeartLine,
                value: favoritesValue,
                label: favoritesLabel,
                onTap: onFavorites,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Signed out: the same card, saying what an account is for and offering
/// the one action that matters here.
class GuestHeroCard extends StatelessWidget {
  const GuestHeroCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onSignIn,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _HeroShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _Avatar.size,
                height: _Avatar.size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: const AppAssetImage(
                  AppAssets.iconUser,
                  width: 26,
                  height: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      message,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.65),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSignIn,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(0, 48),
                shape: const StadiumBorder(),
                textStyle: textTheme.labelLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(actionLabel),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The photo, or the customer's initials inside a brand-coloured ring.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.imageUrl, this.imagePath});

  static const double size = 58;
  static const double _ring = 2;

  final String name;
  final String? imageUrl;
  final String? imagePath;

  /// "Myradow Maksat" -> "MM"
  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    // A number for a name — the account before anyone fills theirs in —
    // would otherwise show a digit where initials belong.
    return RegExp(r'^[A-Za-zÀ-ÿĀ-ſА-Яа-я]').hasMatch(letters) ? letters : '';
  }

  ImageProvider? get _image => switch ((imagePath, imageUrl)) {
    (final String path, _) => FileImage(File(path)),
    (_, final String url) => CachedNetworkImageProvider(url),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(_ring),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryFade],
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grey900,
          image: image == null
              ? null
              : DecorationImage(image: image, fit: BoxFit.cover),
        ),
        child: image != null
            ? null
            : _initials.isEmpty
            ? const AppAssetImage(
                AppAssets.iconUser,
                width: 24,
                height: 24,
                color: AppColors.white,
              )
            : Text(
                _initials,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

/// A round, frosted control on the dark card — the edit button.
class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final String icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: AppAssetImage(
                AppAssets.iconPencil,
                width: 18,
                height: 18,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The frosted panel holding the numbers, with hairlines between cells.
class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  color: AppColors.white.withValues(alpha: 0.1),
                ),
              Expanded(child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// One cell of the strip: a figure with what it counts underneath.
class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final String icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAssetImage(
                    icon,
                    width: 16,
                    height: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
