import 'package:dio/dio.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/exceptions.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/theme/app_typography.dart';
import 'package:elyeter/features/legal/presentation/view/static_page_view.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';

class _PageClient extends ApiClient {
  _PageClient(this.response) : super(Dio());
  final Object response;
  String? requestedPath;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    requestedPath = path;
    if (response is Exception) throw response;
    return response;
  }
}

void main() {
  tearDown(() async => getIt.reset());

  Future<_PageClient> pumpPage(
    WidgetTester tester, {
    required String slug,
    required Object response,
  }) async {
    final client = _PageClient(response);
    getIt.registerSingleton<ShopApi>(ShopApi(client));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: StaticPageView(slug: slug),
      ),
    );
    await tester.pumpAndSettle();
    return client;
  }

  testWidgets('unpublished page shows an empty state with its menu title', (
    tester,
  ) async {
    final client = await pumpPage(
      tester,
      slug: 'faq',
      response: const NotFoundException(
        'page-not-found',
        code: 'page-not-found',
      ),
    );

    expect(client.requestedPath, '/pages/faq');
    expect(find.text('FAQ'), findsNWidgets(2));
    expect(
      find.text('Content will appear here when it is available.'),
      findsOneWidget,
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/faq_empty_3d.png',
    );
    final emptyTitle = find.descendant(
      of: find.byKey(const Key('illustrated-empty-content')),
      matching: find.text('FAQ'),
    );
    final title = tester.widget<Text>(emptyTitle);
    expect(title.style?.fontFamily, AppTypography.fontFamily);
    final imageFrame = tester.getRect(
      find.byKey(const Key('illustrated-empty-image')),
    );
    final titleRect = tester.getRect(emptyTitle);
    expect(titleRect.top - imageFrame.bottom, 4);
    final pageCenter = tester.getCenter(find.byType(Scaffold));
    final contentCenter = tester.getCenter(
      find.byKey(const Key('illustrated-empty-content')),
    );
    expect(
      contentCenter.dy,
      inInclusiveRange(pageCenter.dy - 32, pageCenter.dy - 16),
    );
  });

  testWidgets('a published page renders the API body', (tester) async {
    final client = await pumpPage(
      tester,
      slug: 'terms',
      response: {
        'slug': 'terms',
        'title': 'Terms from API',
        'body': '<p>Current terms</p>',
      },
    );

    expect(client.requestedPath, '/pages/terms');
    expect(find.text('Terms from API'), findsOneWidget);
    expect(find.text('Current terms'), findsOneWidget);
    final html = tester.widget<Html>(find.byType(Html));
    expect(html.style['html']?.fontFamily, AppTypography.fontFamily);
    expect(html.style['p']?.fontFamily, AppTypography.fontFamily);
  });

  testWidgets('a published page with no body shows an empty state', (
    tester,
  ) async {
    await pumpPage(
      tester,
      slug: 'about',
      response: {'slug': 'about', 'title': 'About from API', 'body': null},
    );

    expect(find.text('About from API'), findsOneWidget);
    expect(
      find.text('Content will appear here when it is available.'),
      findsOneWidget,
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/about_empty_3d.png',
    );
    final title = tester.widget<Text>(find.text('About the app').last);
    expect(title.style?.fontFamily, AppTypography.fontFamily);
  });

  testWidgets('an unpublished About page uses the same illustrated state', (
    tester,
  ) async {
    await pumpPage(
      tester,
      slug: 'about',
      response: const NotFoundException('page-not-found'),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(
      find.text('Content will appear here when it is available.'),
      findsOneWidget,
    );
  });

  testWidgets('unpublished Terms shows the 3D document and app font', (
    tester,
  ) async {
    final client = await pumpPage(
      tester,
      slug: 'terms',
      response: const NotFoundException('page-not-found'),
    );

    expect(client.requestedPath, '/pages/terms');
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/terms_empty_3d.png',
    );
    final title = tester.widget<Text>(find.text('Terms of use').last);
    expect(title.style?.fontFamily, AppTypography.fontFamily);
    expect(
      find.text('Content will appear here when it is available.'),
      findsOneWidget,
    );
  });

  testWidgets('unpublished Privacy shows the 3D lock and app font', (
    tester,
  ) async {
    final client = await pumpPage(
      tester,
      slug: 'privacy',
      response: const NotFoundException('page-not-found'),
    );

    expect(client.requestedPath, '/pages/privacy');
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/privacy_empty_3d.png',
    );
    final title = tester.widget<Text>(find.text('Privacy policy').last);
    expect(title.style?.fontFamily, AppTypography.fontFamily);
    expect(
      find.text('Content will appear here when it is available.'),
      findsOneWidget,
    );
  });
}
