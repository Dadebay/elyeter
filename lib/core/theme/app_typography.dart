import 'package:flutter/material.dart';

/// Inter-based text theme. Sizes follow the Material 3 role names so
/// `Theme.of(context).textTheme.titleMedium` keeps working everywhere.
abstract final class AppTypography {
  /// Body/default family — Inter text cut (18pt optical).
  static const fontFamily = 'Inter';

  /// Display cut. Tighter letterforms; use for headlines and small UI
  /// labels such as the bottom navigation.
  static const displayFontFamily = 'InterDisplay';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32, height: 1.2, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(fontSize: 24, height: 1.25, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 22, height: 1.25, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20, height: 1.3, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, height: 1.35, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, height: 1.35, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, height: 1.2, fontWeight: FontWeight.w500),
  );
}
