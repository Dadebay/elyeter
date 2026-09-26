import 'package:dio/dio.dart';

import '../../error/failure.dart';
import '../../storage/secure_storage.dart';

/// Attaches the bearer token and clears the session when the backend says it
/// is no longer valid.
///
/// There is no refresh token to try: a 401 means the 30-day access token is
/// gone and the SMS login has to run again. A 403 `user-blocked` can arrive
/// mid-session on an otherwise valid token, and is equally terminal.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, {this.onUnauthorized});

  final SecureStorage _storage;

  /// Called after the token is cleared, so the app can send the customer
  /// back to the login screen.
  final void Function(Failure failure)? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final code = data is Map && data['code'] is String
        ? data['code'] as String
        : null;
    final blocked = status == 403 && code == ApiCodes.userBlocked;

    if (status == 401 || blocked) {
      await _storage.clear();
      onUnauthorized?.call(
        blocked
            ? const ApiFailure(code: ApiCodes.userBlocked, statusCode: 403)
            : const UnauthorizedFailure(),
      );
    }
    handler.next(err);
  }
}
