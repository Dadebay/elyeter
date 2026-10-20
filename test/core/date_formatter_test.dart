import 'package:elyeter/core/utils/formatters/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  final date = DateTime(2026, 10, 20, 0, 33);

  test('Turkmen dates do not need intl locale data', () {
    for (final locale in ['tk', 'tk_TM', 'tk-TM']) {
      expect(DateFormatter.day(date, locale: locale), 'Okt 20, 2026');
      expect(DateFormatter.dayTime(date, locale: locale), 'Okt 20, 2026 00:33');
      expect(DateFormatter.monthDayTime(date, locale: locale), 'Okt 20, 00:33');
      expect(DateFormatter.time(date, locale: locale), '00:33');
    }
    Intl.withLocale('tk', () {
      expect(DateFormatter.dayTime(date), 'Okt 20, 2026 00:33');
    });
  });

  test('English and Russian dates keep their intl formatting', () async {
    await initializeDateFormatting();
    for (final locale in ['en', 'en_US', 'en_GB', 'ru', 'ru_RU']) {
      expect(
        DateFormatter.day(date, locale: locale),
        DateFormat.yMMMd(locale).format(date),
      );
      expect(
        DateFormatter.dayTime(date, locale: locale),
        DateFormat.yMMMd(locale).add_Hm().format(date),
      );
      expect(
        DateFormatter.dayTime(date, locale: locale, fullMonth: true),
        DateFormat.yMMMMd(locale).add_Hm().format(date),
      );
      expect(
        DateFormatter.monthDayTime(date, locale: locale),
        '${DateFormat.MMMMd(locale).format(date)}, 00:33',
      );
      expect(
        DateFormatter.monthDayTime(date, locale: locale, shortMonth: true),
        '${DateFormat.MMMd(locale).format(date)}, 00:33',
      );
    }
  });

  test('English and Russian dates use local day and month order', () async {
    await initializeDateFormatting();
    for (final locale in ['en', 'en-US']) {
      expect(
        DateFormatter.monthDayTime(date, locale: locale),
        'October 20, 00:33',
      );
    }
    for (final locale in ['ru', 'ru-RU']) {
      expect(
        DateFormatter.monthDayTime(date, locale: locale),
        '20 октября, 00:33',
      );
      Intl.withLocale(locale, () {
        expect(DateFormatter.monthDayTime(date), '20 октября, 00:33');
      });
    }
  });
}
