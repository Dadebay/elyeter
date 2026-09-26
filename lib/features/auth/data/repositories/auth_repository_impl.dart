import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/otp_challenge.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureStorage _storage;

  @override
  Future<Result<OtpChallenge>> sendCode(String phone) =>
      _guard(() => _remote.sendCode(phone));

  @override
  Future<Result<AuthSession>> verifyCode({
    required String phone,
    required String code,
  }) => _guard(() async {
    final session = await _remote.verifyCode(phone: phone, code: code);
    // Stored before anything else: every later call needs the bearer token.
    await _storage.saveAccessToken(session.accessToken);
    return session;
  });

  @override
  Future<Result<AppUser>> currentUser() => _guard(_remote.me);

  @override
  Future<Result<AppUser>> updateProfile({String? username, String? image}) =>
      _guard(() => _remote.updateMe(username: username, image: image));

  @override
  Future<Result<void>> updateFcmToken(String token) =>
      _guard(() => _remote.updateFcmToken(token));

  @override
  Future<Result<void>> deleteAccount() => _guard(() async {
    await _remote.deleteMe();
    await _storage.clear();
  });

  @override
  Future<void> signOut() => _storage.clear();

  @override
  Future<bool> hasSession() async {
    final token = await _storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on AppException catch (e) {
      return Error(e.toFailure());
    }
  }
}
