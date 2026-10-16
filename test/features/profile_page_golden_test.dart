@Tags(['golden'])
library;

import 'package:dio/dio.dart';
import 'package:elyeter/app/cubit/locale_cubit.dart';
import 'package:elyeter/app/cubit/theme_cubit.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:elyeter/features/profile/presentation/view/profile_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Keeps the hydrated cubits happy without touching the disk.
class _MemoryStorage implements Storage {
  final Map<String, dynamic> _values = {};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}
}

class _IdleAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProfileClient extends ApiClient {
  _ProfileClient() : super(Dio());

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async => switch (path) {
    '/contacts' => {
      'phone_primary': '+993 65 000000',
      'instagram_url': 'https://example.com/instagram',
      'tiktok_url': 'https://example.com/tiktok',
      'whatsapp_url': 'https://example.com/whatsapp',
    },
    '/pages' => <dynamic>[],
    _ => throw StateError('Unexpected request: $path'),
  };
}

Future<void> _loadFonts() async {
  // SVG icons decode asynchronously; the caller pumps inside runAsync.
  final loader = FontLoader('InterDisplay')
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-Bold.ttf'));
  await loader.load();

  final wordmark = FontLoader('Qurova')
    ..addFont(rootBundle.load('assets/fonts/QurovaDEMO-Medium.otf'));
  await wordmark.load();
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());
  tearDown(() async => getIt.reset());

  testWidgets('guest profile page golden', (tester) async {
    await _loadFonts();
    getIt.registerSingleton<ShopApi>(ShopApi(_ProfileClient()));
    final auth = AuthCubit(_IdleAuthRepository());
    final theme = ThemeCubit();
    final locale = LocaleCubit();
    final profile = ProfileCubit();
    addTearDown(auth.close);
    addTearDown(theme.close);
    addTearDown(locale.close);
    addTearDown(profile.close);
    tester.view
      ..physicalSize = const Size(1170, 3600)
      ..devicePixelRatio = 3
      ..viewPadding = const FakeViewPadding(top: 141, bottom: 102);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<ThemeCubit>.value(value: theme),
          BlocProvider<LocaleCubit>.value(value: locale),
          BlocProvider<ProfileCubit>.value(value: profile),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfilePage(),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ProfilePage),
      matchesGoldenFile('goldens/profile_page.png'),
    );
  });
}
