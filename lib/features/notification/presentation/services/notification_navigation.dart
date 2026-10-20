import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../product/domain/entities/product_id.dart';

abstract final class NotificationNavigation {
  static Future<void> open(
    String? targetType,
    String? target, {
    GoRouter? router,
  }) async {
    if (target == null || target.isEmpty) return;
    switch (targetType) {
      case 'product':
        final productId = ProductId.tryParse(target);
        if (productId == null) return;
        unawaited(
          (router ?? AppRouter.router).pushNamed(
            AppRoutes.productDetail.name,
            pathParameters: {'id': productId.toString()},
          ),
        );
      case 'category':
        unawaited(
          (router ?? AppRouter.router).pushNamed(
            AppRoutes.categoryDetail.name,
            pathParameters: {'id': target},
          ),
        );
      case 'url':
        final uri = Uri.tryParse(target);
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
    }
  }
}
