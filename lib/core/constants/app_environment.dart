/// Build-time configuration. Pass values with `--dart-define`:
///
/// ```sh
/// flutter run --dart-define=FLAVOR=dev --dart-define=API_BASE_URL=https://api.dev.elyeter.com
/// ```
enum Flavor { dev, staging, prod }

abstract final class AppEnvironment {
  static const _flavorName = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static Flavor get flavor => switch (_flavorName) {
    'prod' => Flavor.prod,
    'staging' => Flavor.staging,
    _ => Flavor.dev,
  };

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static bool get isProd => flavor == Flavor.prod;
  static bool get enableLogging => !isProd;
}
