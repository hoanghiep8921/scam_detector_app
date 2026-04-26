import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Risk classification per the product spec.
enum RiskLevel {
  safe,      // 🟢 An toàn
  suspicious, // 🟠 Nghi ngờ
  scam,      // 🔴 Lừa đảo
  unknown;

  String get label {
    switch (this) {
      case RiskLevel.safe:
        return 'An toàn';
      case RiskLevel.suspicious:
        return 'Nghi ngờ';
      case RiskLevel.scam:
        return 'Lừa đảo';
      case RiskLevel.unknown:
        return 'Chưa xác định';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.safe:
        return AppColors.riskSafe;
      case RiskLevel.suspicious:
        return AppColors.riskMedium;
      case RiskLevel.scam:
        return AppColors.riskHigh;
      case RiskLevel.unknown:
        return AppColors.riskUnknown;
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.safe:
        return Icons.verified_user_outlined;
      case RiskLevel.suspicious:
        return Icons.warning_amber_rounded;
      case RiskLevel.scam:
        return Icons.dangerous_outlined;
      case RiskLevel.unknown:
        return Icons.help_outline;
    }
  }

  /// Map a 0-100 score to a risk level.
  static RiskLevel fromScore(int score) {
    if (score >= 70) return RiskLevel.scam;
    if (score >= 40) return RiskLevel.suspicious;
    if (score >= 0) return RiskLevel.safe;
    return RiskLevel.unknown;
  }

  /// Parse from a string returned by the model.
  static RiskLevel fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'scam':
      case 'lừa đảo':
      case 'lua dao':
      case 'high':
        return RiskLevel.scam;
      case 'suspicious':
      case 'nghi ngờ':
      case 'nghi ngo':
      case 'medium':
        return RiskLevel.suspicious;
      case 'safe':
      case 'an toàn':
      case 'an toan':
      case 'low':
        return RiskLevel.safe;
      default:
        return RiskLevel.unknown;
    }
  }
}
