import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../l10n/app_localizations.dart';

/// Holds the selected language. `null` means "follow the device locale".
class LocaleCubit extends HydratedCubit<Locale?> {
  LocaleCubit() : super(null);

  static List<Locale> get supported => AppLocalizations.supportedLocales;

  void setLocale(Locale? locale) => emit(locale);

  void setLanguageCode(String code) => emit(Locale(code));

  void useSystemLocale() => emit(null);

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final code = json['languageCode'] as String?;
    return code == null ? null : Locale(code);
  }

  @override
  Map<String, dynamic>? toJson(Locale? state) => {
    'languageCode': state?.languageCode,
  };
}
