import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';
import '../entities/auth_session.dart';
import '../entities/otp_challenge.dart';

/// The SMS login flow and the account endpoints behind it.
abstract interface class AuthRepository {
  /// `POST /auth/send-code` — Turkmen numbers only, `+993XXXXXXXX`.
  Future<Result<OtpChallenge>> sendCode(String phone);

  /// `POST /auth/verify-code` — stores the token on success.
  Future<Result<AuthSession>> verifyCode({
    required String phone,
    required String code,
  });

  /// `GET /auth/me`
  Future<Result<AppUser>> currentUser();

  /// `PATCH /auth/me`
  Future<Result<AppUser>> updateProfile({String? username, String? image});

  /// `PATCH /auth/fcm-token` — stored but not yet delivered to.
  Future<Result<void>> updateFcmToken(String token);

  /// `DELETE /auth/me` — deletes the account and clears the session.
  Future<Result<void>> deleteAccount();

  /// Local only: drops the stored token.
  Future<void> signOut();

  /// Whether a token is on the device. It may still be expired — the first
  /// 401 is what proves it.
  Future<bool> hasSession();
}
