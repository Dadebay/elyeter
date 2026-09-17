@Tags(['golden'])
library;

import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/category/presentation/view/category_page.dart';
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

void main() {
  testWidgets('category page golden', (tester) async {
    await _loadFonts();
    tester.view
      ..physicalSize = const Size(1170, 2100)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CategoryPage(),
      ),
    );
    // Category artwork is decoded out of its SVG at runtime.
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }

    await expectLater(
      find.byType(CategoryPage),
      matchesGoldenFile('goldens/category_page.png'),
    );
  });
}
