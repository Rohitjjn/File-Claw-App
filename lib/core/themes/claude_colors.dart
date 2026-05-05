import 'package:flutter/material.dart';

/// Claude design system color palette.
///
/// Replicates Anthropic Claude mobile app aesthetic:
/// warm off-white surfaces, terracotta orange accents, no shadows.
class ClaudeColors {
  ClaudeColors._();

  // Brand
  static const Color primary = Color(0xFFD97757); // Terracotta orange
  static const Color primaryVariant = Color(0xFFB95C3D);
  static const Color accent = Color(0xFFD97757);

  // Light theme
  static const Color lightBackground = Color(0xFFFAFAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF5F5F0);
  static const Color lightBorder = Color(0xFFE5E5E0);
  static const Color lightDivider = Color(0xFFE5E5E0);
  static const Color lightTextPrimary = Color(0xFF2D2D2D);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);

  // Dark theme
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkSurfaceMuted = Color(0xFF252525);
  static const Color darkBorder = Color(0xFF3D3D3D);
  static const Color darkDivider = Color(0xFF3D3D3D);
  static const Color darkTextPrimary = Color(0xFFE5E5E5);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
