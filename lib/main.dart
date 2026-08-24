import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_theme.dart';
import 'package:clinicos/features/auth/screens/landing_screen.dart';
import 'package:clinicos/features/patient_portal/patient_portal_screen.dart';
import 'package:clinicos/features/shell/app_shell.dart';
import 'package:clinicos/models/patient.dart';

void main() {
  runApp(const ClinicOSApp());
}

class ClinicOSApp extends StatefulWidget {
  const ClinicOSApp({super.key});

  @override
  State<ClinicOSApp> createState() => _ClinicOSAppState();
}

class _ClinicOSAppState extends State<ClinicOSApp> {
  bool _isStaffLoggedIn = false;
  Patient? _loggedInPatient;

  @override
  Widget build(BuildContext context) {
    Widget currentHome;

    if (_isStaffLoggedIn) {
      currentHome = const AppShell();
    } else if (_loggedInPatient != null) {
      currentHome = PatientPortalScreen(
        patient: _loggedInPatient!,
        onLogout: () {
          setState(() {
            _loggedInPatient = null;
          });
        },
      );
    } else {
      currentHome = LandingScreen(
        onContinueStaff: () {
          setState(() {
            _isStaffLoggedIn = true;
          });
        },
        onPatientLogin: (patient) {
          setState(() {
            _loggedInPatient = patient;
          });
        },
      );
    }

    return MaterialApp(
      title: 'ClinicOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: currentHome,
    );
  }
}
