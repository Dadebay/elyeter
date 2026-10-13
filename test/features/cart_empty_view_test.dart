import 'package:elyeter/core/constants/app_assets.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/theme/app_typography.dart';
import 'package:elyeter/features/cart/presentation/widgets/cart_empty_view.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty cart shows the 3D basket and app typography', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: CartEmptyView()),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppAssets.cartEmpty3d);
    for (final label in [
      'Your cart is empty',
      'Add products you like and they will wait for you here.',
      'Start shopping',
    ]) {
      expect(
        tester.widget<Text>(find.text(label)).style?.fontFamily,
        AppTypography.fontFamily,
      );
    }
    expect(tester.takeException(), isNull);
  });
}
