import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to environment-driven configuration.
///
/// Reads via [_env] which returns '' when dotenv hasn't been initialised
/// (e.g. unit tests) instead of throwing.
class ApiConfig {
  ApiConfig._();

  static String _env(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Gemini Flash API key. Loaded from `.env` (key `GEMINI_API_KEY`).
  static String get geminiApiKey => _env('GEMINI_API_KEY');

  /// Gemini model identifier. Override via `.env` `GEMINI_MODEL=...` if needed.
  ///
  /// Default = `gemini-flash-latest` — Google auto-rotates this alias to the
  /// most current stable Gemini Flash so we don't hit "model not found" when
  /// older versions get retired (e.g. gemini-1.5-flash was removed from new
  /// API keys). Native multimodal (text + image + short video) supported.
  static String get geminiModel {
    final override = _env('GEMINI_MODEL');
    return override.isEmpty ? 'gemini-flash-latest' : override;
  }

  static bool get hasGeminiKey =>
      geminiApiKey.isNotEmpty &&
      geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';

  /// Supabase project URL, e.g. `https://xxxx.supabase.co`.
  static String get supabaseUrl => _env('SUPABASE_URL');

  /// Supabase anon (publishable) API key — accepts both legacy JWT
  /// (`eyJhbGc...`) and the new `sb_publishable_...` format.
  static String get supabaseAnonKey => _env('SUPABASE_ANON_KEY');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('xxxxxx');

  /// Sentry DSN. Empty → Sentry disabled (no crash reporting).
  static String get sentryDsn => _env('SENTRY_DSN');

  /// Tag in Sentry dashboard. Defaults to "production" if not set.
  static String get sentryEnvironment {
    final env = _env('SENTRY_ENV');
    return env.isEmpty ? 'production' : env;
  }

  static bool get hasSentry => sentryDsn.startsWith('https://');
}
