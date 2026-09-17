import 'package:logger/logger.dart';

import '../constants/app_environment.dart';

/// App-wide logger. Silent in production builds.
abstract final class AppLogger {
  static final Logger _logger = Logger(
    filter: _EnvFilter(),
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 6),
  );

  static void d(Object? message) => _logger.d(message);
  static void i(Object? message) => _logger.i(message);
  static void w(Object? message) => _logger.w(message);
  static void e(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}

class _EnvFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => AppEnvironment.enableLogging;
}
