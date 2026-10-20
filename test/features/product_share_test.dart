import 'package:elyeter/app/router/app_router.dart';
import 'package:elyeter/features/product/domain/entities/product.dart';
import 'package:elyeter/features/product/domain/entities/product_attribute.dart';
import 'package:elyeter/features/product/domain/entities/product_variant.dart';
import 'package:elyeter/features/product/presentation/model/product_share_content.dart';
import 'package:elyeter/features/product/presentation/view/product_detail_page.dart';
import 'package:elyeter/l10n/app_localizations_en.dart';
import 'package:elyeter/l10n/app_localizations_ru.dart';
import 'package:elyeter/l10n/app_localizations_tk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const product = Product(
  id: 37224,
  slug: 'legacy-slug',
  sku: 'EL-037224',
  name: ' Travel\n suitcase ',
  price: 1286,
  oldPrice: 1600,
  mainImage: 'https://example.com/product-main.webp',
);

const variant = ProductVariant(
  id: 88,
  sku: 'EL-037224-BLUE',
  price: 1350.50,
  attributes: [
    ProductAttribute(name: 'Color', value: 'Blue'),
    ProductAttribute(name: 'Size', value: '28 inches'),
    ProductAttribute(name: 'Empty', value: ' '),
  ],
);

void main() {
  test('share has a readable price, discount, SKU and numeric app link', () {
    final share = productShareContent(
      product: product,
      l10n: AppLocalizationsEn(),
      origin: const Rect.fromLTWH(300, 40, 88, 40),
    );
    expect(share.title, 'Elýeter · Travel suitcase');
    expect(share.subject, share.title);
    expect(share.text, contains('Price: 1,286 TMT'));
    expect(share.text, contains('Regular price: 1,600 TMT · 20% discount'));
    expect(share.text, contains('Item Article: EL-037224'));
    expect(
      share.text,
      contains('Product photo:\nhttps://example.com/product-main.webp'),
    );
    expect(share.text, endsWith('elyeter://app/product/37224'));
    expect(share.text, isNot(contains('legacy-slug')));
    expect(share.uri, isNull);
    expect(share.sharePositionOrigin, const Rect.fromLTWH(300, 40, 88, 40));
  });

  test(
    'selected option shares its price and SKU without the base discount',
    () {
      final share = productShareContent(
        product: product,
        variant: variant,
        imageUrl: 'https://example.com/first-gallery-photo.webp',
        l10n: AppLocalizationsEn(),
      );
      expect(share.text, contains('Price: 1,350.50 TMT'));
      expect(share.text, contains('Color: Blue\nSize: 28 inches'));
      expect(share.text, contains('Item Article: EL-037224-BLUE'));
      expect(share.text, isNot(contains('Regular price')));
      expect(share.text, isNot(contains('Empty:')));
      expect(
        share.text,
        contains(
          'Product photo:\nhttps://example.com/first-gallery-photo.webp',
        ),
      );
      expect(share.text, isNot(contains('product-main.webp')));
      expect(share.text, endsWith('elyeter://app/product/37224?variant=88'));
    },
  );

  test('share labels follow Russian and Turkmen app languages', () {
    final ru = productShareContent(
      product: product,
      l10n: AppLocalizationsRu(),
    ).text!;
    expect(ru, contains('Цена:'));
    expect(ru, contains('Артикул: EL-037224'));
    expect(ru, contains('Открыть в приложении Elýeter:'));
    final tk = productShareContent(
      product: product,
      l10n: AppLocalizationsTk(),
    ).text!;
    expect(tk, contains('Bahasy:'));
    expect(tk, contains('Haryt kody: EL-037224'));
    expect(tk, contains('Elýeter programmasynda aç:'));
  });

  testWidgets(
    'shared URI resolves to the real product route and chosen variant',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox();
            },
          ),
        ),
      );
      final share = productShareContent(
        product: product,
        variant: variant,
        l10n: AppLocalizationsEn(),
      );
      final uri = Uri.parse(share.text!.split('\n').last);
      final configuration = AppRouter.router.configuration;
      final matches = configuration.findMatch(uri);
      expect(matches.isError, isFalse);
      expect(matches.pathParameters['id'], '37224');
      final route = matches.last.route;
      final page =
          route.builder!(
                context,
                GoRouterState(
                  configuration,
                  uri: uri,
                  matchedLocation: '/product/37224',
                  fullPath: '/product/:id',
                  pathParameters: matches.pathParameters,
                  pageKey: const ValueKey('shared-product'),
                ),
              )
              as ProductDetailPage;
      expect(page.productId, 37224);
      expect(page.initialVariantId, 88);
    },
  );
}
