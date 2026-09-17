// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Elyeter';

  @override
  String get navHome => 'Главная';

  @override
  String get navCategory => 'Категории';

  @override
  String get navCart => 'Корзина';

  @override
  String get navFavorite => 'Избранное';

  @override
  String get favoriteTitle => 'Избранное';

  @override
  String get navProfile => 'Профиль';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get homeSearchHint => 'Поиск товара';

  @override
  String get locationTitle => 'Адрес доставки';

  @override
  String get locationSearchHint => 'Поиск района или улицы';

  @override
  String get locationEmpty => 'Совпадений не найдено';

  @override
  String get visualSearchTitle => 'Поиск по фото';

  @override
  String get visualSearchHint => 'Поместите товар в рамку для сканирования';

  @override
  String get visualSearchCamera => 'Сделать фото';

  @override
  String get visualSearchRetake => 'Переснять';

  @override
  String get visualSearchUse => 'Использовать';

  @override
  String get visualSearchGallery => 'Выбрать из галереи';

  @override
  String get visualSearchNoCamera => 'На этом устройстве нет камеры.';

  @override
  String get visualSearchDenied =>
      'Для поиска по фото нужен доступ к камере. Разрешите его в настройках.';

  @override
  String get visualSearchReady => 'Фото готово — поиск по фото скоро.';

  @override
  String commonOpenFailed(String target) {
    return 'Не удалось открыть $target';
  }

  @override
  String get orderActiveTitle => 'Активный заказ';

  @override
  String orderNumber(String number) {
    return 'Заказ № $number';
  }

  @override
  String get orderRepeat => 'Повторить заказ';

  @override
  String get orderQuestions => 'Вопросы';

  @override
  String get orderCancel => 'Отменить';

  @override
  String get orderProgress => 'Ход доставки';

  @override
  String get orderStepPlaced => 'Заказ оформлен';

  @override
  String get orderStepWarehouse => 'Поступил на склад в Китае';

  @override
  String get orderStepShipped => 'Отправлен в Туркменистан';

  @override
  String get orderStepArrived => 'Прибыл в Туркменистан';

  @override
  String get orderStepDelivered => 'Доставлен';

  @override
  String get orderProducts => 'Товары в доставке';

  @override
  String orderItemSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров на $total',
      few: '$count товара на $total',
      one: '$count товар на $total',
    );
    return '$_temp0';
  }

  @override
  String get orderPickupPoint => 'Пункт выдачи';

  @override
  String get orderRecipient => 'Получатель';

  @override
  String get orderTime => 'Время заказа';

  @override
  String get orderPayment => 'Способ оплаты';

  @override
  String get orderPaymentCard => 'Картой / Оплата картой';

  @override
  String get orderTotalTitle => 'Сумма заказа';

  @override
  String get orderProductsTotal => 'Сумма товаров';

  @override
  String get orderDeliveryLabel => 'Доставка';

  @override
  String get orderDeliveryFree => 'Бесплатно';

  @override
  String get orderCargo => 'Карго';

  @override
  String get orderDiscount => 'Скидка';

  @override
  String get orderDownloadCheck => 'Скачать чек';

  @override
  String get categoryFilterMaterial => 'Материал';

  @override
  String get categoryFilterColor => 'Цвет';

  @override
  String get categoryFilterBrand => 'Бренд';

  @override
  String get categorySearch => 'Поиск';

  @override
  String get categoryFilters => 'Фильтры';

  @override
  String get categorySortTitle => 'Сортировка';

  @override
  String get categorySortPopular => 'Популярные';

  @override
  String get categorySortPriceAsc => 'Цена: по возрастанию';

  @override
  String get categorySortPriceDesc => 'Цена: по убыванию';

  @override
  String get categorySortDiscount => 'Больше скидка';

  @override
  String get categoryApply => 'Применить';

  @override
  String get categoryReset => 'Сбросить';

  @override
  String get categoryNoResults => 'Ничего не найдено по этим фильтрам';

  @override
  String get categoryNoResultsHint => 'Попробуйте убрать один из них.';

  @override
  String categoryFacetSearch(String facet) {
    return 'Поиск: $facet';
  }

  @override
  String categorySelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get searchTitle => 'Поиск';

  @override
  String get commonSeeAll => 'Все';

  @override
  String get commonAddToCart => 'В корзину';

  @override
  String get commonAdded => 'Добавлено';

  @override
  String get cartDelete => 'Удалить';

  @override
  String get cartSelectAll => 'Выбрать все';

  @override
  String cartProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товара',
      one: '1 товар',
    );
    return '$_temp0';
  }

  @override
  String get commonCheckout => 'Оформить';

  @override
  String get commonTotal => 'Итого';

  @override
  String get commonEmpty => 'Здесь пока пусто';

  @override
  String productReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отзывов',
      one: '1 отзыв',
    );
    return '$_temp0';
  }

  @override
  String productOrderCount(int count) {
    return '$count заказов';
  }

  @override
  String productColor(String name) {
    return 'Цвет: $name';
  }

  @override
  String productSize(String size) {
    return 'Размер: $size';
  }

  @override
  String get productArticle => 'Артикул:';

  @override
  String get productCopy => 'Копировать';

  @override
  String get productCopied => 'Артикул скопирован';

  @override
  String get productShared => 'Ссылка на товар скопирована';

  @override
  String get productDescription => 'Описание';

  @override
  String get productReadMore => 'Читать далее';

  @override
  String get productReadLess => 'Свернуть';

  @override
  String get productCharacteristics => 'Характеристики';

  @override
  String get productAllCharacteristics => 'Все характеристики';

  @override
  String get productReviews => 'Отзывы';

  @override
  String productRatingCount(int count) {
    return '$count оценок';
  }

  @override
  String get productReadAllReviews => 'Читать все отзывы';

  @override
  String get orderActive => 'Активный заказ';

  @override
  String get orderCompleted => 'Заказ выполнен';

  @override
  String get orderCancelled => 'Заказ отменён';

  @override
  String get orderHistory => 'История заказов';

  @override
  String orderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров',
      few: '$count товара',
      one: '$count товар',
      zero: 'Нет товаров',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Профиль';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get errorServer => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorNetwork => 'Нет подключения к интернету.';

  @override
  String get errorTimeout => 'Запрос занял слишком много времени.';

  @override
  String get errorUnauthorized => 'Войдите, чтобы продолжить.';

  @override
  String get errorNotFound => 'Ничего не найдено.';

  @override
  String get errorCache => 'Не удалось прочитать сохранённые данные.';

  @override
  String get errorUnknown => 'Неизвестная ошибка.';

  @override
  String get profileEditProfile => 'Изменить профиль';

  @override
  String get profileAllOrders => 'Все заказы';

  @override
  String profileOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заказов',
      few: '$count заказа',
      one: '$count заказ',
      zero: 'Нет заказов',
    );
    return '$_temp0';
  }

  @override
  String get profileSectionGeneral => 'Основное';

  @override
  String get profileSectionOther => 'Другое';

  @override
  String get profileSectionContact => 'Связаться с нами';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileActiveOrders => 'Активные заказы';

  @override
  String get profileSavedLocations => 'Мои адреса';

  @override
  String get profileOrderHistory => 'История заказов';

  @override
  String get profileAnnouncements => 'Объявления';

  @override
  String get profileDarkMode => 'Тёмная тема';

  @override
  String get profileAboutApp => 'О приложении';

  @override
  String get profileFaq => 'Вопросы и ответы';

  @override
  String get profileTerms => 'Условия использования';

  @override
  String get profilePrivacy => 'Политика конфиденциальности';

  @override
  String get profileWhatsapp => 'WhatsApp';

  @override
  String get profileInstagram => 'Instagram';

  @override
  String get profileTiktok => 'TikTok';

  @override
  String get profileCallTitle => 'Звоните по любым вопросам:';

  @override
  String get profileCallAction => 'Позвонить';

  @override
  String get profileCallHours =>
      'Звонки принимаем каждый день недели, 09:00 - 19:00';

  @override
  String profileVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsLanguageEnglish => 'Английский';

  @override
  String get settingsLanguageTurkmen => 'Туркменский';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get editProfileTitle => 'Изменить профиль';

  @override
  String get editProfileName => 'Имя и фамилия';

  @override
  String get editProfileNameHint => 'Ваше имя';

  @override
  String get editProfilePhone => 'Номер телефона';

  @override
  String get editProfilePhoneNote =>
      'Чтобы изменить номер, обратитесь в поддержку';

  @override
  String get editProfilePhoto => 'Изменить фото';

  @override
  String get editProfilePhotoCamera => 'Сделать фото';

  @override
  String get editProfilePhotoGallery => 'Выбрать из галереи';

  @override
  String get editProfilePhotoRemove => 'Удалить фото';

  @override
  String get editProfileSaved => 'Профиль обновлён';

  @override
  String get editProfileNameRequired => 'Введите ваше имя';

  @override
  String get editProfilePhotoHint => 'Нажмите на фото, чтобы изменить';

  @override
  String editProfileNameCounter(int count) {
    return '$count/40';
  }

  @override
  String get editProfileNothingChanged => 'Пока нечего сохранять';

  @override
  String get aboutTagline =>
      'Всё с крупных маркетплейсов — с доставкой по Туркменистану.';

  @override
  String legalUpdated(String date) {
    return 'Обновлено: $date';
  }

  @override
  String get faqTitle => 'Вопросы и ответы';

  @override
  String get faqQ1 => 'Как оформить заказ?';

  @override
  String get faqA1 =>
      'Добавьте товары в корзину, откройте вкладку «Корзина» и нажмите «Оформить». Итог с доставкой показан до подтверждения.';

  @override
  String get faqQ2 => 'Сколько идёт доставка?';

  @override
  String get faqA2 =>
      'Товары со склада приходят за 1–3 дня. Заказы с партнёрских площадок — 10–20 дней, в зависимости от продавца.';

  @override
  String get faqQ3 => 'Как отследить заказ?';

  @override
  String get faqA3 =>
      'Откройте Профиль → Активные заказы. Там виден каждый этап от подтверждения до доставки.';

  @override
  String get faqQ4 => 'Можно ли отменить заказ?';

  @override
  String get faqA4 =>
      'Да, пока он в статусе «Подтверждён». После отправки позвоните оператору — поможем.';

  @override
  String get faqQ5 => 'Как вернуть товар?';

  @override
  String get faqA5 =>
      'Позвоните оператору в течение 3 дней после доставки. Принимаем неиспользованный товар в оригинальной упаковке.';

  @override
  String get termsTitle => 'Условия использования';

  @override
  String get termsS1 => 'Использование приложения';

  @override
  String get termsB1 =>
      'Пользуясь Elyeter, вы принимаете эти условия. Если вы не согласны, прекратите использование приложения.';

  @override
  String get termsS2 => 'Заказы и цены';

  @override
  String get termsB2 =>
      'Цены указаны в TMT и могут измениться до подтверждения заказа. Наличие на партнёрских площадках от нас не зависит.';

  @override
  String get termsS3 => 'Доставка';

  @override
  String get termsB3 =>
      'Сроки доставки — ориентир, а не гарантия. Таможня и задержки продавца могут их увеличить.';

  @override
  String get termsS4 => 'Возврат';

  @override
  String get termsB4 =>
      'Неиспользованный товар в оригинальной упаковке можно вернуть в течение 3 дней. Товары под заказ и средства личной гигиены возврату не подлежат.';

  @override
  String get termsS5 => 'Ваш аккаунт';

  @override
  String get termsB5 =>
      'Ваш номер телефона — идентификатор аккаунта. Держите его актуальным: заказы и звонки курьера идут на него.';

  @override
  String get privacyTitle => 'Политика конфиденциальности';

  @override
  String get privacyS1 => 'Какие данные мы собираем';

  @override
  String get privacyB1 =>
      'Имя, номер телефона, адрес доставки и историю заказов. Больше ничего для работы Elyeter не нужно.';

  @override
  String get privacyS2 => 'Зачем мы их используем';

  @override
  String get privacyB2 =>
      'Чтобы доставлять заказы, сообщать об их статусе и отвечать вам в поддержке.';

  @override
  String get privacyS3 => 'Кому мы их передаём';

  @override
  String get privacyB3 =>
      'Только курьерам и платёжным сервисам — и только то, что нужно для выполнения заказа. Мы не продаём ваши данные.';

  @override
  String get privacyS4 => 'Сколько мы их храним';

  @override
  String get privacyB4 =>
      'Пока существует ваш аккаунт, плюс срок, требуемый правилами учёта для завершённых заказов.';

  @override
  String get privacyS5 => 'Ваши права';

  @override
  String get privacyB5 =>
      'Позвоните оператору, чтобы получить копию данных или удалить аккаунт.';

  @override
  String get categoryTitle => 'Категории';
}
