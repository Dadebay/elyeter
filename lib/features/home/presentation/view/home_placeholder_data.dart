import '../../../../core/constants/app_assets.dart';
import '../../../category/presentation/view/category_placeholder_data.dart';
import '../../../product/presentation/model/product_detail_data.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../widgets/brand_strip.dart';
import '../widgets/category_strip.dart';
import '../widgets/location_picker_dialog.dart';
import '../widgets/marketplace_strip.dart';
import '../widgets/promo_carousel.dart';

/// Stand-in content so the home layout can be built and reviewed before the
/// API exists. Drop this file once `HomeBloc` supplies real data; add the
/// artwork by setting `logoAsset` / `imageAsset` on these entries.
class HomePlaceholderData {
  const HomePlaceholderData();

  static const _city = 'Ashgabat';

  /// The address the app opens on until the customer picks another.
  static const DeliveryLocation defaultLocation =
      DeliveryLocation(id: 'andalyp', city: _city, district: 'Köpetdag', name: 'Andalyp Street');

  /// Delivery areas the picker offers, grouped by Ashgabat's four districts.
  static const List<DeliveryLocation> locations = [
    // Köpetdag
    defaultLocation,
    DeliveryLocation(id: 'parahat1', city: _city, district: 'Köpetdag', name: 'Parahat 1'),
    DeliveryLocation(id: 'parahat2', city: _city, district: 'Köpetdag', name: 'Parahat 2'),
    DeliveryLocation(id: 'parahat4', city: _city, district: 'Köpetdag', name: 'Parahat 4'),
    DeliveryLocation(id: 'parahat7', city: _city, district: 'Köpetdag', name: 'Parahat 7'),
    DeliveryLocation(id: 'mir3', city: _city, district: 'Köpetdag', name: 'Mir 3'),
    DeliveryLocation(id: 'mir4', city: _city, district: 'Köpetdag', name: 'Mir 4'),
    DeliveryLocation(id: 'berzenni', city: _city, district: 'Köpetdag', name: 'Berzeňňi'),
    // Berkararlyk
    DeliveryLocation(id: 'magtymguly', city: _city, district: 'Berkararlyk', name: 'Magtymguly Avenue'),
    DeliveryLocation(id: 'gorogly', city: _city, district: 'Berkararlyk', name: 'Görogly Street'),
    DeliveryLocation(id: 'mollanepes', city: _city, district: 'Berkararlyk', name: 'Mollanepes Street'),
    DeliveryLocation(id: 'oguzhan', city: _city, district: 'Berkararlyk', name: 'Oguzhan Street'),
    DeliveryLocation(id: 'teke', city: _city, district: 'Berkararlyk', name: 'Teke Bazaar'),
    DeliveryLocation(id: 'bekrewe', city: _city, district: 'Berkararlyk', name: 'Bekrewe'),
    // Bagtyýarlyk
    DeliveryLocation(id: 'gurtly', city: _city, district: 'Bagtyýarlyk', name: 'Gurtly'),
    DeliveryLocation(id: 'choganly', city: _city, district: 'Bagtyýarlyk', name: 'Çoganly'),
    DeliveryLocation(id: 'garadamak', city: _city, district: 'Bagtyýarlyk', name: 'Garadamak'),
    DeliveryLocation(id: 'yasmansalyk', city: _city, district: 'Bagtyýarlyk', name: 'Ýasmansalyk'),
    DeliveryLocation(id: 'altynasyr', city: _city, district: 'Bagtyýarlyk', name: 'Altyn Asyr Bazaar'),
    // Büzmeýin
    DeliveryLocation(id: 'buzmeyin', city: _city, district: 'Büzmeýin', name: 'Büzmeýin Centre'),
    DeliveryLocation(id: 'gypjak', city: _city, district: 'Büzmeýin', name: 'Gypjak'),
    DeliveryLocation(id: 'herrikgala', city: _city, district: 'Büzmeýin', name: 'Herrikgala'),
  ];

  static const List<MarketplaceItem> marketplaces = [
    MarketplaceItem(id: 'aliexpress', name: 'AliExpress', logoAsset: AppAssets.marketAliexpress),
    MarketplaceItem(id: 'alibaba', name: 'Alibaba', logoAsset: AppAssets.marketAlibaba),
    MarketplaceItem(id: 'taobao', name: 'Taobao', logoAsset: AppAssets.marketTaobao),
    MarketplaceItem(id: '1688', name: '1688', logoAsset: AppAssets.market1688),
  ];

