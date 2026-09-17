import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/product/presentation/view/product_photo_viewer_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _images = [
  'assets/images/category_image.png',
  'assets/images/category_image.png',
  'assets/images/category_image.png',
];

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
  testWidgets('double tap zooms in and out again', (tester) async {
    await tester.pumpWidget(
      _app(const ProductPhotoViewerPage(images: _images)),
    );
    await tester.pumpAndSettle();

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer).first,
    );
    final controller = viewer.transformationController!;
    expect(controller.value.getMaxScaleOnAxis(), 1);

    final centre = tester.getCenter(find.byType(InteractiveViewer).first);
    await tester.tapAt(centre);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(centre);
    await tester.pumpAndSettle();
    expect(
      controller.value.getMaxScaleOnAxis(),
      greaterThan(2),
      reason: 'double tap should zoom in',
    );

    await tester.tapAt(centre);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(centre);
    await tester.pumpAndSettle();
    expect(
      controller.value.getMaxScaleOnAxis(),
      1,
      reason: 'double tap again should reset',
    );
  });

  testWidgets('dragging the photo down closes the viewer', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    ProductPhotoViewerPage.open(context, images: _images),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductPhotoViewerPage), findsOneWidget);

    await tester.drag(find.byType(InteractiveViewer).first, const Offset(0, 200));
    await tester.pumpAndSettle();

    expect(find.byType(ProductPhotoViewerPage), findsNothing);
  });
}
