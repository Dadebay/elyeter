import 'package:elyeter/app/cubit/locale_cubit.dart';
import 'package:elyeter/app/router/app_router.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/core/storage/local_storage.dart';
import 'package:elyeter/core/storage/storage_keys.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/onboarding/presentation/view/onboarding_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _MemoryStorage implements Storage {
  final values = <String, dynamic>{};
  @override
  dynamic read(String key) => values[key];
  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<void> clear() async => values.clear();
  @override
  Future<void> close() async {}
}

class _MemoryLocalStorage implements LocalStorage {
  final values = <String, dynamic>{};
  @override
  bool? getBool(String key) => values[key] as bool?;
  @override
  Future<void> setBool(String key, {required bool value}) async {
    values[key] = value;
  }

  @override
  String? getString(String key) => values[key] as String?;
  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  List<String>? getStringList(String key) => values[key] as List<String>?;
  @override
  Future<void> setStringList(String key, List<String> value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());
  tearDown(() async => getIt.reset());

  test('first launch starts at onboarding', () {
    getIt.registerSingleton<LocalStorage>(_MemoryLocalStorage());
    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      '/onboarding',
    );
  });

  testWidgets('language changes and Start enters the shop once', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final storage = _MemoryLocalStorage();
    getIt.registerSingleton<LocalStorage>(storage);
    final locale = LocaleCubit()..setLanguageCode('en');
    addTearDown(locale.close);
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const Scaffold(body: Text('Shop home')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<LocaleCubit>.value(
        value: locale,
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, selectedLocale) => MaterialApp.router(
            theme: AppTheme.light,
            locale: selectedLocale,
            routerConfig: router,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              ...FallbackLocalizations.delegates,
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome!'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('onboarding-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkmençe').last);
    await tester.pumpAndSettle();
    expect(find.text('Hoş geldiňiz!'), findsOneWidget);
    expect(find.text('Başlamak'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-start')));
    await tester.pumpAndSettle();
    expect(storage.getBool(StorageKeys.onboardingSeen), isTrue);
    expect(find.text('Shop home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
