import '../../l10n/app_localizations.dart';
import '../error/failure.dart';

/// Turns a [Failure] into a localized, user-facing sentence.
/// Blocs stay free of copy; widgets call `failure.localize(context.l10n)`.
extension FailureL10n on Failure {
  String localize(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    UnauthorizedFailure() => l10n.errorUnauthorized,
    NotFoundFailure() => l10n.errorNotFound,
    CacheFailure() => l10n.errorCache,
    ServerFailure() => l10n.errorServer,
    UnknownFailure() => l10n.errorUnknown,
  };
}
