/// Keys for local persistence. Keeping them here prevents typo-driven bugs.
abstract final class StorageKeys {
  // Secure
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';

  // Preferences
  static const themeMode = 'theme_mode';
  static const locale = 'locale';
  static const onboardingSeen = 'onboarding_seen';
  static const recentSearches = 'recent_searches';
}
