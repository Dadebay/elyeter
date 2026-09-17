/// Non-visual app-wide constants. Keep environment values in [AppEnvironment].
abstract final class AppConstants {
  static const appName = 'Elyeter';

  // Currency — the designs price everything in Turkmen manat.
  static const currencyCode = 'TMT';
  static const currencySymbol = 'TMT';

  // Paging
  static const pageSize = 20;

  // Timings
  static const searchDebounce = Duration(milliseconds: 400);
  static const connectTimeout = Duration(seconds: 20);
  static const receiveTimeout = Duration(seconds: 30);
}
