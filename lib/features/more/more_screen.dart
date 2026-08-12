import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const MoreScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final List<_MoreMenuItem> menuItems = [
      _MoreMenuItem(title: 'Queue', icon: Icons.queue_play_next_rounded, color: Colors.blue, navIndex: 3),
      _MoreMenuItem(title: 'Visits', icon: Icons.medical_services_outlined, color: Colors.indigo, navIndex: 4),
      _MoreMenuItem(title: 'Prescriptions', icon: Icons.description_outlined, color: Colors.teal, navIndex: 5),
      _MoreMenuItem(title: 'Reports & Docs', icon: Icons.folder_shared_outlined, color: Colors.amber.shade800, navIndex: 6),
      _MoreMenuItem(title: 'Inventory', icon: Icons.inventory_2_outlined, color: Colors.purple, navIndex: 8),
      _MoreMenuItem(title: 'Notifications', icon: Icons.notifications_none_rounded, color: Colors.orange, navIndex: 9),
      _MoreMenuItem(title: 'Settings', icon: Icons.settings_outlined, color: Colors.blueGrey, navIndex: 10),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('More Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: AppColors.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: const Icon(Icons.medical_information, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text(
                          'Clinic Management Hub',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Access all clinical tools & features',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return InkWell(
                  onTap: () => onNavigate(item.navIndex),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon, color: item.color, size: 22),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final int navIndex;

  _MoreMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.navIndex,
  });
}
