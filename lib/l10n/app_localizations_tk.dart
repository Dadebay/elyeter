// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkmen (`tk`).
class AppLocalizationsTk extends AppLocalizations {
  AppLocalizationsTk([String locale = 'tk']) : super(locale);

  @override
  String get appName => 'Elyeter';

  @override
  String get navHome => 'Baş sahypa';

  @override
  String get navCategory => 'Bölümler';

  @override
  String get navCart => 'Sebet';

  @override
  String get navFavorite => 'Halanlarym';

  @override
  String get favoriteTitle => 'Halanlarym';

  @override
  String get navProfile => 'Profil';

  @override
  String get commonRetry => 'Gaýtadan synanyş';

  @override
  String get commonCancel => 'Ýatyr';

  @override
  String get commonClose => 'Ýap';

  @override
  String get commonSave => 'Ýatda sakla';

  @override
  String get commonSearch => 'Gözleg';

  @override
  String get homeSearchHint => 'Haryt gözle';

  @override
  String get locationTitle => 'Eltip bermek salgysy';

  @override
  String get locationSearchHint => 'Etrap ýa-da köçe gözle';

  @override
  String get locationEmpty => 'Salgy tapylmady';

  @override
  String get visualSearchTitle => 'Surat boýunça gözleg';

  @override
  String get visualSearchHint => 'Skanirlemek üçin harydy çarçuwa ýerleşdiriň';

  @override
  String get visualSearchCamera => 'Surat al';

  @override
  String get visualSearchRetake => 'Täzeden al';

  @override
  String get visualSearchUse => 'Suraty ulan';

  @override
  String get visualSearchGallery => 'Galereýadan saýla';

  @override
  String get visualSearchNoCamera => 'Bu enjamda kamera ýok.';

  @override
  String get visualSearchDenied =>
      'Surat boýunça gözlemek üçin Elyeter-e kamera rugsady gerek. Sazlamalardan rugsat beriň.';

  @override
  String get visualSearchReady =>
      'Surat taýýar — surat boýunça gözleg tiz wagtda.';

  @override
  String commonOpenFailed(String target) {
    return '$target açyp bolmady';
  }

  @override
  String get orderActiveTitle => 'Işjeň sargyt';

  @override
  String orderNumber(String number) {
    return 'Sargyt № $number';
  }

  @override
  String get orderRepeat => 'Sargydy gaýtala';

  @override
  String get orderQuestions => 'Soraglar';

  @override
  String get orderCancel => 'Ýatyr';

  @override
  String get orderProgress => 'Eltip berişiň barşy';

  @override
  String get orderStepPlaced => 'Sargyt kabul edildi';

  @override
  String get orderStepWarehouse => 'Hytaý ammaryna geldi';

  @override
  String get orderStepShipped => 'Türkmenistana ugradyldy';

  @override
  String get orderStepArrived => 'Türkmenistana geldi';

  @override
  String get orderStepDelivered => 'Eltildi';

  @override
  String get orderProducts => 'Eltilýän harytlar';

