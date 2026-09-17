import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/cubit/locale_cubit.dart';
import '../../app/cubit/theme_cubit.dart';
import '../constants/app_environment.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/network_info.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

/// Service locator. One `getIt` for the whole app.
final getIt = GetIt.instance;

/// Registration order: external packages -> core services -> feature layers.
///
/// Feature registrations live in their own `_registerX()` function below so
/// each feature stays self-contained and easy to move when the codebase
/// migrates to MVVM.
Future<void> configureDependencies() async {
  await _registerExternal();
  _registerCore();
  _registerGlobalCubits();
  _registerFeatures();
}

Future<void> _registerExternal() async {
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        // v11 encrypts with AES-GCM by default; only the iOS class needs setting.
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      ),
    )
    ..registerLazySingleton<Connectivity>(Connectivity.new);
}

void _registerCore() {
  getIt
    ..registerLazySingleton<LocalStorage>(
      () => LocalStorageImpl(getIt<SharedPreferences>()),
    )
    ..registerLazySingleton<SecureStorage>(
      () => SecureStorageImpl(getIt<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt<Connectivity>()),
    )
    ..registerLazySingleton<Dio>(
      () => ApiClient.createDio(
        interceptors: [
          AuthInterceptor(getIt<SecureStorage>()),
          if (AppEnvironment.enableLogging)
            PrettyDioLogger(requestBody: true, compact: true),
        ],
      ),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
}

void _registerGlobalCubits() {
  getIt
    ..registerLazySingleton<ThemeCubit>(ThemeCubit.new)
    ..registerLazySingleton<LocaleCubit>(LocaleCubit.new);
}

void _registerFeatures() {
  // Each feature registers its data source -> repository -> bloc chain here.
  //
  // Template:
  //   getIt
  //     ..registerLazySingleton<HomeRemoteDataSource>(
  //       () => HomeRemoteDataSourceImpl(getIt<ApiClient>()),
  //     )
  //     ..registerLazySingleton<HomeRepository>(
  //       () => HomeRepositoryImpl(getIt<HomeRemoteDataSource>()),
  //     )
  //     ..registerFactory<HomeBloc>(() => HomeBloc(getIt<HomeRepository>()));
}
