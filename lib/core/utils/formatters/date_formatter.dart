import 'package:intl/intl.dart';

/// Date/time formats used in order history and tracking screens.
abstract final class DateFormatter {
  // intl has no `tk` date symbols. Keep the app's Turkmen month names here
  // instead of passing that locale to DateFormat.
  static const _turkmenMonths = [
    'Ýan',
    'Few',
    'Mar',
    'Apr',
    'Maý',
    'Iýn',
    'Iýl',
    'Awg',
    'Sen',
    'Okt',
    'Noý',
    'Dek',
  ];

  static String _locale(String? locale) =>
      Intl.canonicalizedLocale(locale ?? Intl.getCurrentLocale());

  static bool _isTurkmen(String? locale) =>
      _locale(locale).split('_').first == 'tk';

  static String? _intlLocale(String? locale) => Intl.verifiedLocale(
    _locale(locale),
    DateFormat.localeExists,
    onFailure: (_) => 'en',
  );

  static String day(DateTime date, {String? locale, bool fullMonth = false}) {
    if (_isTurkmen(locale)) {
      return '${_turkmenMonths[date.month - 1]} ${date.day}, ${date.year}';
    }
    final format = fullMonth
        ? DateFormat.yMMMMd(_intlLocale(locale))
        : DateFormat.yMMMd(_intlLocale(locale));
    return format.format(date);
  }

  static String dayTime(
    DateTime date, {
    String? locale,
    bool fullMonth = false,
  }) =>
      '${day(date, locale: locale, fullMonth: fullMonth)} ${time(date, locale: locale)}';

  static String monthDayTime(
    DateTime date, {
    String? locale,
    bool shortMonth = false,
  }) {
    if (_isTurkmen(locale)) {
      return '${_turkmenMonths[date.month - 1]} ${date.day}, ${time(date, locale: locale)}';
    }
    final format = shortMonth
        ? DateFormat.MMMd(_intlLocale(locale))
        : DateFormat.MMMMd(_intlLocale(locale));
    return '${format.format(date)}, ${time(date, locale: locale)}';
  }

  static String time(DateTime date, {String? locale}) {
    if (_isTurkmen(locale)) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return DateFormat.Hm(_intlLocale(locale)).format(date);
  }
}
