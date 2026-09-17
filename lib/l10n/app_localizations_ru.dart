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
  String get navProfile => 'Профиль';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get commonSeeAll => 'Все';

  @override
  String get commonAddToCart => 'В корзину';

  @override
  String get commonCheckout => 'Оформить';

  @override
  String get commonTotal => 'Итого';

  @override
  String get commonEmpty => 'Здесь пока пусто';

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
}
