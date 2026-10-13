import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../cubit/login_cubit.dart';
import '../../../../core/widgets/app_snack_bar.dart';

/// The SMS login: a phone number, then the code that number receives.
///
/// Pops with `true` once the session exists, so whoever pushed the page —
/// the profile header, a gated row — can carry on.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => getIt<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  /// A Turkmen subscriber number is exactly 8 digits. `+993` is drawn as a
  /// fixed prefix rather than typed into the field, so it cannot be deleted,
  /// doubled or replaced with another country's code.
  static const _phoneDigits = 8;

  /// The SMS code is 4 digits.
  static const _codeDigits = 4;

  final _phone = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppPageAppBar(title: l10n.loginTitle),
      body: BlocConsumer<LoginCubit, LoginState>(
        listenWhen: (previous, current) =>
            previous.signedIn != current.signedIn ||
            previous.failure != current.failure ||
            previous.step != current.step,
        listener: (context, state) {
          final failure = state.failure;
          if (failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.localize(l10n))),
            );
          }
          // A fresh code deserves an empty field, whether it is the first
          // one or a resend after a wrong entry.
          if (state.step == LoginStep.phone) _code.clear();

          if (state.signedIn) {
            AppSnackBar.show(context, l10n.loginSignedIn);
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xxl,
              AppSpacing.page,
              AppSpacing.xxxl,
            ),
            children: switch (state.step) {
              LoginStep.phone => _phoneStep(context, state),
              LoginStep.code => _codeStep(context, state),
            },
          );
        },
      ),
    );
  }

  List<Widget> _phoneStep(BuildContext context, LoginState state) {
    final l10n = context.l10n;

    return [
      Text(l10n.loginPhoneTitle, style: context.textTheme.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      Text(
        l10n.loginPhoneMessage,
        style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey500),
      ),
      const SizedBox(height: AppSpacing.xxl),
      TextField(
        controller: _phone,
        keyboardType: TextInputType.phone,
        autofocus: true,
        // Digits only, and never more than a Turkmen number holds: the
        // country code is the prefix below, not something to type.
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(_phoneDigits),
        ],
        // The number reads as one string, so what is typed and the code in
        // front of it are set at the same size rather than the prefix being
        // dropped to the smaller default.
        style: context.textTheme.titleMedium,
        decoration: InputDecoration(
          labelText: l10n.loginPhoneLabel,
          // Carries no country code of its own — the prefix below draws it.
          hintText: l10n.loginPhoneHint,
          // Smaller than what gets typed: the placeholder is a shape to aim
          // at, not something to read at the same weight as a real number.
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.grey500,
          ),
          prefixText: '+993 ',
          prefixStyle: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          counterText: '${_phone.text.length}/$_phoneDigits',
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _sendCode(context, state),
      ),
      const SizedBox(height: AppSpacing.xxl),
      FilledButton(
        onPressed: state.submitting || _phone.text.length < _phoneDigits
            ? null
            : () => _sendCode(context, state),
        child: state.submitting
            ? const _ButtonSpinner()
            : Text(l10n.loginSendCode),
      ),
    ];
  }

  List<Widget> _codeStep(BuildContext context, LoginState state) {
    final l10n = context.l10n;

    return [
      Text(l10n.loginCodeTitle, style: context.textTheme.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      Text(
        l10n.loginCodeMessage(state.phone),
        style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey500),
      ),
      const SizedBox(height: AppSpacing.xxl),
      TextField(
        controller: _code,
        keyboardType: TextInputType.number,
        autofocus: true,
        maxLength: _codeDigits,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        textAlign: TextAlign.center,
        style: context.textTheme.headlineSmall?.copyWith(letterSpacing: 8),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.loginCodeLabel,
          counterText: '',
        ),
        onChanged: (value) {
          setState(() {});
          // The last digit is the whole code: nobody needs to reach for a
          // button after typing it.
          if (value.length == _codeDigits) _verify(context, state);
        },
        onSubmitted: (_) => _verify(context, state),
      ),
      const SizedBox(height: AppSpacing.xxl),
      FilledButton(
        onPressed: state.submitting || _code.text.length < _codeDigits
            ? null
            : () => _verify(context, state),
        child: state.submitting
            ? const _ButtonSpinner()
            : Text(l10n.loginVerify),
      ),
      const SizedBox(height: AppSpacing.sm),
      TextButton(
        onPressed: state.canResend
            ? () => unawaited(context.read<LoginCubit>().resend())
            : null,
        child: Text(
          state.resendIn > 0
              ? l10n.loginResendIn(state.resendIn)
              : l10n.loginResend,
        ),
      ),
      TextButton(
        onPressed: state.submitting
            ? null
            : () => context.read<LoginCubit>().editPhone(),
        child: Text(l10n.loginChangePhone),
      ),
    ];
  }

  void _sendCode(BuildContext context, LoginState state) {
    if (state.submitting) return;
    unawaited(context.read<LoginCubit>().sendCode(_phone.text));
  }

  void _verify(BuildContext context, LoginState state) {
    if (state.submitting || _code.text.length != _codeDigits) return;
    unawaited(context.read<LoginCubit>().verify(_code.text));
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
  );
}
