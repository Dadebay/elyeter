import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../constants/app_environment.dart';
import '../error/exceptions.dart';

/// Dio wrapper that returns decoded JSON and throws [AppException]s.
/// Data sources depend on this, never on Dio directly.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  static Dio createDio({List<Interceptor> interceptors = const []}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: const {'Accept': 'application/json'},
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.addAll(interceptors);
    return dio;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> put(String path, {Object? data, CancelToken? cancelToken}) =>
      _request(
        () => _dio.put<dynamic>(path, data: data, cancelToken: cancelToken),
      );

  Future<dynamic> patch(String path, {Object? data, CancelToken? cancelToken}) =>
      _request(
        () => _dio.patch<dynamic>(path, data: data, cancelToken: cancelToken),
      );

  Future<dynamic> delete(
    String path, {
    Object? data,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.delete<dynamic>(path, data: data, cancelToken: cancelToken),
  );

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final serverMessage = _extractMessage(e.response?.data);

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => switch (status) {
        401 || 403 => UnauthorizedException(serverMessage ?? 'Unauthorized'),
        404 => NotFoundException(serverMessage ?? 'Not found'),
        _ => ServerException(
          serverMessage ?? 'Server error',
          statusCode: status,
        ),
      },
      _ => ServerException(
        serverMessage ?? e.message ?? 'Unexpected error',
        statusCode: status,
      ),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (data is Map && data['error'] is String) return data['error'] as String;
    return null;
  }
}
