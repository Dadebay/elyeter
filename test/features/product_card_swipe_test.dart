import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/product/presentation/widgets/product_card.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('photo animation uses its own pager when controller is shared', (
    tester,
  ) async {
    const product = ProductCardData(
      id: 'test-product',
      title: 'Test product',
      price: 100,
      images: [
        'assets/images/cart_empty_illustration.png',
        'assets/images/favorite_empty_illustration.png',
      ],
    );

    Widget app(PageController? sharedController) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          children: [
            const SizedBox(
              width: 180,
              height: 316,
              child: ProductCard(data: product),
            ),
            if (sharedController != null)
              SizedBox(
                height: 100,
                child: PageView(
                  controller: sharedController,
                  children: const [ColoredBox(color: Colors.blue)],
                ),
              ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(app(null));
    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;

    await tester.pumpWidget(app(controller));
    await tester.drag(find.byType(PageView).first, const Offset(-60, 0));
    await tester.pump();

    expect(controller.positions.length, 2);
    expect(tester.takeException(), isNull);
  });
}
