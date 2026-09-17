import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/bloc/app_bloc_observer.dart';
import 'core/di/injector.dart';
import 'core/utils/app_logger.dart';

/// Everything that must happen before the first frame, in one place.
/// `main.dart` stays a two-liner and tests can reuse this setup.
Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.e(details.exceptionAsString(), details.exception, details.stack);
  };

  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path));

  Bloc.observer = const AppBlocObserver();

  await configureDependencies();

  runApp(builder());
}
