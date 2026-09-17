import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';

/// Attaches the bearer token and clears the session on a 401.
///
/// Silent refresh is intentionally left as a TODO for the MVP — wire it here
/// once the refresh endpoint contract is final, so no other layer changes.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, {this.onUnauthorized});

  final SecureStorage _storage;
  final void Function()? onUnauthorized;

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
    if (err.response?.statusCode == 401) {
      await _storage.clear();
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
