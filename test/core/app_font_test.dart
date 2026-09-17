import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/theme/app_typography.dart';
import 'package:elyeter/features/legal/presentation/view/faq_page.dart';
import 'package:elyeter/features/profile/presentation/widgets/about_app_dialog.dart';
import 'package:elyeter/features/profile/presentation/widgets/language_dialog.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Fails when any rendered text would draw in something other than the app
/// font — the trap being widgets that *replace* the default text style
/// (AnimatedDefaultTextStyle, AppBar.titleTextStyle) rather than merge with
/// it, which silently falls back to the platform font.
void _expectAllInterDisplay(WidgetTester tester, String where) {
  final missing = <String>[];
  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    final span = rich.text as TextSpan;
    final family = span.style?.fontFamily;
    // Icons are glyphs in their own font, and the wordmark has its own
    // display face on purpose.
    if (family == 'MaterialIcons') continue;
    if (family == AppTypography.wordmarkFontFamily) continue;
    if (family != AppTypography.fontFamily) {
      missing.add('"${span.toPlainText()}" -> $family');
    }
  }
  expect(missing, isEmpty, reason: '$where draws text without the app font');
}

void main() {
  testWidgets('faq page text uses the app font', (tester) async {
    await tester.pumpWidget(_app(const FaqPage()));
    await tester.pump();
    _expectAllInterDisplay(tester, 'FaqPage');
  });

  testWidgets('dialogs use the app font', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => showAboutAppDialog(context),
                  child: const Text('about'),
                ),
                ElevatedButton(
                  onPressed: () => showLanguageDialog(context, current: 'tk'),
                  child: const Text('lang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('about'));
    await tester.pumpAndSettle();
    _expectAllInterDisplay(tester, 'about dialog');
    Navigator.of(tester.element(find.byType(Dialog))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('lang'));
    await tester.pumpAndSettle();
    _expectAllInterDisplay(tester, 'language dialog');
  });
}
