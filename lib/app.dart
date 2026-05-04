import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/call_screening/call_screening_role_provider.dart';
import 'features/main_shell.dart';
import 'features/scam_check/scam_check_provider.dart';

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
      ],
      child: MaterialApp(
        title: 'Scam Detector',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainShell(),
      ),
    );
  }
}
