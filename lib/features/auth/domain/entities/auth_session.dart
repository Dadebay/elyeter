import 'package:equatable/equatable.dart';

import 'app_user.dart';

/// A successful `POST /auth/verify-code`.
///
/// There is no refresh token: [accessToken] lives for 30 days and a 401
/// means running the SMS flow again.
class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.isNew = false,
  });

  final String accessToken;
  final AppUser user;

  /// The account was just created — a good moment to ask for a name.
  final bool isNew;

  @override
  List<Object?> get props => [accessToken, user, isNew];
}
