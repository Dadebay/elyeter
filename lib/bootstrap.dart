import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/di/injector.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/system_ui_manager.dart';

/// Everything that must happen before the first frame, in one place.
/// `main.dart` stays a two-liner and tests can reuse this setup.
Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.e(details.exceptionAsString(), details.exception, details.stack);
  };

  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path));

  // Hide Android's navigation bar and keep the status bar: the app draws
  // its own floating bottom bar, and two stacked bars waste the space.
  // The manager also re-hides the bar after a swipe brings it back.
  await SystemUiManager().start();

  Bloc.observer = const AppBlocObserver();

  await configureDependencies();

  runApp(builder());
}
