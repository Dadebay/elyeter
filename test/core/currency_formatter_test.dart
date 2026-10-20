import 'package:elyeter/core/utils/formatters/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  for (final locale in ['tk', 'tk_TM', 'tk-TM']) {
    test('prices support $locale explicitly and as the default locale', () {
      expect(CurrencyFormatter.format(1234.5, locale: locale), '1,234.50 TMT');
      expect(
        CurrencyFormatter.amount(1234.5, locale: locale, decimals: 2),
        '1\u2009234.50',
      );
      expect(CurrencyFormatter.compact(1200, locale: locale), '1.2K TMT');

      Intl.withLocale(locale, () {
        expect(CurrencyFormatter.format(1234.5), '1,234.50 TMT');
        expect(CurrencyFormatter.amount(1234), '1\u2009234');
        expect(CurrencyFormatter.compact(1200), '1.2K TMT');
      });
    });
  }

  test('Turkmen prices preserve zero, discounts and fractional amounts', () {
    Intl.withLocale('tk', () {
      expect(CurrencyFormatter.format(0), '0.00 TMT');
      expect(CurrencyFormatter.amount(-1234.5, decimals: 2), '-1\u2009234.50');
      expect(
        CurrencyFormatter.amount(1234567.89, decimals: 2),
        '1\u2009234\u2009567.89',
      );
    });
  });

  test('English and Russian currency and compact formats are preserved', () {
    for (final locale in ['en', 'en_US', 'ru', 'ru_RU']) {
      expect(
        CurrencyFormatter.format(1234.5, locale: locale),
        '${NumberFormat.currency(locale: locale, symbol: '', decimalDigits: 2).format(1234.5).trim()} TMT',
      );
      expect(
        CurrencyFormatter.compact(1200, locale: locale),
        '${NumberFormat.compact(locale: locale).format(1200)} TMT',
      );
    }
  });

  test('amount spacing preserves the decimal separator', () {
    expect(
      CurrencyFormatter.amount(1234.5, locale: 'en', decimals: 2),
      '1\u2009234.50',
    );
    for (final locale in ['ru', 'ru_RU', 'ru-RU']) {
      expect(
        CurrencyFormatter.amount(1234.5, locale: locale, decimals: 2),
        '1\u2009234,50',
      );
    }
  });
}
