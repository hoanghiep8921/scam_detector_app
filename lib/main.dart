import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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

  // Sentry catches Flutter framework errors, async errors, and platform
  // dispatcher errors automatically when we wrap runApp via SentryFlutter.init.
  // Disabled when DSN is missing so local debug builds don't ping Sentry.
  if (ApiConfig.hasSentry) {
    await SentryFlutter.init(
      (options) {
        options.dsn = ApiConfig.sentryDsn;
        options.environment = ApiConfig.sentryEnvironment;
        // Sample everything in early stages — tighten later if free quota hits.
        options.tracesSampleRate = 1.0;
        // Sentry already captures stack traces; don't include screenshots
        // since the app handles sensitive numbers / messages.
        options.attachScreenshot = false;
        // Sanitize PII fields (phone numbers, account numbers) before send.
        options.sendDefaultPii = false;
      },
      appRunner: () => runApp(const ScamDetectorApp()),
    );
  } else {
    runApp(const ScamDetectorApp());
  }
}