  @override
  String orderItemSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count haryt $total',
      one: '1 haryt $total',
    );
    return '$_temp0';
  }

  @override
  String get orderPickupPoint => 'Almak nokady';

  @override
  String get orderRecipient => 'Alyjy';

  @override
  String get orderTime => 'Sargyt wagty';

  @override
  String get orderPayment => 'Töleg usuly';

  @override
  String get orderPaymentCard => 'Kart bilen / Kart tölegi';

  @override
  String get orderTotalTitle => 'Sargydyň jemi';

  @override
  String get orderProductsTotal => 'Harytlaryň jemi';

  @override
  String get orderDeliveryLabel => 'Eltip berme';

  @override
  String get orderDeliveryFree => 'Mugt';

  @override
  String get orderCargo => 'Kargo';

  @override
  String get orderDiscount => 'Arzanladyş';

  @override
  String get orderDownloadCheck => 'Çeki ýükle';

  @override
  String get categoryFilterMaterial => 'Material';

  @override
  String get categoryFilterColor => 'Reňk';

  @override
  String get categoryFilterBrand => 'Marka';

  @override
  String get categorySearch => 'Gözleg';

  @override
  String get categoryFilters => 'Süzgüçler';

  @override
  String get categorySortTitle => 'Tertipleme';

  @override
  String get categorySortPopular => 'Meşhur';

  @override
  String get categorySortPriceAsc => 'Baha: arzandan gymmada';

  @override
  String get categorySortPriceDesc => 'Baha: gymmatdan arzana';

  @override
  String get categorySortDiscount => 'Iň uly arzanladyş';

  @override
  String get categoryApply => 'Ulan';

  @override
  String get categoryReset => 'Arassala';

  @override
  String get categoryNoResults => 'Bu süzgüçlere hiç zat gabat gelmedi';

  @override
  String get categoryNoResultsHint => 'Birini aýryp görüň.';

  @override
  String categoryFacetSearch(String facet) {
    return 'Gözleg: $facet';
  }

  @override
  String categorySelectedCount(int count) {
    return '$count saýlandy';
  }

  @override
  String get searchTitle => 'Gözleg';

  @override
  String get commonSeeAll => 'Hemmesi';

  @override
  String get commonAddToCart => 'Sebede goş';

  @override
  String get commonAdded => 'Goşuldy';

  @override
  String get cartDelete => 'Poz';

  @override
  String get cartSelectAll => 'Hemmesini saýla';

  @override
  String cartProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count haryt',
      one: '1 haryt',
    );
    return '$_temp0';
  }

  @override
  String get commonCheckout => 'Sargyt et';

  @override
  String get commonTotal => 'Jemi';

  @override
  String get commonEmpty => 'Bu ýerde entek hiç zat ýok';

  @override
  String productReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teswir',
      one: '1 teswir',
    );
    return '$_temp0';
  }

  @override
  String productOrderCount(int count) {
    return '$count sargyt';
  }

  @override
  String productColor(String name) {
    return 'Reňk: $name';
  }

  @override
  String productSize(String size) {
    return 'Ýüzük ölçegi: $size';
  }

  @override
  String get productArticle => 'Haryt kody:';

  @override
  String get productCopy => 'Göçür';

  @override
  String get productCopied => 'Haryt kody göçürildi';

  @override
  String get productShared => 'Haryt salgysy göçürildi';

  @override
  String get productDescription => 'Beýany';

  @override
  String get productReadMore => 'Dowamyny oka';

  @override
  String get productReadLess => 'Gysgalt';

  @override
  String get productCharacteristics => 'Häsiýetleri';

  @override
  String get productAllCharacteristics => 'Ähli häsiýetleri';

  @override
  String get productReviews => 'Teswirler';

  @override
  String productRatingCount(int count) {
    return '$count baha';
  }

  @override
  String get productReadAllReviews => 'Ähli teswirleri oka';

  @override
  String get orderActive => 'Işjeň sargyt';

  @override
  String get orderCompleted => 'Sargyt tamamlandy';

  @override
  String get orderCancelled => 'Sargyt ýatyryldy';

  @override
  String get orderHistory => 'Sargytlaryň taryhy';

  @override
  String orderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count haryt',
      one: '1 haryt',
      zero: 'Haryt ýok',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Açyk';

  @override
  String get settingsThemeDark => 'Garaňky';

  @override
  String get settingsThemeSystem => 'Ulgam';

  @override
  String get errorServer => 'Bir zat ýalňyş boldy. Gaýtadan synanyşyň.';

  @override
  String get errorNetwork => 'Internet birikmesi ýok.';

  @override
  String get errorTimeout => 'Haýyş juda uzaga çekdi.';

  @override
  String get errorUnauthorized => 'Dowam etmek üçin ulgama giriň.';

  @override
  String get errorNotFound => 'Gözlän zadyňyz tapylmady.';

  @override
  String get errorCache => 'Saklanan maglumat okalmady.';

  @override
  String get errorUnknown => 'Näbelli ýalňyşlyk.';

  @override
  String get profileEditProfile => 'Profili üýtget';

  @override
  String get profileAllOrders => 'Ähli sargytlar';

  @override
  String profileOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sargyt',
      one: '1 sargyt',
      zero: 'Sargyt ýok',
    );
    return '$_temp0';
  }

  @override
  String get profileSectionGeneral => 'Umumy';

  @override
  String get profileSectionOther => 'Beýleki';

  @override
  String get profileSectionContact => 'Biz bilen habarlaşyň';

  @override
  String get profileNotifications => 'Bildirişler';

  @override
  String get profileActiveOrders => 'Işjeň sargytlar';

  @override
  String get profileSavedLocations => 'Saklanan salgylarym';

  @override
  String get profileOrderHistory => 'Sargytlaryň taryhy';

  @override
  String get profileAnnouncements => 'Habarlar';

  @override
  String get profileDarkMode => 'Garaňky tema';

  @override
  String get profileAboutApp => 'Programma barada';

  @override
  String get profileFaq => 'Sowal-jogap';

  @override
  String get profileTerms => 'Ulanyş şertleri';

  @override
  String get profilePrivacy => 'Gizlinlik syýasaty';

  @override
  String get profileWhatsapp => 'WhatsApp';

  @override
  String get profileInstagram => 'Instagram';

  @override
  String get profileTiktok => 'TikTok';

  @override
  String get profileCallTitle => 'Ähli soraglar üçin jaň ediň:';

  @override
  String get profileCallAction => 'Operatora jaň et';

  @override
  String get profileCallHours =>
      'Jaňlara jogap beriljek wagtlary: Hepde içi her gün sagat 09:00 - 19:00 aralygy';

  @override
  String profileVersion(String version) {
    return 'Wersiýa $version';
  }

  @override
  String get settingsLanguageEnglish => 'Iňlisçe';

  @override
  String get settingsLanguageTurkmen => 'Türkmençe';

  @override
  String get settingsLanguageRussian => 'Rusça';

  @override
  String get editProfileTitle => 'Profili üýtget';

  @override
  String get editProfileName => 'Ady we familiýasy';

  @override
  String get editProfileNameHint => 'Adyňyz';

  @override
  String get editProfilePhone => 'Telefon belgisi';

  @override
  String get editProfilePhoneNote =>
      'Belgiňizi üýtgetmek üçin goldaw bilen habarlaşyň';

  @override
  String get editProfilePhoto => 'Suraty üýtget';

  @override
  String get editProfilePhotoCamera => 'Surat al';

  @override
  String get editProfilePhotoGallery => 'Galereýadan saýla';

  @override
  String get editProfilePhotoRemove => 'Suraty aýyr';

  @override
  String get editProfileSaved => 'Profil täzelendi';

  @override
  String get editProfileNameRequired => 'Adyňyzy ýazyň';

  @override
  String get editProfilePhotoHint => 'Üýtgetmek üçin surata basyň';

  @override
  String editProfileNameCounter(int count) {
    return '$count/40';
  }

  @override
  String get editProfileNothingChanged => 'Ýatda saklamaga zat ýok';

  @override
  String get aboutTagline =>
      'Uly bazarlardaky ähli zat, Türkmenistana eltilýär.';

  @override
  String legalUpdated(String date) {
    return 'Soňky täzelenme: $date';
  }

  @override
  String get faqTitle => 'Sowal-jogap';

  @override
  String get faqQ1 => 'Sargydy nädip edýärin?';

  @override
  String get faqA1 =>
      'Islän harydyňyzy sebede goşuň, Sebet bölümini açyň we Sargyt et düwmesine basyň. Tassyklamazdan öň eltip bermek bilen bilelikde jemi görkeziler.';

  @override
  String get faqQ2 => 'Eltip bermek näçe wagt alýar?';

  @override
  String get faqA2 =>
      'Ýerli ammardaky harytlar 1–3 günde gelýär. Hyzmatdaş bazarlardan sargytlar satyja görä 10–20 gün alýar.';

  @override
  String get faqQ3 => 'Sargydymy nädip yzarlaýaryn?';

  @override
  String get faqA3 =>
      'Profil → Işjeň sargytlar bölümini açyň. Tassyklanandan eltilýänçä ähli ädim şol ýerde.';

  @override
  String get faqQ4 => 'Sargydy ýatyryp bilerinmi?';

  @override
  String get faqA4 =>
      'Hawa, entek \"Tassyklandy\" ýagdaýyndaka. Ugradylandan soň operatora jaň ediň, kömek ederis.';

  @override
  String get faqQ5 => 'Haryt yzyna nädip gaýtarylýar?';

  @override
  String get faqA5 =>
      'Eltilenden soň 3 günüň içinde operatora jaň ediň. Ulanylmadyk we asyl gaby bilen harytlar kabul edilýär.';

  @override
  String get termsTitle => 'Ulanyş şertleri';

  @override
  String get termsS1 => 'Programmany ulanmak';

  @override
  String get termsB1 =>
      'Elyeter-i ulanmak bilen bu şertleri kabul edýärsiňiz. Razy bolmasaňyz, programmany ulanmagy bes ediň.';

  @override
  String get termsS2 => 'Sargytlar we bahalar';

  @override
  String get termsB2 =>
      'Bahalar TMT-de görkezilýär we sargyt tassyklanýança üýtgäp biler. Hyzmatdaş bazarlardaky haryt gory biziň gözegçiligimizde däl.';

  @override
  String get termsS3 => 'Eltip bermek';

  @override
  String get termsB3 =>
      'Eltip bermek möhletleri çaklamadyr, kepillik däldir. Gümrük we satyjy gijikdirmeleri möhleti uzaldyp biler.';

  @override
  String get termsS4 => 'Yzyna gaýtarmak';

  @override
  String get termsB4 =>
      'Ulanylmadyk we asyl gabyndaky harytlar eltilenden soň 3 günüň içinde yzyna gaýtarylyp bilner. Sargyt boýunça ýasalan we şahsy ideg harytlary gaýtarylmaýar.';

  @override
  String get termsS5 => 'Hasabyňyz';

  @override
  String get termsB5 =>
      'Telefon belgiňiz hasabyňyzy kesgitleýär. Ony täze ýagdaýda saklaň — sargytlar we eltip bermek jaňlary şol belgä barýar.';

  @override
  String get privacyTitle => 'Gizlinlik syýasaty';

  @override
  String get privacyS1 => 'Näme ýygnaýarys';

  @override
  String get privacyB1 =>
      'Adyňyz, telefon belgiňiz, eltip bermek salgyňyz we sargyt taryhyňyz. Elyeter-i ulanmak üçin başga zat gerek däl.';

  @override
  String get privacyS2 => 'Näme üçin ulanýarys';

  @override
  String get privacyB2 =>
      'Sargytlaryňyzy eltmek, olar barada habar bermek we goldawa ýüz tutanyňyzda jogap bermek üçin.';

  @override
  String get privacyS3 => 'Kim bilen paýlaşýarys';

  @override
  String get privacyB3 =>
      'Diňe kurýerler we töleg hyzmatlary bilen, diňe sargydyňyzy tamamlamak üçin gerek bölegi. Maglumatlaryňyzy hiç haçan satmaýarys.';

  @override
  String get privacyS4 => 'Näçe wagt saklaýarys';

  @override
  String get privacyB4 =>
      'Hasabyňyz bar wagty, şeýle hem tamamlanan sargytlar üçin hasabat kadalarynyň talap edýän möhletinde.';

  @override
  String get privacyS5 => 'Hukuklaryňyz';

  @override
  String get privacyB5 =>
      'Maglumatlaryňyzyň nusgasyny almak ýa-da hasabyňyzy pozdurmak üçin operatora jaň ediň.';

  @override
  String get categoryTitle => 'Bölümler';
}
