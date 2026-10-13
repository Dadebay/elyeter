import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/router/app_routes.dart';

abstract final class NotificationNavigation {
  static Future<void> open(String? targetType, String? target) async {
    if (target == null || target.isEmpty) return;
    switch (targetType) {
      case 'product':
        unawaited(
          AppRouter.router.pushNamed(
            AppRoutes.productDetail.name,
            pathParameters: {'id': target},
          ),
        );
      case 'category':
        unawaited(
          AppRouter.router.pushNamed(
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
