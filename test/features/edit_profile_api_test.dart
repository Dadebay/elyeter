import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/failure.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/auth/domain/entities/app_user.dart';
import 'package:elyeter/features/auth/domain/entities/auth_session.dart';
import 'package:elyeter/features/auth/domain/entities/otp_challenge.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:elyeter/features/profile/presentation/view/edit_profile_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _MemoryStorage implements Storage {
  final _values = <String, dynamic>{};
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

class _ProfileRepository implements AuthRepository {
  _ProfileRepository({this.fail = false});
  final bool fail;
  String? submittedName;

  @override
  Future<Result<AppUser>> updateProfile({
    String? username,
    String? image,
  }) async {
    submittedName = username;
    if (fail) return const Error(NetworkFailure());
    return Success(AppUser(id: 1, phone: '+99362123456', username: username));
  }

  @override
  Future<Result<AppUser>> currentUser() async => throw UnimplementedError();
  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();
  @override
  Future<bool> hasSession() async => true;
  @override
  Future<Result<OtpChallenge>> sendCode(String phone) async =>
      throw UnimplementedError();
  @override
  Future<void> signOut() async {}
  @override
  Future<Result<void>> updateFcmToken(String token, {String? lang}) async =>
      throw UnimplementedError();
  @override
  Future<Result<AuthSession>> verifyCode({
    required String phone,
    required String code,
  }) async => throw UnimplementedError();
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());
  tearDown(() async => getIt.reset());

  for (final fail in [false, true]) {
    testWidgets(
      fail
          ? 'failed profile PATCH does not save a new name locally'
          : 'saving a new name calls profile PATCH and updates account',
      (tester) async {
        final repository = _ProfileRepository(fail: fail);
        getIt.registerSingleton<AuthRepository>(repository);
        final auth = AuthCubit(repository)
          ..onSignedIn(
            const AppUser(id: 1, phone: '+99362123456', username: 'Old'),
          );
        final profile = ProfileCubit()
          ..adoptAccount(phone: '+99362123456', name: 'Old');
        addTearDown(auth.close);
        addTearDown(profile.close);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: auth),
              BlocProvider<ProfileCubit>.value(value: profile),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              locale: const Locale('en'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const EditProfilePage(),
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'New');
        await tester.pump();
        await tester.tap(find.byType(FilledButton).last);
        await tester.pumpAndSettle();

        expect(repository.submittedName, 'New');
        expect(profile.state.name, fail ? 'Old' : 'New');
        expect(auth.state.user?.username, fail ? 'Old' : 'New');
      },
    );
  }
}
