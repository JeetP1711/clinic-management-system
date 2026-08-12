import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/core/utils/responsive.dart';
import 'package:clinicos/features/dashboard/widgets/stat_card.dart';
import 'package:clinicos/features/patients/controllers/patient_controller.dart';

class DashboardScreen extends StatelessWidget {
  final PatientController patientController;
  final Function(int) onNavigate;

  const DashboardScreen({
    super.key,
    required this.patientController,
    required this.onNavigate,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ListenableBuilder(
          listenable: patientController,
          builder: (context, _) {
            final patientCount = patientController.totalCount.toString();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here is what is happening at your clinic today.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => onNavigate(1), // Navigate to Patients tab
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('+ Add Patient'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Today's Overview Section Title
                Text(
                  "Today's Overview",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 16),

                // Stat Cards Grid
                Responsive(
                  mobile: Column(
                    children: [
                      StatCard(
                        title: 'Patients',
                        value: patientCount,
                        icon: Icons.people_outline_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primarySurface,
                      ),
                      const SizedBox(height: 12),
                      const StatCard(
                        title: 'Appointments',
                        value: '0',
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.info,
                        iconBgColor: AppColors.infoBackground,
                      ),
                      const SizedBox(height: 12),
                      const StatCard(
                        title: 'Waiting',
                        value: '0',
                        icon: Icons.hourglass_empty_rounded,
                        iconColor: AppColors.warning,
                        iconBgColor: AppColors.warningBackground,
                      ),
                      const SizedBox(height: 12),
                      const StatCard(
                        title: 'Completed',
                        value: '0',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: AppColors.success,
                        iconBgColor: AppColors.successBackground,
                      ),
                    ],
                  ),
                  desktop: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
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
                        value: '0',
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.info,
                        iconBgColor: AppColors.infoBackground,
                      ),
                      const StatCard(
                        title: 'Waiting',
                        value: '0',
                        icon: Icons.hourglass_empty_rounded,
                        iconColor: AppColors.warning,
                        iconBgColor: AppColors.warningBackground,
                      ),
                      const StatCard(
                        title: 'Completed',
                        value: '0',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: AppColors.success,
                        iconBgColor: AppColors.successBackground,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Quick Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ClinicOS Milestone 1 Operational',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Patient records are permanently connected to Google Sheets & Drive.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
