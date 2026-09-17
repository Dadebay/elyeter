/// Non-visual app-wide constants. Keep environment values in [AppEnvironment].
abstract final class AppConstants {
  static const appName = 'Elyeter';

  /// Shown on the profile page. Keep in step with `version:` in pubspec.yaml.
  static const appVersion = '1.0.0';

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
