import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/patient.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          elevation: 0,
          title: Text(
            patient.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Appointments'),
              Tab(text: 'Visits'),
              Tab(text: 'Reports'),
              Tab(text: 'Prescriptions'),
              Tab(text: 'Documents'),
              Tab(text: 'Billing'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header Profile Banner
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      patient.fullName.isNotEmpty ? patient.fullName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              patient.fullName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                patient.patientId,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.mobile}  •  ${patient.age} Years  •  ${patient.gender}'
                          '${patient.bloodGroup != null && patient.bloodGroup!.isNotEmpty ? "  •  Blood: ${patient.bloodGroup}" : ""}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(context),
                  _buildComingSoonTab('Appointments'),
                  _buildComingSoonTab('Visits'),
                  _buildComingSoonTab('Reports'),
                  _buildComingSoonTab('Prescriptions'),
                  _buildComingSoonTab('Documents'),
                  _buildComingSoonTab('Billing'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Demographics Card
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Demographics',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow('Patient ID', patient.patientId, isMonospace: true),
                        _infoRow('Full Name', patient.fullName),
                        _infoRow('Mobile Number', patient.mobile),
                        _infoRow('Date of Birth', patient.dateOfBirth),
                        _infoRow('Gender', patient.gender),
                        _infoRow('Blood Group', patient.bloodGroup ?? '—'),
                        _infoRow('Email', patient.email ?? '—'),
                        _infoRow('Address', patient.address ?? '—'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Drive & Status Card
              Expanded(
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Google Drive Integration',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _infoRow(
                              'Folder ID',
                              patient.driveFolderId ?? 'Not Created',
                              isMonospace: true,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.folder_outlined, color: AppColors.primary),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Folders created: Reports, Images, Documents, Prescriptions',
                                      style: TextStyle(
                                          fontSize: 12, color: AppColors.primaryDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Contact',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _infoRow('Contact Name', patient.emergencyContactName ?? '—'),
                            _infoRow('Contact Phone', patient.emergencyContact ?? '—'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
              color: isMonospace ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off_rounded, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            '$name Section',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'This tab is connected to Patient ID, features coming soon.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
