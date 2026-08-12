import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/core/utils/responsive.dart';
import 'package:clinicos/features/shell/widgets/sidebar.dart';
import 'package:clinicos/features/dashboard/screens/dashboard_screen.dart';
import 'package:clinicos/features/patients/screens/patients_list_screen.dart';
import 'package:clinicos/features/patients/screens/add_patient_screen.dart';
import 'package:clinicos/features/patients/screens/patient_detail_screen.dart';
import 'package:clinicos/features/patients/controllers/patient_controller.dart';
import 'package:clinicos/features/coming_soon/coming_soon_screen.dart';
import 'package:clinicos/models/patient.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final PatientController _patientController = PatientController();

  // Sub-navigation state within Patients module
  bool _isAddingPatient = false;
  Patient? _selectedPatient;

  final List<String> _navTitles = [
    'Dashboard',
    'Patients',
    'Appointments',
    'Queue',
    'Visits',
    'Prescriptions',
    'Documents',
    'Billing',
    'Settings',
  ];

  void _onNavSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _isAddingPatient = false;
      _selectedPatient = null;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          patientController: _patientController,
          onNavigate: (idx) => _onNavSelected(idx),
        );
      case 1:
        if (_isAddingPatient) {
          return AddPatientScreen(
            controller: _patientController,
            onPatientCreated: (p) {
              setState(() {
                _isAddingPatient = false;
                _selectedPatient = p;
              });
            },
          );
        }
        if (_selectedPatient != null) {
          return PatientDetailScreen(patient: _selectedPatient!);
        }
        return PatientsListScreen(
          controller: _patientController,
          onAddPatient: () {
            setState(() {
              _isAddingPatient = true;
              _selectedPatient = null;
            });
          },
          onPatientSelect: (p) {
            setState(() {
              _selectedPatient = p;
              _isAddingPatient = false;
            });
          },
        );
      default:
        return ComingSoonScreen(title: _navTitles[_selectedIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: AppColors.surface,
              surfaceTintColor: AppColors.surface,
              elevation: 0,
              title: Text(
                _navTitles[_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            )
          : null,
      drawer: !isDesktop
          ? Drawer(
              child: Sidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  Navigator.of(context).pop(); // Close drawer
                  _onNavSelected(index);
                },
              ),
            )
          : null,
      bottomNavigationBar: Responsive.isMobile(context)
          ? BottomNavigationBar(
              currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
              onTap: (index) => _onNavSelected(index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_rounded),
                  label: 'Patients',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today_rounded),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Billing',
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) => _onNavSelected(index),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
