@Tags(['golden'])
library;

import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:elyeter/features/profile/presentation/view/edit_profile_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

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

  testWidgets('edit profile golden', (tester) async {
    await _loadFonts();
    tester.view
      ..physicalSize = const Size(1170, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ProfileCubit(),
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const EditProfilePage(),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(EditProfilePage),
      matchesGoldenFile('goldens/edit_profile_page.png'),
    );
  });
}
