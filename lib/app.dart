import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/call_screening/call_screening_role_provider.dart';
import 'features/main_shell.dart';
import 'features/scam_check/scam_check_provider.dart';
import 'services/settings_service.dart';

class ScamDetectorApp extends StatelessWidget {
  const ScamDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScamCheckProvider()..loadHistory()),
        ChangeNotifierProvider(
          create: (_) => CallScreeningRoleProvider()..refresh(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsService()..load(),
        ),
      ],
      child: const _AppWithThemeAndLocale(),
    );
  }
}

/// Rebuilds [MaterialApp] whenever theme or locale settings change.
class _AppWithThemeAndLocale extends StatelessWidget {
  const _AppWithThemeAndLocale();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    return MaterialApp(
      title: 'Scam Detector',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      home: const MainShell(),
    );
  }
}
