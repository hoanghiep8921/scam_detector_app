import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to environment-driven configuration.
class ApiConfig {
  ApiConfig._();

  /// Gemini Flash API key. Loaded from `.env` (key `GEMINI_API_KEY`).
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Gemini model identifier - using Flash for speed/cost.
  static const String geminiModel = 'gemini-1.5-flash';

  static bool get hasGeminiKey =>
      geminiApiKey.isNotEmpty &&
      geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';
}
