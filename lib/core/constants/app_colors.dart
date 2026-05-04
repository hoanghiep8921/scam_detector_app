import 'package:flutter/material.dart';

/// Color palette — derived from Stitch "Sentinel Assurance" design system.
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
}
