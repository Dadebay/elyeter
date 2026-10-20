@Tags(['golden'])
library;

import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/features/profile/presentation/widgets/language_dialog.dart';
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
  testWidgets('language bottom sheet golden', (tester) async {
    await _loadFonts();
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3
      ..viewPadding = const FakeViewPadding(bottom: 102);
    addTearDown(tester.view.reset);
    String? selected;
    var navTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('tk'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ...FallbackLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          extendBody: true,
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      selected = await showLanguageDialog(
                        context,
                        current: 'en',
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 80,
            child: TextButton(
              onPressed: () => navTaps++,
              child: const Text('navigation'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final navBarTop = tester.getTopLeft(find.text('navigation')).dy;

    final sheet = find.byKey(const Key('language-sheet'));
    expect(tester.getSize(sheet).width, closeTo(366, 1));
    expect(tester.getBottomLeft(sheet).dy, closeTo(810, 1));
    expect(tester.getBottomLeft(sheet).dy, greaterThan(navBarTop));

    await expectLater(
      find.byKey(const Key('language-sheet-backdrop')),
      matchesGoldenFile('goldens/language_dialog.png'),
    );

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(selected, 'ru');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.text('navigation')));
    await tester.pumpAndSettle();
    expect(navTaps, 0);

    await tester.tapAt(const Offset(195, 200));
    await tester.pumpAndSettle();
    expect(selected, isNull);
  });
}
