import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/app_constants.dart';
import '../core/di/injector.dart';
import '../core/localization/fallback_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/cart/presentation/cubit/cart_cubit.dart';
import '../features/favorite/presentation/cubit/favorite_cubit.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../l10n/app_localizations.dart';
import 'cubit/locale_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'router/app_router.dart';

/// Root widget: global blocs, theme, localization and the router.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
        BlocProvider<FavoriteCubit>.value(value: getIt<FavoriteCubit>()),
        BlocProvider<CartCubit>.value(value: getIt<CartCubit>()),
        BlocProvider<ProfileCubit>.value(value: getIt<ProfileCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.router,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  // Last: catches the locales the global ones do not ship,
                  // which is Turkmen. See [FallbackLocalizations].
                  ...FallbackLocalizations.delegates,
                ],
              );
            },
          );
        },
      ),
    );
  }
}
