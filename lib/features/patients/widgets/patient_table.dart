import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/models/patient.dart';

class PatientTable extends StatelessWidget {
  final List<Patient> patients;
  final Function(Patient) onPatientTap;

  const PatientTable({
    super.key,
    required this.patients,
    required this.onPatientTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.surfaceVariant),
          dataRowHeight: 64,
          headingRowHeight: 48,
          horizontalMargin: 20,
          columnSpacing: 24,
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Patient ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: patients.map((patient) {
            return DataRow(
              onSelectChanged: (_) => onPatientTap(patient),
              cells: [
                DataCell(
                  Text(
                    patient.patientId,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    patient.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(patient.mobile)),
                DataCell(Text('${patient.age} yrs')),
                DataCell(Text(patient.gender)),
                DataCell(Text(patient.createdAt.split('T').first)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: patient.status == 'Active'
                          ? AppColors.successBackground
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      patient.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: patient.status == 'Active'
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
