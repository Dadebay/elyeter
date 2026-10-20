import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/theme/app_typography.dart';
import 'package:elyeter/features/profile/presentation/widgets/language_dialog.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showLanguageDialog(context, current: 'en'),
              child: const Text('Open language'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open language'));
    await tester.pump();
  }

  testWidgets('language sheet rises a short distance while opening', (
    tester,
  ) async {
    await openSheet(tester);
    final sheet = find.byKey(const Key('language-sheet'));
    final start = tester.getTopLeft(sheet).dy;

    await tester.pump(const Duration(milliseconds: 100));
    final middle = tester.getTopLeft(sheet).dy;

    await tester.pumpAndSettle();
    final end = tester.getTopLeft(sheet).dy;

    expect(start, greaterThan(middle));
    expect(middle, greaterThan(end));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps the sheet in place', (tester) async {
    await openSheet(tester, reduceMotion: true);
    final sheet = find.byKey(const Key('language-sheet'));
    final start = tester.getTopLeft(sheet).dy;

    await tester.pumpAndSettle();

    expect(tester.getTopLeft(sheet).dy, closeTo(start, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('language sheet text uses the app font', (tester) async {
    await openSheet(tester);
    await tester.pumpAndSettle();

    for (final label in ['English', 'Русский', 'Türkmençe']) {
      expect(find.text(label), findsWidgets);
      for (final widget in tester.widgetList<Text>(find.text(label))) {
        expect(widget.style?.fontFamily, AppTypography.fontFamily);
      }
    }
  });
}
