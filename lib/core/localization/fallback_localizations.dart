import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Supplies Flutter's own Material and Cupertino strings for a locale the
/// framework does not ship — Turkmen being the app's.
///
/// Without this, `MaterialLocalizations.of` returns null under `tk` and every
/// Material widget that reads it throws on its null check: the back button's
/// tooltip, `showDialog`, `TextField`, the date pickers, the selection
/// toolbar. The app appears to work until the language is switched, and then
/// crashes on the next screen.
///
/// These delegates claim every locale, so they must be listed *after* the
/// global ones: `Localizations` keeps the first delegate that supports the
/// locale for a given type, which leaves English and Russian on the real
/// translations and sends only the uncovered locales here.
abstract final class FallbackLocalizations {
  /// The locale whose strings stand in. Turkish rather than English: these
  /// are short, common words — Back, Cancel, Paste, the month names — and a
  /// Turkmen reader gets far closer to them in a sister language than in
  /// English. Change this one constant to move the whole fallback.
  static const _standIn = Locale('tr');

  /// Add after `GlobalMaterialLocalizations.delegate` and friends.
  static const List<LocalizationsDelegate<dynamic>> delegates = [
    _MaterialFallbackDelegate(),
    _CupertinoFallbackDelegate(),
  ];
}

class _MaterialFallbackDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialFallbackDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(FallbackLocalizations._standIn);

  @override
  bool shouldReload(_MaterialFallbackDelegate old) => false;
}

class _CupertinoFallbackDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoFallbackDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(
        FallbackLocalizations._standIn,
      );

  @override
  bool shouldReload(_CupertinoFallbackDelegate old) => false;
}