  /// In the order the design's strip shows them, each with its own artwork.
  static const List<CategoryItem> categories = [
    CategoryItem(id: 'makeup', name: 'Make Up', imageAsset: AppAssets.categoryMakeUp),
    CategoryItem(id: 'electronics', name: 'Electronics', imageAsset: AppAssets.categoryElectronics),
    CategoryItem(id: 'automotive', name: 'Automotive', imageAsset: AppAssets.categoryAutomotive),
    CategoryItem(id: 'stationery', name: 'Stationery', imageAsset: AppAssets.categoryStationery),
    CategoryItem(id: 'jewellery', name: 'Jewellery', imageAsset: AppAssets.categoryJewellery),
  ];

  /// The artwork carries its own headline, so no text is drawn over it.
  static const List<PromoBanner> banners = [
    PromoBanner(id: 'look', imageAsset: AppAssets.bannerLook),
    PromoBanner(id: 'tech', imageAsset: AppAssets.bannerTech),
    PromoBanner(id: 'style', imageAsset: AppAssets.bannerStyle),
  ];

  static const List<BrandItem> brands = [
    BrandItem(id: 'loro', name: 'Loro Piana', logoAsset: AppAssets.brandLoroPiana),
    BrandItem(id: 'jordan', name: 'Jordan', logoAsset: AppAssets.brandJordan),
    BrandItem(id: 'lacoste', name: 'Lacoste', logoAsset: AppAssets.brandLacoste),
    BrandItem(id: 'tissot', name: 'Tissot', logoAsset: AppAssets.brandTissot),
    BrandItem(id: 'clothing', name: 'Clothing Store', logoAsset: AppAssets.brandClothingStore),
  ];

  /// One product per supplied photo. Each also lists a couple of the other
  /// photos so the card's swipe and its dots have something to show until the
  /// API supplies real galleries.
  static const List<ProductCardData> products = [
    ProductCardData(
      id: '1',
      title: 'Loro Piana Summer Walk suede loafers',
      price: 7526,
      oldPrice: 9408,
      images: [AppAssets.productLoafers, AppAssets.productBag, AppAssets.productWatch],
      specs: ['Material: suede', 'Size: 42 EU'],
    ),
    ProductCardData(
      id: '2',
      title: 'Lacoste ribbed cotton T-shirt',
      price: 1240,
      images: [AppAssets.productTshirt, AppAssets.productPerfume],
      specs: ['Material: 100% cotton', 'Fit: regular'],
    ),
    ProductCardData(
      id: '3',
      title: 'Tissot Le Locle Powermatic 80',
      price: 12890,
      oldPrice: 14320,
      images: [AppAssets.productWatch, AppAssets.productLoafers, AppAssets.productSuitcase],
      specs: ['Movement: Powermatic 80', 'Case: 39 mm steel'],
    ),
    ProductCardData(
      id: '4',
      title: 'Monogram cabin trolley, 55 cm',
      price: 23750,
      images: [AppAssets.productSuitcase, AppAssets.productBag],
      specs: ['Cabin size: 55 cm', 'Material: coated canvas'],
    ),
    ProductCardData(
      id: '5',
      title: 'Alma BB monogram handbag',
      price: 18990,
      oldPrice: 21800,
      images: [AppAssets.productBag, AppAssets.productPerfume, AppAssets.productTshirt],
      specs: ['Material: monogram canvas', 'Strap: removable'],
    ),
    ProductCardData(
      id: '6',
      title: 'Miss Dior Eau de Parfum, 100 ml',
      price: 2340,
      images: [AppAssets.productPerfume, AppAssets.productBag],
      specs: ['Volume: 100 ml', 'Type: Eau de Parfum'],
    ),
    ProductCardData(
      id: '7',
      title: 'Apple iPhone 17 Pro 256 GB, Dual nano SIM + eSIM, Deep Blue',
      price: 24500,
      oldPrice: 25000,
      images: [AppAssets.productPhone, AppAssets.productSmartWatch],
      specs: ['Built-in memory: 256 GB', 'Protection rating: IP68'],
    ),
    ProductCardData(
      id: '8',
      title: 'Ring, silver, 925 hallmark, gilding, Swarovski crystals',
      price: 2539,
      oldPrice: 4220,
      images: [AppAssets.productRing],
      specs: ['Ring size: 16.5', 'Material: Jewelry Alloy'],
    ),
    ProductCardData(
      id: '9',
      title: 'Apple Watch Series 11 42 mm A3331 Sport Band S/M, black',
      price: 30059,
      oldPrice: 39139,
      images: [AppAssets.productSmartWatch, AppAssets.productPhone],
      specs: ['Case material: metal', 'Case size: 42 mm'],
    ),
    ProductCardData(
      id: '10',
      title: 'PUMA TRC Plaza R-90 trainers',
      price: 1290,
      oldPrice: 1990,
      images: [AppAssets.productSneakers],
      specs: ['Fastening: laces', 'Upper: mesh and suede'],
    ),
  ];

