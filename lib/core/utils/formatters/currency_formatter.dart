import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';

/// Formats prices the way the designs show them: `280.00 TMT`.
abstract final class CurrencyFormatter {
  static String format(num amount, {String? locale, int decimals = 2}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: decimals,
    );
    return '${formatter.format(amount).trim()} ${AppConstants.currencySymbol}';
  }

  /// Compact form for badges and chips: `1.2K TMT`.
  static String compact(num amount, {String? locale}) =>
      '${NumberFormat.compact(locale: locale).format(amount)} '
      '${AppConstants.currencySymbol}';
}
