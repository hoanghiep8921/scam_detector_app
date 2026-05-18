import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';

/// Minimal string localization. Add new keys as needed.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _strings = {
    'vi': {
      'settings_title': 'Cài đặt',
      'settings_appearance': 'Giao diện',
      'settings_light': 'Sáng',
      'settings_dark': 'Tối',
      'settings_system': 'Theo hệ thống',
      'settings_language': 'Ngôn ngữ',
      'settings_language_vi': 'Tiếng Việt',
      'settings_language_en': 'English',
      'settings_behavior': 'Điều hướng',
      'settings_prevent_minimize': 'Ngăn thu nhỏ khi bấm Back',
      'settings_prevent_minimize_desc': 'Bấm Back sẽ quay màn trước thay vì thoát app.',
      'settings_about': 'Về ứng dụng',
      'settings_version': 'Phiên bản',
      'settings_app_name': 'Scam Guard',
      'settings_data_reset': 'Reset toàn bộ dữ liệu',
    },
    'en': {
      'settings_title': 'Settings',
      'settings_appearance': 'Appearance',
      'settings_light': 'Light',
      'settings_dark': 'Dark',
      'settings_system': 'System default',
      'settings_language': 'Language',
      'settings_language_vi': 'Tiếng Việt',
      'settings_language_en': 'English',
      'settings_behavior': 'Navigation',
      'settings_prevent_minimize': 'Prevent minimize on Back',
      'settings_prevent_minimize_desc': 'Back navigates to previous screen instead of exiting.',
      'settings_about': 'About',
      'settings_version': 'Version',
      'settings_app_name': 'Scam Guard',
      'settings_data_reset': 'Reset all data',
    },
  };

  static String of(String key, [String locale = 'vi']) =>
      _strings[locale]?[key] ?? _strings['vi']![key] ?? key;
}

/// Helper to read the current locale from [SettingsService] via context.
extension StringsX on BuildContext {
  String tr(String key) {
    final locale = _localeOf(this);
    return AppStrings.of(key, locale);
  }
}

String _localeOf(BuildContext context) {
  final service = Provider.of<SettingsService>(context, listen: false);
  return service.locale;
}
