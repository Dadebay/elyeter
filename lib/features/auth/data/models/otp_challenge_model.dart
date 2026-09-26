import '../../../../core/network/api_response.dart';
import '../../domain/entities/otp_challenge.dart';

abstract final class OtpChallengeModel {
  static OtpChallenge fromJson(Map<String, dynamic> json) => OtpChallenge(
    expiresIn: json.intVal('expires_in', 180),
    resendAfter: json.intVal('resend_after', 60),
  );
}
