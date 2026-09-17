import 'package:bloc/bloc.dart';

import '../utils/app_logger.dart';

/// Logs every bloc transition and error in one place — replaces scattered
/// prints and gives a single hook for Crashlytics/Sentry later.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.d('${bloc.runtimeType}: ${change.currentState} -> ${change.nextState}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.e('${bloc.runtimeType} error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
