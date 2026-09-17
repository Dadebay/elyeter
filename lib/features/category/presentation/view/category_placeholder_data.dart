import '../../../../core/constants/app_assets.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../widgets/subcategory_grid.dart';

/// Stand-in contents for one category until the catalogue API lands. Replace
/// with `CategoryBloc` state; the widgets take plain values, so nothing else
/// moves.
abstract final class CategoryPlaceholderData {
  /// The tiles across the top of a category, in the order the design shows
  /// them.
  static const List<SubcategoryItem> subcategories = [
    SubcategoryItem(id: 'gaming-mice', name: 'Gaming Mice', imageAsset: AppAssets.subGamingMice),
    SubcategoryItem(id: 'earbuds', name: 'Earbuds', imageAsset: AppAssets.subEarbuds),
    SubcategoryItem(id: 'controllers', name: 'Gaming Controllers', imageAsset: AppAssets.subControllers),
    SubcategoryItem(id: 'smartwatches', name: 'Smartwatches', imageAsset: AppAssets.subSmartwatches),
    SubcategoryItem(id: 'smartphones', name: 'Smartphones', imageAsset: AppAssets.subSmartphones),
    SubcategoryItem(id: 'phone-cases', name: 'Phone Cases', imageAsset: AppAssets.subPhoneCases),
    SubcategoryItem(id: 'cameras', name: 'Cameras', imageAsset: AppAssets.subCameras),
    SubcategoryItem(id: 'ps5-games', name: 'PS5 Games', imageAsset: AppAssets.subPs5Games),
  ];

  /// The tiles [id] should show. A subcategory has none of its own — it is
  /// already the bottom of the tree — so its page opens straight onto the
  /// filters, as the design draws it.
  static List<SubcategoryItem> subcategoriesFor(String id) =>
      subcategories.any((item) => item.id == id) ? const [] : subcategories;

  /// What the category lists. Ids continue past the home catalogue so the
  /// cart and favourites can hold both without a collision.
  static const List<ProductCardData> products = [
    ProductCardData(
      id: 'e1',
      title: 'Apple TV Model 4K 2022 Edition HD Set-Top Box with Siri Remote',
      price: 22329,
      oldPrice: 27911,
      images: [AppAssets.productAppleTv],
      specs: ['Storage: 64 GB', 'Resolution: 4K HDR'],
      attributes: {
        'brand': 'Apple',
        'material': 'Aluminium',
        'color': 'Black',
      },
    ),
    ProductCardData(
      id: 'e2',
      title: 'Apple silicone case for iPhone 15 Pro Max, orange',
      price: 5702,
      images: [AppAssets.productPhoneCase],
      specs: ['Material: silicone', 'MagSafe: yes'],
      attributes: {
        'brand': 'Apple',
        'material': 'Silicone',
        'color': 'Orange',
      },
    ),
    ProductCardData(
      id: 'e3',
      title: 'Beats Studio Buds+ wireless headphones',
      price: 13572,
      oldPrice: 15990,
      images: [AppAssets.productBeats],
      specs: ['Noise cancelling: active', 'Battery: 36 h with case'],
      attributes: {
        'brand': 'Beats',
        'material': 'Plastic',
        'color': 'Black',
      },
    ),
    ProductCardData(
      id: 'e4',
      title: 'FUJIFILM INSTAX MINI 9 instant camera',
      price: 10668,
      images: [AppAssets.productInstax],
      specs: ['Film: Instax Mini', 'Close-up lens: included'],
      attributes: {
        'brand': 'Fujifilm',
        'material': 'Plastic',
        'color': 'Blue',
      },
    ),
    ProductCardData(
      id: 'e5',
      title: 'Xiaomi 14 5G, 12/512 GB, Jade Green',
      price: 19450,
      oldPrice: 22900,
      images: [AppAssets.productXiaomi],
      specs: ['Built-in memory: 512 GB', 'Screen: 6.36" AMOLED'],
      attributes: {
        'brand': 'Xiaomi',
        'material': 'Glass',
        'color': 'Green',
      },
    ),
    ProductCardData(
      id: 'e6',
      title: 'Braided USB-C to USB-A coiled cable, 1.5 m',
      price: 289,
      images: [AppAssets.productCable],
      specs: ['Length: 1.5 m', 'Output: 60 W'],
      attributes: {
        'brand': 'Elyeter',
        'material': 'Braided nylon',
        'color': 'Black',
      },
    ),
    ProductCardData(
      id: 'e7',
      title: 'Apple iPhone 17 Pro 256 GB, Cosmic Orange',
      price: 24500,
      oldPrice: 25000,
      images: [AppAssets.productIphoneOrange, AppAssets.productIphoneWhite],
      specs: ['Built-in memory: 256 GB', 'Protection rating: IP68'],
      attributes: {
        'brand': 'Apple',
        'material': 'Titanium',
        'color': 'Orange',
      },
    ),
    ProductCardData(
      id: 'e8',
      title: 'Apple iPhone 17 Pro 512 GB, Deep Blue',
      price: 27900,
      images: [AppAssets.productIphoneBlue, AppAssets.productIphoneOrange],
      specs: ['Built-in memory: 512 GB', 'Protection rating: IP68'],
      attributes: {
        'brand': 'Apple',
        'material': 'Titanium',
        'color': 'Blue',
      },
    ),
    ProductCardData(
      id: 'e9',
      title: 'Apple iPhone 16 128 GB, Green',
      price: 16400,
      oldPrice: 18200,
      images: [AppAssets.productIphoneGreen],
      specs: ['Built-in memory: 128 GB', 'Screen: 6.1"'],
      attributes: {
        'brand': 'Apple',
        'material': 'Aluminium',
        'color': 'Green',
      },
    ),
    ProductCardData(
      id: 'e10',
      title: 'Apple iPhone 16 256 GB, Ultramarine',
      price: 18900,
      images: [AppAssets.productIphoneLightBlue],
      specs: ['Built-in memory: 256 GB', 'Screen: 6.1"'],
      attributes: {
        'brand': 'Apple',
        'material': 'Aluminium',
        'color': 'Blue',
      },
    ),
    ProductCardData(
      id: 'e11',
      title: 'Apple iPhone 16 128 GB, Pink',
      price: 16400,
      images: [AppAssets.productIphonePink],
      specs: ['Built-in memory: 128 GB', 'Screen: 6.1"'],
      attributes: {
        'brand': 'Apple',
        'material': 'Aluminium',
        'color': 'Pink',
      },
    ),
    ProductCardData(
      id: 'e12',
      title: 'Apple iPhone 17 Pro 256 GB, Silver',
      price: 24500,
      oldPrice: 26800,
      images: [AppAssets.productIphoneWhite, AppAssets.productIphoneBlue],
      specs: ['Built-in memory: 256 GB', 'Protection rating: IP68'],
      attributes: {
        'brand': 'Apple',
        'material': 'Titanium',
        'color': 'Silver',
      },
    ),
  ];
}
