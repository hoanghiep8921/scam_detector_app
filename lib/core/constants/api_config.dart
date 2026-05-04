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

  /// Gemini model identifier — using Flash for speed/cost.
  /// (gemini-1.5-* đã deprecate; dùng 2.5-flash cho generation hiện tại.)
  static const String geminiModel = 'gemini-2.5-flash';

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
}
