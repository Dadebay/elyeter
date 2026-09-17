@Tags(['golden'])
library;

import 'package:elyeter/app/cubit/locale_cubit.dart';
import 'package:elyeter/app/cubit/theme_cubit.dart';
import 'package:elyeter/core/theme/app_theme.dart';
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

Future<void> _loadFonts() async {
  // SVG icons decode asynchronously; the caller pumps inside runAsync.
  final loader = FontLoader('InterDisplay')
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/InterDisplay-SemiBold.ttf'));
  await loader.load();

  final wordmark = FontLoader('Qurova')
    ..addFont(rootBundle.load('assets/fonts/QurovaDEMO-Medium.otf'));
  await wordmark.load();
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());

  testWidgets('profile page golden', (tester) async {
    await _loadFonts();
    tester.view
      ..physicalSize = const Size(1170, 4300)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => LocaleCubit()),
          BlocProvider(create: (_) => ProfileCubit()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
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
