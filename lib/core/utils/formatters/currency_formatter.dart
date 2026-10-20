import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';

/// Formats prices the way the designs show them: `280.00 TMT`.
abstract final class CurrencyFormatter {
  // intl has no Turkmen number symbols. Match the English numeric fallback
  // used by receipts and product sharing, including when tk is the default.
  static String? _intlLocale(String? locale) => Intl.verifiedLocale(
    Intl.canonicalizedLocale(locale ?? Intl.getCurrentLocale()),
    NumberFormat.localeExists,
    onFailure: (_) => 'en',
  );

  static String format(num amount, {String? locale, int decimals = 2}) {
    final formatter = NumberFormat.currency(
      locale: _intlLocale(locale),
      symbol: '',
      decimalDigits: decimals,
    );
    return '${formatter.format(amount).trim()} ${AppConstants.currencySymbol}';
  }

  /// Just the number, for layouts that style the currency separately:
  /// `7 526`.
  static String amount(num value, {String? locale, int decimals = 0}) {
    final formatter = NumberFormat.currency(
      locale: _intlLocale(locale),
      symbol: '',
      decimalDigits: decimals,
    );
    return formatter
        .format(value)
        .trim()
        .replaceAll(formatter.symbols.GROUP_SEP, '\u2009');
  }

  /// Compact form for badges and chips: `1.2K TMT`.
  static String compact(num amount, {String? locale}) =>
      '${NumberFormat.compact(locale: _intlLocale(locale)).format(amount)} '
      '${AppConstants.currencySymbol}';
}
