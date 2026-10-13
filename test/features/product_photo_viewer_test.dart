import 'package:cached_network_image/cached_network_image.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/product/presentation/view/product_photo_viewer_page.dart';
import 'package:elyeter/features/product/presentation/widgets/product_gallery.dart';
import 'package:elyeter/features/product/presentation/widgets/product_option_picker.dart';
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
  testWidgets('API photo URLs use network images in gallery and viewer', (
    tester,
  ) async {
    const url = 'https://example.com/products/photo.webp';

    await tester.pumpWidget(
      _app(const Scaffold(body: ProductGallery(images: [url]))),
    );
    expect(
      tester
          .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .imageUrl,
      url,
    );

    await tester.pumpWidget(_app(const ProductPhotoViewerPage(images: [url])));
    expect(
      tester
          .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .imageUrl,
      url,
    );

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: ProductColorPicker(
            images: const [url],
            selected: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .imageUrl,
      url,
    );
  });

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

    await tester.drag(
      find.byType(InteractiveViewer).first,
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProductPhotoViewerPage), findsNothing);
  });
}