  /// A cart that already holds the four products the cart design was drawn
  /// around, so the Cart tab shows the real layout on a fresh install
  /// instead of its empty state. Product id -> quantity.
  ///
  /// Only seeds the first launch: once the customer touches the cart their
  /// own state is stored and this is never consulted again. Drop it with the
  /// rest of this file once the API supplies the cart.
  static const Map<String, int> demoCart = {'7': 1, '8': 10, '9': 2, '10': 1};

  /// Everything an id can resolve to: the home grid plus what only a
  /// category lists. The cart, favourites and the detail page look here, so
  /// a product added from a category is not lost on the way back.
  static List<ProductCardData> get catalog => [
    ...products,
    ...CategoryPlaceholderData.products,
  ];

  /// The catalog entry for [id], or null when it is no longer listed.
  static ProductCardData? productById(String id) {
    for (final product in catalog) {
      if (product.id == id) return product;
    }
    return null;
  }

  /// Detail-page content for [product]. Derived from the catalog entry so the
  /// two never disagree, with the extra fields stood in until the API lands.
  static ProductDetailData detailFor(ProductCardData product) {
    // Deterministic from the id: the same product reads the same on every
    // launch, which random numbers would not.
    final seed = int.tryParse(product.id) ?? product.id.length;

    return ProductDetailData(
      product: product,
      rating: 4.3 + (seed % 5) / 10,
      reviewCount: 120 + seed * 47,
      orderCount: 3800 + seed * 1290,
      ratingCount: 90 + seed * 29,
      colorName: _colorNames[seed % _colorNames.length],
      sizes: _sizesFor(product),
      article: '${4391000000 + seed * 31517}',
      description: _description,
      // Longer than the card's preview on purpose, so the block has
      // something to reveal when it is expanded.
      characteristics: {
        'Brand': product.title.split(' ').first,
        'Collection': 'Fashion and style',
        'Product color': _colorNames[seed % _colorNames.length],
        for (final spec in product.specs)
          if (spec.contains(':')) spec.split(':').first.trim(): spec.split(':').last.trim(),
        'Type': 'accessory',
        'Model': product.title.split(' ').last,
        'Audience': "for girls, women's, men's",
        'Package': '1 piece',
        'Country': 'China',
        'Warranty': '12 months',
        'Seller': 'Elyeter Marketplace',
        'Delivery': '7-14 days',
      },
      ratingBreakdown: const [0.68, 0.18, 0.07, 0.04, 0.03],
      reviews: _reviews,
    );
  }

  static const _colorNames = ['Pink', 'Black', 'Silver', 'Beige', 'Green', 'Gold'];

  /// Ring sizes for jewellery, clothing sizes otherwise — the chips are the
  /// same control either way.
  static List<String> _sizesFor(ProductCardData product) =>
      product.title.toLowerCase().contains('shirt')
      ? const ['S', 'M', 'L', 'XL']
      : const ['16.5', '17.0', '17.5', '18.0'];

  static const _description =
      'Made from carefully selected materials and finished by hand, this '
      'piece is built to be worn every day. The proportions follow the '
      'house pattern, so it sits the way the photographs show it, and the '
      'finish keeps its colour through normal wear.';

  static const _reviews = [
    ProductReview(
      author: 'Aline Bysse',
      date: 'Aug 21, 2025',
      rating: 5,
      text: 'Arrived faster than promised and looks exactly like the photos. '
          'The finish is even and there were no marks anywhere.',
    ),
    ProductReview(
      author: 'Merjen A.',
      date: 'Aug 2, 2025',
      rating: 4,
      text: 'Good quality for the price. One star off because the box was '
          'dented, but the product itself is fine.',
    ),
    ProductReview(
      author: 'Serdar K.',
      date: 'Jul 18, 2025',
      rating: 5,
      text: 'Second one I order. Sizing is true and delivery to Ashgabat took '
          'about a week.',
    ),
  ];
}
