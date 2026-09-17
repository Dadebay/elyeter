import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tk'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Elyeter'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get navCategory;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get navFavorite;

  /// No description provided for @favoriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoriteTitle;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search product'**
  String get homeSearchHint;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get locationTitle;

  /// No description provided for @locationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search area or street'**
  String get locationSearchHint;

  /// No description provided for @locationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching address'**
  String get locationEmpty;

  /// No description provided for @visualSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by photo'**
  String get visualSearchTitle;

  /// No description provided for @visualSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Place the product in the frame to scan'**
  String get visualSearchHint;

  /// No description provided for @visualSearchCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get visualSearchCamera;

  /// No description provided for @visualSearchRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get visualSearchRetake;

  /// No description provided for @visualSearchUse.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get visualSearchUse;

  /// No description provided for @visualSearchGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get visualSearchGallery;

  /// No description provided for @visualSearchNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera is available on this device.'**
  String get visualSearchNoCamera;

  /// No description provided for @visualSearchDenied.
  ///
  /// In en, this message translates to:
  /// **'Elyeter needs camera access to search by photo. Allow it in Settings.'**
  String get visualSearchDenied;

  /// No description provided for @visualSearchReady.
  ///
  /// In en, this message translates to:
  /// **'Photo ready — visual search is coming soon.'**
  String get visualSearchReady;

  /// No description provided for @commonOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open {target}'**
  String commonOpenFailed(String target);

  /// No description provided for @orderActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Order'**
  String get orderActiveTitle;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order No. {number}'**
  String orderNumber(String number);

  /// No description provided for @orderRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat order'**
  String get orderRepeat;

  /// No description provided for @orderQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get orderQuestions;

  /// No description provided for @orderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get orderCancel;

  /// No description provided for @orderProgress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Progress'**
  String get orderProgress;

  /// No description provided for @orderStepPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderStepPlaced;

  /// No description provided for @orderStepWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Arrived at China Warehouse'**
  String get orderStepWarehouse;

  /// No description provided for @orderStepShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped to Turkmenistan'**
  String get orderStepShipped;

  /// No description provided for @orderStepArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived in Turkmenistan'**
  String get orderStepArrived;

  /// No description provided for @orderStepDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStepDelivered;

  /// No description provided for @orderProducts.
  ///
  /// In en, this message translates to:
  /// **'Delivery Products'**
  String get orderProducts;

  /// No description provided for @orderItemSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item for {total}} other{{count} items for {total}}}'**
  String orderItemSummary(int count, String total);

  /// No description provided for @orderPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pick-up point'**
  String get orderPickupPoint;

  /// No description provided for @orderRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get orderRecipient;

  /// No description provided for @orderTime.
  ///
  /// In en, this message translates to:
  /// **'Order Time'**
  String get orderTime;

  /// No description provided for @orderPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get orderPayment;

  /// No description provided for @orderPaymentCard.
  ///
  /// In en, this message translates to:
  /// **'By card / Card payment'**
  String get orderPaymentCard;

  /// No description provided for @orderTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotalTitle;

  /// No description provided for @orderProductsTotal.
  ///
  /// In en, this message translates to:
  /// **'Products Total'**
  String get orderProductsTotal;

  /// No description provided for @orderDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get orderDeliveryLabel;

  /// No description provided for @orderDeliveryFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get orderDeliveryFree;

  /// No description provided for @orderCargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get orderCargo;

  /// No description provided for @orderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get orderDiscount;

  /// No description provided for @orderDownloadCheck.
  ///
  /// In en, this message translates to:
  /// **'Download Check'**
  String get orderDownloadCheck;

  /// No description provided for @categoryFilterMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get categoryFilterMaterial;

  /// No description provided for @categoryFilterColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryFilterColor;

  /// No description provided for @categoryFilterBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get categoryFilterBrand;

  /// No description provided for @categorySearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get categorySearch;

  /// No description provided for @categoryFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get categoryFilters;

  /// No description provided for @categorySortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get categorySortTitle;

  /// No description provided for @categorySortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get categorySortPopular;

  /// No description provided for @categorySortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get categorySortPriceAsc;

  /// No description provided for @categorySortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get categorySortPriceDesc;

  /// No description provided for @categorySortDiscount.
  ///
  /// In en, this message translates to:
  /// **'Biggest discount'**
  String get categorySortDiscount;

  /// No description provided for @categoryApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get categoryApply;

  /// No description provided for @categoryReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get categoryReset;

  /// No description provided for @categoryNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get categoryNoResults;

  /// No description provided for @categoryNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try removing one of them.'**
  String get categoryNoResultsHint;

  /// No description provided for @categoryFacetSearch.
  ///
  /// In en, this message translates to:
  /// **'Search {facet}'**
  String categoryFacetSearch(String facet);

  /// No description provided for @categorySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String categorySelectedCount(int count);

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Card'**
  String get commonAddToCart;

  /// No description provided for @commonAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get commonAdded;

  /// No description provided for @cartDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cartDelete;

  /// No description provided for @cartSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get cartSelectAll;

  /// No description provided for @cartProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Product} other{{count} Product}}'**
  String cartProductCount(int count);

  /// No description provided for @commonCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get commonCheckout;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get commonEmpty;

  /// No description provided for @productReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String productReviewCount(int count);

  /// No description provided for @productOrderCount.
  ///
  /// In en, this message translates to:
  /// **'{count} order'**
  String productOrderCount(int count);

  /// No description provided for @productColor.
  ///
  /// In en, this message translates to:
  /// **'Color: {name}'**
  String productColor(String name);

  /// No description provided for @productSize.
  ///
  /// In en, this message translates to:
  /// **'Ring size: {size}'**
  String productSize(String size);

  /// No description provided for @productArticle.
  ///
  /// In en, this message translates to:
  /// **'Item Article:'**
  String get productArticle;

  /// No description provided for @productCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get productCopy;

  /// No description provided for @productCopied.
  ///
  /// In en, this message translates to:
  /// **'Article copied'**
  String get productCopied;

  /// No description provided for @productShared.
  ///
  /// In en, this message translates to:
  /// **'Product link copied'**
  String get productShared;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// No description provided for @productReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get productReadMore;

  /// No description provided for @productReadLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get productReadLess;

  /// No description provided for @productCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'Characteristics'**
  String get productCharacteristics;

  /// No description provided for @productAllCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'All characteristics'**
  String get productAllCharacteristics;

  /// No description provided for @productReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get productReviews;

  /// No description provided for @productRatingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String productRatingCount(int count);

  /// No description provided for @productReadAllReviews.
  ///
  /// In en, this message translates to:
  /// **'Read all reviews'**
  String get productReadAllReviews;

  /// No description provided for @orderActive.
  ///
  /// In en, this message translates to:
  /// **'Active Order'**
  String get orderActive;

  /// No description provided for @orderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order Completed'**
  String get orderCompleted;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCancelled;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistory;

  /// No description provided for @orderItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No products} =1{1 product} other{{count} products}}'**
  String orderItemCount(int count);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorServer;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @errorCache.
  ///
  /// In en, this message translates to:
  /// **'Could not read saved data.'**
  String get errorCache;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error.'**
  String get errorUnknown;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfile;

  /// No description provided for @profileAllOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get profileAllOrders;

  /// No description provided for @profileOrderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No orders} =1{1 Order} other{{count} Orders}}'**
  String profileOrderCount(int count);

  /// No description provided for @profileSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get profileSectionGeneral;

  /// No description provided for @profileSectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileSectionOther;

  /// No description provided for @profileSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get profileSectionContact;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get profileActiveOrders;

  /// No description provided for @profileSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'My saved locations'**
  String get profileSavedLocations;

  /// No description provided for @profileOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get profileOrderHistory;

  /// No description provided for @profileAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get profileAnnouncements;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get profileDarkMode;

  /// No description provided for @profileAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get profileAboutApp;

  /// No description provided for @profileFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get profileFaq;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get profileTerms;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacy;

  /// No description provided for @profileWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get profileWhatsapp;

  /// No description provided for @profileInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get profileInstagram;

  /// No description provided for @profileTiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get profileTiktok;

  /// No description provided for @profileCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Call us with any question:'**
  String get profileCallTitle;

  /// No description provided for @profileCallAction.
  ///
  /// In en, this message translates to:
  /// **'Call operator'**
  String get profileCallAction;

  /// No description provided for @profileCallHours.
  ///
  /// In en, this message translates to:
  /// **'Calls are answered every day of the week, 09:00 - 19:00'**
  String get profileCallHours;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String profileVersion(String version);

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageTurkmen.
  ///
  /// In en, this message translates to:
  /// **'Türkmençe'**
  String get settingsLanguageTurkmen;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRussian;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get editProfileName;

  /// No description provided for @editProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get editProfileNameHint;

  /// No description provided for @editProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get editProfilePhone;

  /// No description provided for @editProfilePhoneNote.
  ///
  /// In en, this message translates to:
  /// **'Contact support to change your number'**
  String get editProfilePhoneNote;

  /// No description provided for @editProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editProfilePhoto;

  /// No description provided for @editProfilePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get editProfilePhotoCamera;

  /// No description provided for @editProfilePhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get editProfilePhotoGallery;

  /// No description provided for @editProfilePhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get editProfilePhotoRemove;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get editProfileSaved;

  /// No description provided for @editProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get editProfileNameRequired;

  /// No description provided for @editProfilePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the photo to change it'**
  String get editProfilePhotoHint;

  /// No description provided for @editProfileNameCounter.
  ///
  /// In en, this message translates to:
  /// **'{count}/40'**
  String editProfileNameCounter(int count);

  /// No description provided for @editProfileNothingChanged.
  ///
  /// In en, this message translates to:
  /// **'Nothing to save yet'**
  String get editProfileNothingChanged;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Everything from the big marketplaces, delivered to Turkmenistan.'**
  String get aboutTagline;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String legalUpdated(String date);

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I place an order?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Add what you want to the cart, open the Cart tab and tap Checkout. The total, including delivery, is shown before you confirm.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'How long does delivery take?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Items in local stock arrive in 1–3 days. Orders from partner marketplaces take 10–20 days, depending on the seller.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I track my order?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Open Profile → Active orders. Every step from confirmation to delivery is listed there.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel an order?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'Yes, while it is still marked Confirmed. Once it has shipped, call the operator and we will help.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'How do returns work?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Call the operator within 3 days of delivery. Unused items in their original packaging are accepted.'**
  String get faqA5;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsTitle;

  /// No description provided for @termsS1.
  ///
  /// In en, this message translates to:
  /// **'Using the app'**
  String get termsS1;

  /// No description provided for @termsB1.
  ///
  /// In en, this message translates to:
  /// **'By using Elyeter you accept these terms. If you do not agree with them, please stop using the app.'**
  String get termsB1;

  /// No description provided for @termsS2.
  ///
  /// In en, this message translates to:
  /// **'Orders and prices'**
  String get termsS2;

  /// No description provided for @termsB2.
  ///
  /// In en, this message translates to:
  /// **'Prices are shown in TMT and may change until an order is confirmed. Availability at partner marketplaces is outside our control.'**
  String get termsB2;

  /// No description provided for @termsS3.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get termsS3;

  /// No description provided for @termsB3.
  ///
  /// In en, this message translates to:
  /// **'Delivery times are estimates, not guarantees. Customs and seller delays can extend them.'**
  String get termsB3;

  /// No description provided for @termsS4.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get termsS4;

  /// No description provided for @termsB4.
  ///
  /// In en, this message translates to:
  /// **'Unused items in original packaging can be returned within 3 days of delivery. Made-to-order and personal-care items cannot.'**
  String get termsB4;

  /// No description provided for @termsS5.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get termsS5;

  /// No description provided for @termsB5.
  ///
  /// In en, this message translates to:
  /// **'Your phone number identifies your account. Keep it up to date — orders and delivery calls go to it.'**
  String get termsB5;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyTitle;

  /// No description provided for @privacyS1.
  ///
  /// In en, this message translates to:
  /// **'What we collect'**
  String get privacyS1;

  /// No description provided for @privacyB1.
  ///
  /// In en, this message translates to:
  /// **'Your name, phone number, delivery address and order history. Nothing else is required to use Elyeter.'**
  String get privacyB1;

  /// No description provided for @privacyS2.
  ///
  /// In en, this message translates to:
  /// **'Why we use it'**
  String get privacyS2;

  /// No description provided for @privacyB2.
  ///
  /// In en, this message translates to:
  /// **'To deliver your orders, keep you updated about them and answer you when you contact support.'**
  String get privacyB2;

  /// No description provided for @privacyS3.
  ///
  /// In en, this message translates to:
  /// **'Who we share it with'**
  String get privacyS3;

  /// No description provided for @privacyB3.
  ///
  /// In en, this message translates to:
  /// **'Only couriers and payment providers, and only the part they need to complete your order. We never sell your data.'**
  String get privacyB3;

  /// No description provided for @privacyS4.
  ///
  /// In en, this message translates to:
  /// **'How long we keep it'**
  String get privacyS4;

  /// No description provided for @privacyB4.
  ///
  /// In en, this message translates to:
  /// **'While your account exists, plus the period accounting rules require for completed orders.'**
  String get privacyB4;

  /// No description provided for @privacyS5.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get privacyS5;

  /// No description provided for @privacyB5.
  ///
  /// In en, this message translates to:
  /// **'Call the operator to get a copy of your data or ask for your account to be deleted.'**
  String get privacyB5;

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoryTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tk':
      return AppLocalizationsTk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
