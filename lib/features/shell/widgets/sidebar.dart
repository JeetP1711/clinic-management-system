import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<Map<String, dynamic>> _navItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard_rounded},
    {'title': 'Patients', 'icon': Icons.people_outline_rounded, 'activeIcon': Icons.people_rounded},
    {'title': 'Appointments', 'icon': Icons.calendar_today_outlined, 'activeIcon': Icons.calendar_today_rounded},
    {'title': 'Queue', 'icon': Icons.hourglass_empty_outlined, 'activeIcon': Icons.hourglass_full_rounded},
    {'title': 'Visits', 'icon': Icons.medical_information_outlined, 'activeIcon': Icons.medical_information_rounded},
    {'title': 'Prescriptions', 'icon': Icons.description_outlined, 'activeIcon': Icons.description_rounded},
    {'title': 'Documents', 'icon': Icons.folder_outlined, 'activeIcon': Icons.folder_rounded},
    {'title': 'Billing', 'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long_rounded},
    {'title': 'Settings', 'icon': Icons.settings_outlined, 'activeIcon': Icons.settings_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // ClinicOS Logo Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ClinicOS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const Text(
                      'Clinic Workspace',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: AppColors.primarySurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: Icon(
                      isSelected ? item['activeIcon'] : item['icon'],
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => onItemSelected(index),
                  ),
                );
              },
            ),
          ),

          // User Footer
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySurface,
                  child: const Text(
                    'DR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Admin',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'General Physician',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
