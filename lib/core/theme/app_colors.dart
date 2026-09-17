import 'package:flutter/material.dart';

/// Raw color palette. Never reference these directly from widgets —
/// go through `Theme.of(context).colorScheme` or [AppTheme] instead.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFFFF6B35);
  static const primaryDark = Color(0xFFE2541F);
  static const primarySoft = Color(0xFFFFF1EA);

  // Neutrals
  static const black = Color(0xFF1A1A1A);
  static const grey900 = Color(0xFF2B2B2B);
  static const grey700 = Color(0xFF5C5C5C);
  static const grey500 = Color(0xFF8E8E93);
  static const grey300 = Color(0xFFD1D1D6);
  static const grey100 = Color(0xFFF2F2F7);
  static const background = Color(0xFFF7F7F7);
  static const surface = Color(0xFFFFFFFF);
  static const white = Color(0xFFFFFFFF);

  // Dark surfaces
  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);

  // Semantic — order statuses in the designs
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF5A623);
  static const error = Color(0xFFE74C3C);
  static const info = Color(0xFF2F80ED);
}
