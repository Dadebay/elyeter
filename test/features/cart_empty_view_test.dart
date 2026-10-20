import 'package:elyeter/core/constants/app_assets.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/theme/app_typography.dart';
import 'package:elyeter/core/widgets/app_asset_image.dart';
import 'package:elyeter/core/widgets/catalog_empty_view.dart';
import 'package:elyeter/features/cart/presentation/widgets/cart_empty_view.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty cart shows the supplied illustration and app typography', (
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
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<AppAssetImage>(find.byType(AppAssetImage));
    expect(image.path, AppAssets.cartEmptyIllustration);
    expect(
      tester.getSize(find.byType(FilledButton)).width,
      tester.getSize(find.text('Shopping')).width + 40,
    );
    for (final label in [
      'Your Cart Is Empty',
      'You haven’t added any items yet. Explore our collection and find your favorites.',
      'Shopping',
    ]) {
      expect(
        tester.widget<Text>(find.text(label)).style?.fontFamily,
        AppTypography.fontFamily,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorite illustration loads', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatalogEmptyView(
            illustration: AppAssets.favoriteEmptyIllustration,
            title: 'No Favorites Yet',
            message:
                'Save your favorite items and find them here whenever you need them.',
            actionLabel: 'Explore',
            onAction: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      AppAssets.favoriteEmptyIllustration,
    );
    expect(tester.takeException(), isNull);
  });
}
