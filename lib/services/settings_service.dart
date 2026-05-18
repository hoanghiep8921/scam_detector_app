import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide settings persisted to SharedPreferences.
class SettingsService extends ChangeNotifier {
  static const _themeKey = 'settings_theme_mode';
  static const _localeKey = 'settings_locale';
  static const _preventMinimizeKey = 'settings_prevent_minimize';

  ThemeMode _themeMode = ThemeMode.light;
  String _locale = 'vi';
  bool _preventMinimize = false;

  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  bool get preventMinimize => _preventMinimize;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeKey);
    if (raw == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (raw == 'system') {
      _themeMode = ThemeMode.system;
    }
    _locale = prefs.getString(_localeKey) ?? 'vi';
    _preventMinimize = prefs.getBool(_preventMinimizeKey) ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    _locale = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
    notifyListeners();
  }

  Future<void> setPreventMinimize(bool value) async {
    _preventMinimize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preventMinimizeKey, value);
    notifyListeners();
  }
}
