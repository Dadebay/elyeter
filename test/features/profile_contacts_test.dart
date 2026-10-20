import 'package:dio/dio.dart';
import 'package:elyeter/app/cubit/locale_cubit.dart';
import 'package:elyeter/app/cubit/theme_cubit.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:elyeter/features/profile/presentation/view/profile_page.dart';
import 'package:elyeter/features/profile/presentation/widgets/support_call_card.dart';
import 'package:elyeter/features/profile/presentation/widgets/settings_tile.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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

class _IdleAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ContactsClient extends ApiClient {
  _ContactsClient(this.data, this.pages) : super(Dio());
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> pages;
  final requests = <String>[];

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    requests.add(path);
    if (path == '/contacts') return data;
    if (path == '/pages') return pages;
    throw StateError('Unexpected request: $path');
  }
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());
  tearDown(() async => getIt.reset());

  Future<LocaleCubit> pumpProfile(
    WidgetTester tester,
    Map<String, dynamic> data, {
    bool dark = false,
    List<Map<String, dynamic>> pages = const [],
  }) async {
    final client = _ContactsClient(data, pages);
    getIt.registerSingleton<ShopApi>(ShopApi(client));
    final auth = AuthCubit(_IdleAuthRepository());
    final theme = ThemeCubit();
    final locale = LocaleCubit()..setLanguageCode('en');
    final profile = ProfileCubit();
    addTearDown(auth.close);
    addTearDown(theme.close);
    addTearDown(locale.close);
    addTearDown(profile.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<ThemeCubit>.value(value: theme),
          BlocProvider<LocaleCubit>.value(value: locale),
          BlocProvider<ProfileCubit>.value(value: profile),
        ],
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, selectedLocale) => MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            locale: selectedLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              ...FallbackLocalizations.delegates,
            ],
            home: const ProfilePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(client.requests, contains('/contacts'));
    return locale;
  }

  testWidgets('Other labels follow locale even with Turkmen server titles', (
    tester,
  ) async {
    final locale = await pumpProfile(
      tester,
      {},
      pages: [
        {'slug': 'about', 'title': 'Programma barada'},
        {'slug': 'faq', 'title': 'FAQ'},
        {'slug': 'terms', 'title': 'Ulanyş şertleri'},
        {'slug': 'privacy', 'title': 'Gizlinlik syýasaty'},
      ],
    );

    const titles = {
      'en': ['About the app', 'FAQ', 'Terms of use', 'Privacy policy'],
      'ru': [
        'О приложении',
        'Вопросы и ответы',
        'Условия использования',
        'Политика конфиденциальности',
      ],
      'tk': [
        'Programma barada',
        'Sowal-jogap',
        'Ulanyş şertleri',
        'Gizlinlik syýasaty',
      ],
    };
    for (final language in ['en', 'ru', 'tk', 'en']) {
      locale.setLanguageCode(language);
      await tester.pumpAndSettle();
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pump();
      for (final title in titles[language]!) {
        await tester.scrollUntilVisible(
          find.text(title),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(title), findsOneWidget);
      }
    }
  });

  testWidgets('all null contacts hide the section and call cards', (
    tester,
  ) async {
    await pumpProfile(tester, {
      'phone_primary': null,
      'phone_secondary': null,
      'whatsapp_url': null,
      'telegram_url': null,
      'instagram_url': null,
      'tiktok_url': null,
      'imo_url': null,
    });

    expect(find.text('Contact Us'), findsNothing);
    expect(find.byType(SupportCallCard), findsNothing);
  });

  testWidgets('Other links remain visible when the pages list is empty', (
    tester,
  ) async {
    await pumpProfile(tester, {});

    for (final title in [
      'About the app',
      'FAQ',
      'Terms of use',
      'Privacy policy',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('only populated contact entries are shown', (tester) async {
    await pumpProfile(tester, {
      'phone_primary': null,
      'phone_secondary': '+99365000001',
      'whatsapp_url': 'https://wa.me/99365000002',
      'telegram_url': null,
      'instagram_url': null,
      'tiktok_url': null,
      'imo_url': null,
    });

    await tester.scrollUntilVisible(
      find.text('+99365000001'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(SupportCallCard), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Telegram'), findsNothing);
    expect(find.text('Instagram'), findsNothing);
  });

  testWidgets('dark profile keeps its title fixed while scrolling settings', (
    tester,
  ) async {
    await pumpProfile(tester, {'phone_primary': '+99365000001'}, dark: true);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Profile').hitTestable(), findsOneWidget);
    final titlePosition = tester.getTopLeft(find.text('Profile'));
    expect(
      find.ancestor(of: find.text('Profile'), matching: find.byType(AppBar)),
      findsOneWidget,
    );
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
      AppTheme.dark.scaffoldBackgroundColor,
    );
    expect(find.text('My saved locations'), findsNothing);
    expect(find.text('Active orders'), findsNothing);
    expect(find.text('Order history'), findsNothing);
    expect(find.text('Announcements'), findsNothing);
    final notifications = find.ancestor(
      of: find.text('Notifications'),
      matching: find.byType(SettingsTile),
    );
    expect(
      tester
          .widget<Ink>(
            find.descendant(of: notifications, matching: find.byType(Ink)),
          )
          .decoration,
      isA<BoxDecoration>().having(
        (decoration) => decoration.color,
        'color',
        AppTheme.dark.colorScheme.surface,
      ),
    );

    await tester.scrollUntilVisible(
      find.text('+99365000001'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final callButton = tester.widget<FilledButton>(
      find.descendant(
        of: find.byType(SupportCallCard),
        matching: find.byType(FilledButton),
      ),
    );
    expect(find.text('Profile').hitTestable(), findsOneWidget);
    expect(tester.getTopLeft(find.text('Profile')), titlePosition);
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).scrolledUnderElevation,
      0,
    );
    expect(
      callButton.style?.backgroundColor?.resolve({}),
      AppTheme.dark.colorScheme.surface,
    );
  });
}
