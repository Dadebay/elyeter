import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';

/// Asks a signed-out customer to sign in before opening an account-only
/// page, and takes them to the login screen when they agree.
///
/// Returns true once the customer actually signed in, so the caller can go
/// on with whatever the tap was for.
Future<bool> promptSignIn(BuildContext context) async {
  final l10n = context.l10n;

  final goToLogin = await showAppConfirmDialog(
    context,
    icon: const AppAssetImage(
      AppAssets.iconLock,
      width: 26,
      height: 26,
      color: AppColors.primary,
    ),
    title: l10n.authSignInRequiredTitle,
    message: l10n.authSignInRequiredMessage,
    confirmLabel: l10n.authSignIn,
    cancelLabel: l10n.commonCancel,
  );

  if (!goToLogin || !context.mounted) return false;

  // The login page pops with true once `/auth/verify-code` succeeded.
  final signedIn = await context.pushNamed<bool>(AppRoutes.login.name);
  return signedIn ?? false;
}
