/// Spacing scale (4pt grid) and corner radii used across the app.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Default horizontal page padding.
  static const double page = 16;
}

abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

/// Geometry of the floating bottom navigation bar.
///
/// Lives in core so a page can clear the bar — the cart floats its summary
/// pill just above it — without importing the shell that draws it, and so
/// the two can never drift apart.
abstract final class AppNavBar {
  /// The icon-and-label row inside the capsule.
  static const double rowHeight = 52;

  /// Padding inside the capsule, above and below the row.
  static const double verticalPadding = AppSpacing.sm;

  /// Gap left under the capsule, on top of the system inset.
  static const double bottomGap = 10;

  /// Stands in for the system inset on a device without a home indicator.
  static const double fallbackInset = AppSpacing.md;

  /// How much room the bar takes at the bottom of the screen, given the
  /// device's [bottomInset].
  static double heightFor(double bottomInset) =>
      rowHeight +
      verticalPadding * 2 +
      (bottomInset > 0 ? bottomInset : fallbackInset) +
      bottomGap;
}
