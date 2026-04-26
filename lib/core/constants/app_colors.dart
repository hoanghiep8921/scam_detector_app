import 'package:flutter/material.dart';

/// Color palette for risk levels and app theme.
class AppColors {
  AppColors._();

  // Primary brand
  static const Color primary = Color(0xFF1E5BB8);
  static const Color primaryDark = Color(0xFF143E80);
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;

  // Risk levels (per spec)
  static const Color riskHigh = Color(0xFFE53935);    // Đỏ - Lừa đảo
  static const Color riskMedium = Color(0xFFF57C00);  // Cam - Nghi ngờ
  static const Color riskSafe = Color(0xFF2E7D32);    // Xanh - An toàn
  static const Color riskUnknown = Color(0xFF9E9E9E);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textTertiary = Color(0xFF9AA0A6);

  // Borders
  static const Color border = Color(0xFFE0E4EA);
}
