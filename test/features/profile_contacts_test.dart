import 'package:dio/dio.dart';
import 'package:elyeter/app/cubit/locale_cubit.dart';
import 'package:elyeter/app/cubit/theme_cubit.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/constants/app_icons.dart';
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
  _ContactsClient(this.data) : super(Dio());
  final Map<String, dynamic> data;
  final requests = <String>[];

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    requests.add(path);
    if (path == '/contacts') return data;
    if (path == '/pages') return <dynamic>[];
    throw StateError('Unexpected request: $path');
  }
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());
  tearDown(() async => getIt.reset());

  Future<void> pumpProfile(
    WidgetTester tester,
    Map<String, dynamic> data, {
    bool dark = false,
  }) async {
    final client = _ContactsClient(data);
    getIt.registerSingleton<ShopApi>(ShopApi(client));
    final auth = AuthCubit(_IdleAuthRepository());
    final theme = ThemeCubit();
    final locale = LocaleCubit();
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
        child: MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(client.requests, contains('/contacts'));
  }

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

  testWidgets('dark profile uses dark app bar, settings rows and call button', (
    tester,
  ) async {
    await pumpProfile(tester, {'phone_primary': '+99365000001'}, dark: true);

    expect(
      tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
      AppTheme.dark.scaffoldBackgroundColor,
    );
    final appBarTheme = Theme.of(
      tester.element(find.byType(AppBar)),
    ).appBarTheme;
    expect(appBarTheme.backgroundColor, AppTheme.dark.scaffoldBackgroundColor);
    expect(appBarTheme.scrolledUnderElevation, 0);
    expect(appBarTheme.surfaceTintColor, Colors.transparent);
    final savedLocations = find.ancestor(
      of: find.text('My saved locations'),
      matching: find.byType(SettingsTile),
    );
    final locationIcons = tester.widgetList<HugeIcon>(
      find.descendant(of: savedLocations, matching: find.byType(HugeIcon)),
    );
    expect(locationIcons.first.icon, AppIcons.location);
    expect(locationIcons.first.strokeWidth, 2.5);
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
    expect(
      callButton.style?.backgroundColor?.resolve({}),
      AppTheme.dark.colorScheme.surface,
    );
  });
}
