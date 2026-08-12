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
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddPatient,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => widget.controller.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search patients...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Patient filter coming soon')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main Patient List Area
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
                            Text('Loading patients...', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }

                    if (widget.controller.error != null && widget.controller.patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.error),
                            const SizedBox(height: 12),
                            const Text('Error Loading Patients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(widget.controller.error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 16),
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
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.primarySurface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.people_outline_rounded, size: 40, color: AppColors.primary),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No patients registered yet'
                                  : 'No patients found matching "${_searchController.text}"',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Tap "+" to register your first patient.'
                                  : 'Try searching by a different name, mobile, or ID.',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                          physics: const AlwaysScrollableScrollPhysics(),
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
                          physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}
