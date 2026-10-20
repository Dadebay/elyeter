import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/catalog_empty_view.dart';

class CartEmptyView extends StatelessWidget {
  const CartEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CatalogEmptyView(
      illustration: AppAssets.cartEmptyIllustration,
      title: l10n.cartEmpty,
      message: l10n.cartEmptyMessage,
      actionLabel: l10n.cartEmptyAction,
      onAction: () => context.goNamed(AppRoutes.home.name),
    );
  }
}
