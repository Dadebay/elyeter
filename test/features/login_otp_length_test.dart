import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/failure.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/auth/domain/entities/app_user.dart';
import 'package:elyeter/features/auth/domain/entities/auth_session.dart';
import 'package:elyeter/features/auth/domain/entities/otp_challenge.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/auth/presentation/cubit/login_cubit.dart';
import 'package:elyeter/features/auth/presentation/view/login_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _OtpRepository implements AuthRepository {
  String? verifiedCode;

  @override
  Future<Result<OtpChallenge>> sendCode(String phone) async =>
      const Success(OtpChallenge(expiresIn: 180, resendAfter: 0));

  @override
  Future<Result<AuthSession>> verifyCode({
    required String phone,
    required String code,
  }) async {
    verifiedCode = code;
    return const Error(NetworkFailure());
  }

  @override
  Future<Result<AppUser>> currentUser() async => throw UnimplementedError();
  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();
  @override
  Future<bool> hasSession() async => false;
  @override
  Future<void> signOut() async {}
  @override
  Future<Result<AppUser>> updateProfile({
    String? username,
    String? image,
  }) async => throw UnimplementedError();
  @override
  Future<Result<void>> updateFcmToken(String token, {String? lang}) async =>
      throw UnimplementedError();
}

void main() {
  tearDown(() async => getIt.reset());

  testWidgets('OTP field truncates pasted digits to four before verification', (
    tester,
  ) async {
    final repository = _OtpRepository();
    final auth = AuthCubit(repository);
    addTearDown(auth.close);
    getIt.registerSingleton<LoginCubit>(LoginCubit(repository, auth));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const LoginPage(),
      ),
    );

    await tester.enterText(find.byType(TextField), '62123456');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final codeField = find.byType(TextField);
    expect(tester.widget<TextField>(codeField).maxLength, 4);
    expect(
      tester.widget<TextField>(codeField).maxLengthEnforcement,
      MaxLengthEnforcement.enforced,
    );

    await tester.enterText(codeField, '123456');
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(codeField).controller!.text, '1234');
    expect(repository.verifiedCode, '1234');
  });
}
