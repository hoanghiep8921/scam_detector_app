import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/constants/api_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env. Don't crash if missing — service will fall back to stub mode.
  try {
    await dotenv.load();
  } catch (_) {
    // Run in stub/demo mode without API key.
  }
  if (ApiConfig.hasSupabase) {
    try {
      await Supabase.initialize(
        url: ApiConfig.supabaseUrl,
        anonKey: ApiConfig.supabaseAnonKey,
        debug: false,
      );
    } catch (_) {
      // If init fails (bad key, etc.) the app still runs with local-only history.
    }
  }
  runApp(const ScamDetectorApp());
}
