import '../../../../core/network/api_response.dart';
import '../../domain/entities/app_user.dart';

/// The `user` object returned by `/auth/me` and the login response.
abstract final class UserModel {
  static AppUser fromJson(Map<String, dynamic> json) => AppUser(
    id: json.intVal('id'),
    phone: json.str('phone'),
    username: json.strOrNull('username'),
    image: json.strOrNull('image'),
    fcmToken: json.strOrNull('fcm_token'),
    isBlocked: json.boolVal('is_blocked'),
    createdAt: json.dateOrNull('created_at'),
    lastLoginAt: json.dateOrNull('last_login_at'),
  );
}
