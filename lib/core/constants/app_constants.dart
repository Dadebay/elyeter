/// Non-visual app-wide constants. Keep environment values in [AppEnvironment].
abstract final class AppConstants {
  static const appName = 'Elyeter';

  /// Shown on the profile page. Keep in step with `version:` in pubspec.yaml.
  static const appVersion = '1.0.0';

  // Currency — the designs price everything in Turkmen manat.
  static const currencyCode = 'TMT';
  static const currencySymbol = 'TMT';

  // Paging — the API requires both `page` and `size`, and caps `size` at 100.
  static const pageSize = 20;
  static const maxPageSize = 100;

  /// Type-ahead suggestions per request.
  static const suggestLimit = 5;

  // Cart limits, as the pre-order endpoints enforce them.
  static const maxCartLines = 30;
  static const maxLineQuantity = 99;

  // Timings
  static const searchDebounce = Duration(milliseconds: 400);

  /// The suggest endpoint is cheap; the API docs ask for ~300 ms.
  static const suggestDebounce = Duration(milliseconds: 300);
  static const connectTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 30);

  /// The two pre-order endpoints call AliExpress live and are noticeably
  /// slower than the catalog ones.
  static const preOrderTimeout = Duration(seconds: 60);
}
