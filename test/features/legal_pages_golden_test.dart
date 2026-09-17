@Tags(['golden'])
library;

import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/legal/presentation/view/faq_page.dart';
import 'package:elyeter/features/legal/presentation/view/privacy_page.dart';
import 'package:elyeter/features/profile/presentation/widgets/about_app_dialog.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFonts() async {
  final loader = FontLoader('InterDisplay')
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-Bold.ttf'));
  await loader.load();

  final wordmark = FontLoader('Qurova')
    ..addFont(rootBundle.load('assets/fonts/QurovaDEMO-Medium.otf'));
  await wordmark.load();
}

Widget _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  setUp(_loadFonts);

  testWidgets('faq page golden', (tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2100)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const FaqPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FaqPage),
      matchesGoldenFile('goldens/faq_page.png'),
    );
  });

  testWidgets('privacy page golden', (tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const PrivacyPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(PrivacyPage),
      matchesGoldenFile('goldens/privacy_page.png'),
    );
  });

  testWidgets('about dialog golden', (tester) async {
    tester.view
      ..physicalSize = const Size(1170, 1600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showAboutAppDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Dialog),
      matchesGoldenFile('goldens/about_dialog.png'),
    );
  });
}
