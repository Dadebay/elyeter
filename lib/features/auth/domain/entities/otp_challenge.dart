import 'package:equatable/equatable.dart';

/// What `POST /auth/send-code` answers with: how long the code is good for,
/// and how long the "Resend" button stays disabled.
class OtpChallenge extends Equatable {
  const OtpChallenge({required this.expiresIn, required this.resendAfter});

  /// Seconds the code stays valid.
  final int expiresIn;

  /// Seconds until a new code may be requested — drive the countdown off it.
  final int resendAfter;

  @override
  List<Object?> get props => [expiresIn, resendAfter];
}
