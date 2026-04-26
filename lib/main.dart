import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env. Don't crash if missing — service will fall back to stub mode.
  try {
    await dotenv.load();
  } catch (_) {
    // Run in stub/demo mode without API key.
  }
  runApp(const ScamDetectorApp());
}
