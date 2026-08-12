import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/core/utils/responsive.dart';
import 'package:clinicos/features/patients/controllers/patient_controller.dart';
import 'package:clinicos/features/patients/widgets/patient_card.dart';
import 'package:clinicos/features/patients/widgets/patient_table.dart';
import 'package:clinicos/models/patient.dart';

class PatientsListScreen extends StatefulWidget {
  final PatientController controller;
  final VoidCallback onAddPatient;
  final Function(Patient) onPatientSelect;

  const PatientsListScreen({
    super.key,
    required this.controller,
    required this.onAddPatient,
    required this.onPatientSelect,
  });

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load patients when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patients',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage patient records and clinical details.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: widget.onAddPatient,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('+ Add Patient'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (val) => widget.controller.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search patients by Name, Patient ID, or Mobile number...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          widget.controller.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Main Content Area
            Expanded(
              child: ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  if (widget.controller.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text('Loading patient records from Google Sheets...'),
                        ],
                      ),
                    );
                  }

                  if (widget.controller.error != null && widget.controller.patients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            'Error Loading Patients',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.controller.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => widget.controller.fetchPatients(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final patientsList = widget.controller.patients;

                  if (patientsList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people_outline_rounded,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No patients registered yet'
                                : 'No patients found matching "${_searchController.text}"',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Click "+ Add Patient" above to create your first patient record.'
                                : 'Try searching by a different name, mobile, or ID.',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => widget.controller.fetchPatients(),
                    color: AppColors.primary,
                    child: Responsive(
                      mobile: ListView.builder(
                        itemCount: patientsList.length,
                        itemBuilder: (context, index) {
                          final p = patientsList[index];
                          return PatientCard(
                            patient: p,
                            onTap: () => widget.onPatientSelect(p),
                          );
                        },
                      ),
                      desktop: SingleChildScrollView(
                        child: PatientTable(
                          patients: patientsList,
                          onPatientTap: widget.onPatientSelect,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
