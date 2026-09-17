import 'package:intl/intl.dart';

/// Date/time formats used in order history and tracking screens.
abstract final class DateFormatter {
  static String day(DateTime date, {String? locale}) =>
      DateFormat.yMMMd(locale).format(date);

  static String dayTime(DateTime date, {String? locale}) =>
      DateFormat.yMMMd(locale).add_Hm().format(date);

  static String time(DateTime date, {String? locale}) =>
      DateFormat.Hm(locale).format(date);
}
