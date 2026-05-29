import 'package:flutter/material.dart';

/// Color palette — derived from Stitch "Sentinel Assurance" design system.
///
/// Static constants are the light-mode values (kept for backward compat).
/// Use [AppColors.of(context)] for adaptive colors that respond to dark mode.
class AppColors {
  AppColors._();

  // Primary brand — deep security blue (Indigo 900).
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryDark = Color(0xFF000666);
  static const Color primaryContainer = Color(0xFFE0E0FF);
  static const Color onPrimaryContainer = Color(0xFF000767);
  static const Color secondary = Color(0xFF545A90);

  // Surfaces — high-brightness greys per design system.
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);

  // Risk levels — semantic palette (psychological clarity per design notes).
  static const Color riskHigh = Color(0xFFBA1A1A);    // Đỏ - Lừa đảo
  static const Color riskHighContainer = Color(0xFFFFDAD6);
  static const Color riskMedium = Color(0xFFE65100);  // Cam - Nghi ngờ
  static const Color riskMediumContainer = Color(0xFFFFE0B2);
  static const Color riskSafe = Color(0xFF1B5E20);    // Xanh - An toàn
  static const Color riskSafeContainer = Color(0xFFC8E6C9);
  static const Color riskUnknown = Color(0xFF757783);

  // Text — cool-toned greys for systematic appearance.
  static const Color textPrimary = Color(0xFF1A1C1C);
  static const Color textSecondary = Color(0xFF454652);
  static const Color textTertiary = Color(0xFF767683);

  static const Color outline = Color(0xFF767683);
  static const Color outlineVariant = Color(0xFFC6C5D4);
  static const Color border = Color(0xFFE0E4EA);

  /// Adaptive color set based on current brightness.
  static AdaptiveColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _dark : _light;
  }

  static const _light = AdaptiveColors(
    background: Color(0xFFF9F9F9),
    surface: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFEEEEEE),
    surfaceContainerLow: Color(0xFFF3F3F3),
    surfaceContainerHigh: Color(0xFFE8E8E8),
    textPrimary: Color(0xFF1A1C1C),
    textSecondary: Color(0xFF454652),
    textTertiary: Color(0xFF767683),
    border: Color(0xFFE0E4EA),
    outlineVariant: Color(0xFFC6C5D4),
    primary: Color(0xFF1A237E),
    primaryContainer: Color(0xFFE0E0FF),
    onPrimaryContainer: Color(0xFF000767),
  );

  // Facebook-inspired dark palette
  static const _dark = AdaptiveColors(
    background: Color(0xFF18191A),
    surface: Color(0xFF242526),
    surfaceContainer: Color(0xFF3A3B3C),
    surfaceContainerLow: Color(0xFF2F3031),
    surfaceContainerHigh: Color(0xFF4E4F50),
    textPrimary: Color(0xFFE4E6EB),
    textSecondary: Color(0xFFB0B3B8),
    textTertiary: Color(0xFF8A8D91),
    border: Color(0xFF3E4042),
    outlineVariant: Color(0xFF4E4F50),
    primary: Color(0xFF7B8CFF),
    primaryContainer: Color(0xFF1A237E),
    onPrimaryContainer: Color(0xFFE0E0FF),
  );
}

/// Adaptive color values that change based on light/dark mode.
class AdaptiveColors {
  const AdaptiveColors({
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.outlineVariant,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  });

  final Color background;
  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color outlineVariant;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
}
