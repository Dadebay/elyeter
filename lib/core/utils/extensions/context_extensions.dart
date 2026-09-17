import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';

/// Shorthands that cut the boilerplate in every widget build method.
extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  MediaQueryData get mq => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Room the floating nav bar takes at the bottom of the screen. Pages
  /// that draw over it, or scroll under it, measure their clearance here.
  double get navBarHeight =>
      AppNavBar.heightFor(MediaQuery.viewPaddingOf(this).bottom);
}
