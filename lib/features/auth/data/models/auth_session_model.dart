import '../../../../core/network/api_response.dart';
import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

abstract final class AuthSessionModel {
  static AuthSession fromJson(Map<String, dynamic> json) => AuthSession(
    accessToken: json.str('access_token'),
    isNew: json.boolVal('is_new'),
    user: UserModel.fromJson(json.mapOrNull('user') ?? const {}),
  );
}
