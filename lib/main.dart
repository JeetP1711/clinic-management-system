import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/landing_screen.dart';
import 'features/shell/app_shell.dart';

void main() {
  runApp(const ClinicOSApp());
}

class ClinicOSApp extends StatefulWidget {
  const ClinicOSApp({super.key});

  @override
  State<ClinicOSApp> createState() => _ClinicOSAppState();
}

class _ClinicOSAppState extends State<ClinicOSApp> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinicOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoggedIn
          ? const AppShell()
          : LandingScreen(
              onContinue: () {
                setState(() {
                  _isLoggedIn = true;
                });
              },
            ),
    );
  }
}
