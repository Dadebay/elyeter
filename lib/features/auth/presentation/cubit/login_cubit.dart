import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_cubit.dart';

/// Which half of the SMS flow the screen is on.
enum LoginStep { phone, code }

class LoginState extends Equatable {
  const LoginState({
    this.step = LoginStep.phone,
    this.phone = '',
    this.submitting = false,
    this.resendIn = 0,
    this.expiresIn = 0,
    this.failure,
    this.user,
    this.isNewUser = false,
  });

  final LoginStep step;
  final String phone;
  final bool submitting;

  /// Seconds left before "Resend" may be tapped again.
  final int resendIn;

  /// Seconds the current code stays valid.
  final int expiresIn;

  final Failure? failure;

  /// Set once the login succeeded — the page listens for it and leaves.
  final AppUser? user;
  final bool isNewUser;

  bool get canResend => resendIn <= 0 && !submitting;
  bool get signedIn => user != null;

  LoginState copyWith({
    LoginStep? step,
    String? phone,
    bool? submitting,
    int? resendIn,
    int? expiresIn,
    Failure? failure,
    AppUser? user,
    bool? isNewUser,
    bool clearFailure = false,
  }) => LoginState(
    step: step ?? this.step,
    phone: phone ?? this.phone,
    submitting: submitting ?? this.submitting,
    resendIn: resendIn ?? this.resendIn,
    expiresIn: expiresIn ?? this.expiresIn,
    failure: clearFailure ? null : (failure ?? this.failure),
    user: user ?? this.user,
    isNewUser: isNewUser ?? this.isNewUser,
  );

  @override
  List<Object?> get props => [
    step,
    phone,
    submitting,
    resendIn,
    expiresIn,
    failure,
    user,
    isNewUser,
  ];
}

/// Drives `POST /auth/send-code` and `POST /auth/verify-code`, including the
/// resend countdown the first one hands back.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository, this._auth) : super(const LoginState());

  final AuthRepository _repository;
  final AuthCubit _auth;

  Timer? _ticker;

  /// Turkmen numbers only, exactly `+993XXXXXXXX`.
  static final _phonePattern = RegExp(r'^\+993\d{8}$');

  static bool isValidPhone(String phone) =>
      _phonePattern.hasMatch(normalize(phone));

  /// Accepts what a customer actually types — spaces, a leading 8 or a bare
  /// local number — and produces the format the API demands.
  static String normalize(String input) {
    var digits = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+')) digits = digits.substring(1);
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.length == 8) digits = '993$digits';
    return '+$digits';
  }

  Future<void> sendCode(String rawPhone) async {
    final phone = normalize(rawPhone);
    if (!isValidPhone(phone)) {
      return emit(
        state.copyWith(
          phone: phone,
          failure: const ApiFailure(code: 'validation_error', statusCode: 400),
        ),
      );
    }

    emit(state.copyWith(phone: phone, submitting: true, clearFailure: true));

    final result = await _repository.sendCode(phone);
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            step: LoginStep.code,
            submitting: false,
            resendIn: data.resendAfter,
            expiresIn: data.expiresIn,
            clearFailure: true,
          ),
        );
        _startCountdown(data.resendAfter);
      case Error(:final failure):
        emit(state.copyWith(submitting: false, failure: failure));
    }
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    await sendCode(state.phone);
  }

  Future<void> verify(String code) async {
    emit(state.copyWith(submitting: true, clearFailure: true));

    final result = await _repository.verifyCode(
      phone: state.phone,
      code: code.trim(),
    );
    switch (result) {
      case Success(:final data):
        _auth.onSignedIn(data.user);
        emit(
          state.copyWith(
            submitting: false,
            user: data.user,
            isNewUser: data.isNew,
            clearFailure: true,
          ),
        );
      case Error(:final failure):
        emit(state.copyWith(submitting: false, failure: failure));
    }
  }

  /// Back to the phone field — the code is tied to the number it was sent to.
  void editPhone() {
    _ticker?.cancel();
    emit(LoginState(phone: state.phone));
  }

  void _startCountdown(int seconds) {
    _ticker?.cancel();
    if (seconds <= 0) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = state.resendIn - 1;
      if (left <= 0) timer.cancel();
      if (!isClosed) emit(state.copyWith(resendIn: left < 0 ? 0 : left));
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
