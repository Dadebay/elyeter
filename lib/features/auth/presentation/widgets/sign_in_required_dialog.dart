import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Asks a signed-out customer to sign in before opening an account-only
/// page, and takes them to the login screen when they agree.
///
/// Returns true once the customer actually signed in, so the caller can go
/// on with whatever the tap was for.
Future<bool> promptSignIn(BuildContext context) async {
  final l10n = context.l10n;

  final goToLogin = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.authSignInRequiredTitle),
      content: Text(l10n.authSignInRequiredMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.authSignIn),
        ),
      ],
    ),
  );

  if (goToLogin != true || !context.mounted) return false;

  // The login page pops with true once `/auth/verify-code` succeeded.
  final signedIn = await context.pushNamed<bool>(AppRoutes.login.name);
  return signedIn ?? false;
}
