// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Elyeter';

  @override
  String get navHome => 'Home';

  @override
  String get navCategory => 'Category';

  @override
  String get navCart => 'Cart';

  @override
  String get navFavorite => 'Favorite';

  @override
  String get favoriteTitle => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSearch => 'Search';

  @override
  String get homeSearchHint => 'Search product';

  @override
  String get locationTitle => 'Delivery address';

  @override
  String get locationSearchHint => 'Search area or street';

  @override
  String get locationEmpty => 'No matching address';

  @override
  String get visualSearchTitle => 'Search by photo';

  @override
  String get visualSearchHint => 'Place the product in the frame to scan';

  @override
  String get visualSearchCamera => 'Take a photo';

  @override
  String get visualSearchRetake => 'Retake';

  @override
  String get visualSearchUse => 'Use photo';

  @override
  String get visualSearchGallery => 'Choose from gallery';

  @override
  String get visualSearchNoCamera => 'No camera is available on this device.';

  @override
  String get visualSearchDenied =>
      'Elyeter needs camera access to search by photo. Allow it in Settings.';

  @override
  String get visualSearchReady => 'Photo ready — visual search is coming soon.';

  @override
  String commonOpenFailed(String target) {
    return 'Could not open $target';
  }

  @override
  String get orderActiveTitle => 'Active Order';

  @override
  String orderNumber(String number) {
    return 'Order No. $number';
  }

  @override
  String get orderRepeat => 'Repeat order';

  @override
  String get orderQuestions => 'Questions';

  @override
  String get orderCancel => 'Cancel';

  @override
  String get orderProgress => 'Delivery Progress';

  @override
  String get orderStepPlaced => 'Order Placed';

  @override
  String get orderStepWarehouse => 'Arrived at China Warehouse';

  @override
  String get orderStepShipped => 'Shipped to Turkmenistan';

  @override
  String get orderStepArrived => 'Arrived in Turkmenistan';

  @override
  String get orderStepDelivered => 'Delivered';

  @override
  String get orderProducts => 'Delivery Products';

  @override
  String orderItemSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items for $total',
      one: '1 item for $total',
    );
    return '$_temp0';
  }

  @override
  String get orderPickupPoint => 'Pick-up point';

  @override
  String get orderRecipient => 'Recipient';

  @override
  String get orderTime => 'Order Time';

  @override
  String get orderPayment => 'Payment Method';

  @override
  String get orderPaymentCard => 'By card / Card payment';

  @override
  String get orderTotalTitle => 'Order Total';

  @override
  String get orderProductsTotal => 'Products Total';

  @override
  String get orderDeliveryLabel => 'Delivery';

  @override
  String get orderDeliveryFree => 'Free';

  @override
  String get orderCargo => 'Cargo';

  @override
  String get orderDiscount => 'Discount';

  @override
  String get orderDownloadCheck => 'Download Check';

  @override
  String get categoryFilterMaterial => 'Material';

  @override
  String get categoryFilterColor => 'Color';

  @override
  String get categoryFilterBrand => 'Brand';

  @override
  String get categorySearch => 'Search';

  @override
  String get categoryFilters => 'Filters';

  @override
  String get categorySortTitle => 'Sort by';

  @override
  String get categorySortPopular => 'Popular';

  @override
  String get categorySortPriceAsc => 'Price: low to high';

  @override
  String get categorySortPriceDesc => 'Price: high to low';

  @override
  String get categorySortDiscount => 'Biggest discount';

  @override
  String get categoryApply => 'Apply';

  @override
  String get categoryReset => 'Reset';

  @override
  String get categoryNoResults => 'Nothing matches these filters';

  @override
  String get categoryNoResultsHint => 'Try removing one of them.';

  @override
  String categoryFacetSearch(String facet) {
    return 'Search $facet';
  }

  @override
  String categorySelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get searchTitle => 'Search';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonAddToCart => 'Add to Card';

  @override
  String get commonAdded => 'Added';

  @override
  String get cartDelete => 'Delete';

  @override
  String get cartSelectAll => 'Select All';

  @override
  String cartProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Product',
      one: '1 Product',
    );
    return '$_temp0';
  }

  @override
  String get commonCheckout => 'Checkout';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonEmpty => 'Nothing here yet';

  @override
  String productReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String productOrderCount(int count) {
    return '$count order';
  }

  @override
  String productColor(String name) {
    return 'Color: $name';
  }

  @override
  String productSize(String size) {
    return 'Ring size: $size';
  }

  @override
  String get productArticle => 'Item Article:';

  @override
  String get productCopy => 'Copy';

  @override
  String get productCopied => 'Article copied';

  @override
  String get productShared => 'Product link copied';

  @override
  String get productDescription => 'Description';

  @override
  String get productReadMore => 'Read More';

  @override
  String get productReadLess => 'Show less';

  @override
  String get productCharacteristics => 'Characteristics';

  @override
  String get productAllCharacteristics => 'All characteristics';

  @override
  String get productReviews => 'Reviews';

  @override
  String productRatingCount(int count) {
    return '$count ratings';
  }

  @override
  String get productReadAllReviews => 'Read all reviews';

  @override
  String get orderActive => 'Active Order';

  @override
  String get orderCompleted => 'Order Completed';

  @override
  String get orderCancelled => 'Order Cancelled';

  @override
  String get orderHistory => 'Order history';

  @override
  String orderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get errorServer => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorTimeout => 'The request took too long.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorCache => 'Could not read saved data.';

  @override
  String get errorUnknown => 'Unexpected error.';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileAllOrders => 'All Orders';

  @override
  String profileOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Orders',
      one: '1 Order',
      zero: 'No orders',
    );
    return '$_temp0';
  }

  @override
  String get profileSectionGeneral => 'General';

  @override
  String get profileSectionOther => 'Other';

  @override
  String get profileSectionContact => 'Contact Us';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileActiveOrders => 'Active orders';

  @override
  String get profileSavedLocations => 'My saved locations';

  @override
  String get profileOrderHistory => 'Order history';

  @override
  String get profileAnnouncements => 'Announcements';

  @override
  String get profileDarkMode => 'Dark mode';

  @override
  String get profileAboutApp => 'About the app';

  @override
  String get profileFaq => 'FAQ';

  @override
  String get profileTerms => 'Terms of use';

  @override
  String get profilePrivacy => 'Privacy policy';

  @override
  String get profileWhatsapp => 'WhatsApp';

  @override
  String get profileInstagram => 'Instagram';

  @override
  String get profileTiktok => 'TikTok';

  @override
  String get profileCallTitle => 'Call us with any question:';

  @override
  String get profileCallAction => 'Call operator';

  @override
  String get profileCallHours =>
      'Calls are answered every day of the week, 09:00 - 19:00';

  @override
  String profileVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageTurkmen => 'Türkmençe';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileName => 'Full name';

  @override
  String get editProfileNameHint => 'Your name';

  @override
  String get editProfilePhone => 'Phone number';

  @override
  String get editProfilePhoneNote => 'Contact support to change your number';

  @override
  String get editProfilePhoto => 'Change photo';

  @override
  String get editProfilePhotoCamera => 'Take a photo';

  @override
  String get editProfilePhotoGallery => 'Choose from gallery';

  @override
  String get editProfilePhotoRemove => 'Remove photo';

  @override
  String get editProfileSaved => 'Profile updated';

  @override
  String get editProfileNameRequired => 'Please enter your name';

  @override
  String get editProfilePhotoHint => 'Tap the photo to change it';

  @override
  String editProfileNameCounter(int count) {
    return '$count/40';
  }

  @override
  String get editProfileNothingChanged => 'Nothing to save yet';

  @override
  String get aboutTagline =>
      'Everything from the big marketplaces, delivered to Turkmenistan.';

  @override
  String legalUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqQ1 => 'How do I place an order?';

  @override
  String get faqA1 =>
      'Add what you want to the cart, open the Cart tab and tap Checkout. The total, including delivery, is shown before you confirm.';

  @override
  String get faqQ2 => 'How long does delivery take?';

  @override
  String get faqA2 =>
      'Items in local stock arrive in 1–3 days. Orders from partner marketplaces take 10–20 days, depending on the seller.';

  @override
  String get faqQ3 => 'How do I track my order?';

  @override
  String get faqA3 =>
      'Open Profile → Active orders. Every step from confirmation to delivery is listed there.';

  @override
  String get faqQ4 => 'Can I cancel an order?';

  @override
  String get faqA4 =>
      'Yes, while it is still marked Confirmed. Once it has shipped, call the operator and we will help.';

  @override
  String get faqQ5 => 'How do returns work?';

  @override
  String get faqA5 =>
      'Call the operator within 3 days of delivery. Unused items in their original packaging are accepted.';

  @override
  String get termsTitle => 'Terms of use';

  @override
  String get termsS1 => 'Using the app';

  @override
  String get termsB1 =>
      'By using Elyeter you accept these terms. If you do not agree with them, please stop using the app.';

  @override
  String get termsS2 => 'Orders and prices';

  @override
  String get termsB2 =>
      'Prices are shown in TMT and may change until an order is confirmed. Availability at partner marketplaces is outside our control.';

  @override
  String get termsS3 => 'Delivery';

  @override
  String get termsB3 =>
      'Delivery times are estimates, not guarantees. Customs and seller delays can extend them.';

  @override
  String get termsS4 => 'Returns';

  @override
  String get termsB4 =>
      'Unused items in original packaging can be returned within 3 days of delivery. Made-to-order and personal-care items cannot.';

  @override
  String get termsS5 => 'Your account';

  @override
  String get termsB5 =>
      'Your phone number identifies your account. Keep it up to date — orders and delivery calls go to it.';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyS1 => 'What we collect';

  @override
  String get privacyB1 =>
      'Your name, phone number, delivery address and order history. Nothing else is required to use Elyeter.';

  @override
  String get privacyS2 => 'Why we use it';

  @override
  String get privacyB2 =>
      'To deliver your orders, keep you updated about them and answer you when you contact support.';

  @override
  String get privacyS3 => 'Who we share it with';

  @override
  String get privacyB3 =>
      'Only couriers and payment providers, and only the part they need to complete your order. We never sell your data.';

  @override
  String get privacyS4 => 'How long we keep it';

  @override
  String get privacyB4 =>
      'While your account exists, plus the period accounting rules require for completed orders.';

  @override
  String get privacyS5 => 'Your rights';

  @override
  String get privacyB5 =>
      'Call the operator to get a copy of your data or ask for your account to be deleted.';

  @override
  String get categoryTitle => 'Categories';
}
