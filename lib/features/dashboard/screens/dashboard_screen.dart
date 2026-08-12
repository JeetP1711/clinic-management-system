import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/core/utils/responsive.dart';
import 'package:clinicos/features/dashboard/widgets/stat_card.dart';
import 'package:clinicos/features/patients/controllers/patient_controller.dart';
import 'package:clinicos/models/patient.dart';

class DashboardScreen extends StatelessWidget {
  final PatientController patientController;
  final Function(int) onNavigate;
  final Function(Patient)? onPatientSelect;

  const DashboardScreen({
    super.key,
    required this.patientController,
    required this.onNavigate,
    this.onPatientSelect,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: ListenableBuilder(
            listenable: patientController,
            builder: (context, _) {
              final patientCount = patientController.totalCount.toString();
              final recentPatients = patientController.patients.take(5).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Greeting Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Dr. Jeet Patel 👋',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primarySurface,
                        child: const Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  InkWell(
                    onTap: () => onNavigate(1), // Go to Patients list/search
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppColors.textMuted, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search patients, appointments...',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Compact Statistics Grid (2 Columns)
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isMobile ? 2.2 : 2.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(
                        title: 'Patients',
                        value: patientCount,
                        icon: Icons.people_outline_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primarySurface,
                      ),
                      const StatCard(
                        title: 'Appointments',
                        value: '24',
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.info,
                        iconBgColor: AppColors.infoBackground,
                      ),
                      const StatCard(
                        title: 'Waiting',
                        value: '8',
                        icon: Icons.hourglass_empty_rounded,
                        iconColor: AppColors.warning,
                        iconBgColor: AppColors.warningBackground,
                      ),
                      const StatCard(
                        title: 'Completed',
                        value: '16',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: AppColors.success,
                        iconBgColor: AppColors.successBackground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Next Appointment Section
                  const Text(
                    'Next Appointment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primarySurface,
                              child: const Text('RP', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rahul Patel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                                  Text('General Consultation • Dr. Jeet Patel', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successBackground,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CONFIRMED',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        const Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text('10:30 AM Today', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions Section
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _QuickActionButton(
                          icon: Icons.person_add_alt_1_outlined,
                          label: '+ Patient',
                          onTap: () => onNavigate(1),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionButton(
                          icon: Icons.calendar_month_outlined,
                          label: '+ Appointment',
                          onTap: () => onNavigate(2),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionButton(
                          icon: Icons.medical_services_outlined,
                          label: '+ Visit',
                          onTap: () => onNavigate(4),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionButton(
                          icon: Icons.receipt_outlined,
                          label: '+ Invoice',
                          onTap: () => onNavigate(7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Patients Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Patients',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      TextButton(
                        onPressed: () => onNavigate(1),
                        child: const Text('View All', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  recentPatients.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text('No recent patients found', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentPatients.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final p = recentPatients[index];
                            final initial = p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : 'P';
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ListTile(
                                onTap: () {
                                  if (onPatientSelect != null) {
                                    onPatientSelect!(p);
                                  } else {
                                    onNavigate(1);
                                  }
                                },
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primarySurface,
                                  child: Text(
                                    initial,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                                  ),
                                ),
                                title: Text(
                                  p.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                                ),
                                subtitle: Text(
                                  '${p.patientId} • ${p.age} yrs • ${p.gender}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                              ),
                            );
                          },
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
