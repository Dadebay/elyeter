@Tags(['golden'])
library;

import 'package:elyeter/core/theme/app_theme.dart';
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
  testWidgets('language dialog golden', (tester) async {
    await _loadFonts();
    tester.view
      ..physicalSize = const Size(1170, 1400)
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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showLanguageDialog(context, current: 'tk'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Dialog),
      matchesGoldenFile('goldens/language_dialog.png'),
    );
  });
}
