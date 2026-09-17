// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Elyeter';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navCategory => 'Kategori';

  @override
  String get navCart => 'Sepet';

  @override
  String get navFavorite => 'Favoriler';

  @override
  String get navProfile => 'Profil';

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonSearch => 'Ara';

  @override
  String get commonSeeAll => 'Tümünü gör';

  @override
  String get commonAddToCart => 'Sepete ekle';

  @override
  String get commonCheckout => 'Ödemeye geç';

  @override
  String get commonTotal => 'Toplam';

  @override
  String get commonEmpty => 'Burada henüz bir şey yok';

  @override
  String get orderActive => 'Aktif sipariş';

  @override
  String get orderCompleted => 'Sipariş tamamlandı';

  @override
  String get orderCancelled => 'Sipariş iptal edildi';

  @override
  String get orderHistory => 'Sipariş geçmişi';

  @override
  String orderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ürün',
      one: '1 ürün',
      zero: 'Ürün yok',
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
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get errorServer => 'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

  @override
  String get errorNetwork => 'İnternet bağlantısı yok.';

  @override
  String get errorTimeout => 'İstek çok uzun sürdü.';

  @override
  String get errorUnauthorized => 'Devam etmek için giriş yapın.';

  @override
  String get errorNotFound => 'Aradığınız şey bulunamadı.';

  @override
  String get errorCache => 'Kayıtlı veri okunamadı.';

  @override
  String get errorUnknown => 'Beklenmeyen hata.';
}
