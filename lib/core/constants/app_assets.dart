/// Asset paths — never type an asset string inline.
abstract final class AppAssets {
  static const _icons = 'assets/icons';
  static const _images = 'assets/images';

  // Bottom navigation
  static const iconHome = '$_icons/home.svg';
  static const iconCategory = '$_icons/category.svg';
  static const iconCart = '$_icons/cart.svg';
  static const iconFavorite = '$_icons/heart.svg';
  static const iconProfile = '$_icons/people.svg';

  // Product card favourite toggle. Both are two-tone and carry their own
  // white body, so they are drawn as supplied — never tinted.
  static const iconFavoriteEmpty = '$_icons/favorite_empty.svg';
  static const iconFavoriteFull = '$_icons/favorite_full.svg';

  /// Ticket-shaped badge behind the discount percentage on a product card.
  /// The `-20%` baked into the file is drawn in the same green as its
  /// background, so only the shape shows — the number is drawn over it.
  static const iconDiscountBanner = '$_icons/discount_banner.svg';

  // Product detail's floating app bar.
  static const iconBack = '$_icons/back.svg';
  static const iconShare = '$_icons/share.svg';
  static const iconHeartLine = '$_icons/heart_line.svg';

  // Order detail. Each carries its own grey, so they are drawn as supplied.
  static const iconRepeatOrder = '$_icons/repeat_order.svg';
  static const iconBubbleQuestion = '$_icons/bubble_question.svg';
  static const iconCircleX = '$_icons/circle_x.svg';
  static const iconPencil = '$_icons/pencil.svg';
  static const iconUser = '$_icons/user.svg';
  static const iconCalendar = '$_icons/calendar.svg';
  static const iconWallet = '$_icons/wallet.svg';
  static const iconReceipt = '$_icons/receipt.svg';

  // Search bar
  static const iconSearch = '$_icons/search.svg';
  static const iconCamera = '$_icons/camera.svg';

  // Home
  static const logoWhite = '$_images/logo_white.svg';
  static const logoYellow = '$_images/logo_yellow.svg';
  static const homeBackground = '$_images/background.png';
  static const iconMapPin = '$_icons/map_pin.svg';

  // Partner marketplaces, in the order the design shows them.
  static const _magazynes = '$_images/magazynes';
  static const marketAliexpress = '$_magazynes/1.svg';
  static const marketAlibaba = '$_magazynes/2.svg';
  static const marketTaobao = '$_magazynes/3.svg';
  static const market1688 = '$_magazynes/4.svg';

  static const iconCubic = '$_icons/cubic.svg';

  // Profile rows
  static const iconBell = '$_icons/bell.svg';
  static const iconDocumentCheck = '$_icons/document_check.svg';
  static const iconPinLocation = '$_icons/pin_location.svg';
  static const iconClock = '$_icons/clock.svg';
  static const iconNews = '$_icons/news.svg';
  static const iconGlobe = '$_icons/globe.svg';
  static const iconMoon = '$_icons/moon.svg';
  static const iconPhone = '$_icons/phone.svg';
  static const iconQuestion = '$_icons/question_bubble.svg';
  static const iconLock = '$_icons/lock.svg';
  static const iconInstagram = '$_icons/instagram.svg';
  static const iconTiktok = '$_icons/tiktok.svg';
  static const iconWhatsapp = '$_icons/whatsapp.svg';

  // Category tile artwork, one file per category. Named exactly as supplied
  // — the casing and the spelling of `jevelery.svg` are the files' own.
  static const _category = '$_images/category';
  static const categoryMakeUp = '$_category/make_up.svg';
  static const categoryElectronics = '$_category/electronics.svg';
  static const categoryAutomotive = '$_category/Automotive.svg';
  static const categoryStationery = '$_category/Stationery.svg';
  static const categoryJewellery = '$_category/jevelery.svg';

  /// Generic tile art, for a category with no picture of its own.
  static const categoryImage = '$_images/category_image.png';

  // Promo banners — full artwork, headline included.
  static const _banners = '$_images/banners';
  static const bannerTech = '$_banners/1.png';
  static const bannerLook = '$_banners/2.png';
  static const bannerStyle = '$_banners/3.png';

  // Brand logos, in the order the strip shows them.
  static const _logos = '$_images/logos';
  static const brandLoroPiana = '$_logos/1.png';
  static const brandJordan = '$_logos/2.png';
  static const brandLacoste = '$_logos/3.png';
  static const brandTissot = '$_logos/4.png';
  static const brandClothingStore = '$_logos/5.png';

  // Product photography — cut-outs on a transparent background.
  static const _products = '$_images/products';
  static const productLoafers = '$_products/1.png';
  static const productTshirt = '$_products/2.png';
  static const productWatch = '$_products/3.png';
  static const productSuitcase = '$_products/4.png';
  static const productBag = '$_products/5.png';
  static const productPerfume = '$_products/6.png';

  /// The electronics catalogue, `p1`-`p12` as supplied.
  static const productAppleTv = '$_products/p1.png';
  static const productInstax = '$_products/p2.png';
  static const productPhoneCase = '$_products/p3.png';
  static const productXiaomi = '$_products/p4.png';
  static const productCable = '$_products/p5.png';
  static const productBeats = '$_products/p6.png';
  static const productIphoneOrange = '$_products/p7.png';
  static const productIphoneBlue = '$_products/p8.png';
  static const productIphoneGreen = '$_products/p9.png';
  static const productIphoneLightBlue = '$_products/p10.png';
  static const productIphonePink = '$_products/p11.png';
  static const productIphoneWhite = '$_products/p12.png';

  // Subcategory tiles, `s1`-`s8` as supplied.
  static const _subcategory = '$_images/subcategory';
  static const subGamingMice = '$_subcategory/s1.png';
  static const subEarbuds = '$_subcategory/s2.png';
  static const subControllers = '$_subcategory/s3.png';
  static const subSmartwatches = '$_subcategory/s4.png';
  static const subSmartphones = '$_subcategory/s5.png';
  static const subPhoneCases = '$_subcategory/s6.png';
  static const subCameras = '$_subcategory/s7.png';
  static const subPs5Games = '$_subcategory/s8.png';
  static const productRing = '$_products/c1.png';
  static const productPhone = '$_products/c2.png';
  static const productSneakers = '$_products/c3.png';
  static const productSmartWatch = '$_products/c4.png';
}
