import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/models/patient.dart';
import 'package:clinicos/services/patient_service.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onContinueStaff;
  final Function(Patient patient) onPatientLogin;

  const LandingScreen({
    super.key,
    required this.onContinueStaff,
    required this.onPatientLogin,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedRoleIndex = 0; // 0 = Staff, 1 = Patient
  final _patientIdController = TextEditingController();
  final PatientService _patientService = PatientService();
  bool _isLoadingPatient = false;
  String? _patientError;

  @override
  void dispose() {
    _patientIdController.dispose();
    super.dispose();
  }

  Future<void> _handlePatientLogin() async {
    final query = _patientIdController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _patientError = 'Please enter Patient ID (e.g. PAT-2026-000001) or Mobile Number';
      });
      return;
    }

    setState(() {
      _isLoadingPatient = true;
      _patientError = null;
    });

    try {
      final patients = await _patientService.searchPatients(query);
      if (patients.isEmpty) {
        // Try direct lookup if exact ID
        try {
          final p = await _patientService.getPatient(query);
          if (mounted) {
            widget.onPatientLogin(p);
            return;
          }
        } catch (_) {
          setState(() {
            _patientError = 'No patient record found matching "$query"';
          });
        }
      } else {
        if (mounted) {
          widget.onPatientLogin(patients.first);
        }
      }
    } catch (e) {
      setState(() {
        _patientError = 'Failed to lookup patient: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPatient = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // App Name
              Text(
                'ClinicOS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Patient & Document Management System',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 36),

              // Mode Toggle (Doctor / Staff vs Patient)
              Container(
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRoleIndex = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRoleIndex == 0 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Doctor / Staff',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedRoleIndex == 0 ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRoleIndex = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRoleIndex == 1 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Patient Portal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedRoleIndex == 1 ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Login Card
              Container(
                constraints: const BoxConstraints(maxWidth: 380),
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _selectedRoleIndex == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Clinic Workspace',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Access full patient records, upload medical reports, & manage clinic files.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: widget.onContinueStaff,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Continue to Dashboard'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Patient Health Portal',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter your Patient ID or registered Mobile Number to access your documents.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _patientIdController,
                            decoration: InputDecoration(
                              hintText: 'e.g. PAT-2026-000001 or 9876543210',
                              labelText: 'Patient ID / Mobile',
                              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                              errorText: _patientError,
                            ),
                            onSubmitted: (_) => _handlePatientLogin(),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoadingPatient ? null : _handlePatientLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoadingPatient
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('View My Medical Records'),
                                      SizedBox(width: 8),
                                      Icon(Icons.folder_shared_outlined, size: 18),
                                    ],
                                  ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 36),
              Text(
                'Powered by Google Apps Script & Google Drive Storage',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
