import 'package:dio/dio.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/notification/presentation/view/notification_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _EmptyNotificationApi extends ShopApi {
  _EmptyNotificationApi() : super(ApiClient(Dio()));

  int requests = 0;

  @override
  Future<Paginated<ShopNotification>> notifications({
    int page = 1,
    int size = 20,
  }) async {
    requests++;
    return Paginated(items: const [], totalCount: 0, page: page);
  }
}

void main() {
  tearDown(() async => getIt.reset());

  testWidgets('empty notification history shows illustration and refreshes', (
    tester,
  ) async {
    final api = _EmptyNotificationApi();
    getIt.registerSingleton<ShopApi>(api);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const NotificationPage(title: 'Notifications'),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.requests, 1);
    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.text('New updates will appear here.'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/notification_empty_3d.png',
    );

    final content = tester.getRect(
      find.byKey(const Key('notification-empty-content')),
    );
    final viewport = tester.getRect(find.byType(CustomScrollView));
    expect(content.center.dy, lessThan(viewport.center.dy));
    expect((content.center.dy - viewport.center.dy).abs(), lessThan(70));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(api.requests, 2);
  });

  testWidgets('empty announcements use the same centered layout', (
    tester,
  ) async {
    getIt.registerSingleton<ShopApi>(_EmptyNotificationApi());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const NotificationPage(
          title: 'Announcements',
          isAnnouncement: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No announcements yet'), findsOneWidget);
    expect(find.text('New announcements will appear here.'), findsOneWidget);
    expect(find.text('No notifications yet'), findsNothing);
    final imageBox = find.byKey(const Key('notification-empty-image'));
    expect(tester.getSize(imageBox).width, 200);
    expect(tester.getSize(imageBox).height, 160);
    expect(
      find.descendant(of: imageBox, matching: find.byType(ClipRect)),
      findsNothing,
    );
    final content = tester.getRect(
      find.byKey(const Key('notification-empty-content')),
    );
    final viewport = tester.getRect(find.byType(CustomScrollView));
    expect(content.center.dy, lessThan(viewport.center.dy));
    expect((content.center.dy - viewport.center.dy).abs(), lessThan(70));
  });
}
