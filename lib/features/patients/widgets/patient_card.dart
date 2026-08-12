import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      patient.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: patient.status == 'Active'
                          ? AppColors.successBackground
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      patient.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: patient.status == 'Active'
                                ? AppColors.success
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                patient.patientId,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    patient.mobile,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    '${patient.age} Years • ${patient.gender}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
