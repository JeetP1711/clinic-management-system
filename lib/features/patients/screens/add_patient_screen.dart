import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../controllers/patient_controller.dart';
import '../../../models/patient.dart';

class AddPatientScreen extends StatefulWidget {
  final PatientController controller;
  final Function(Patient) onPatientCreated;

  const AddPatientScreen({
    super.key,
    required this.controller,
    required this.onPatientCreated,
  });

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Field Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyNameController = TextEditingController();

  DateTime? _selectedDob;
  String _selectedGender = 'Male';
  String? _selectedBloodGroup;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDob ?? DateTime(now.year - 30);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Date of Birth'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final dobString = DateFormat('yyyy-MM-dd').format(_selectedDob!);

    final newPatient = await widget.controller.createPatient(
      fullName: _nameController.text,
      mobile: _mobileController.text,
      dateOfBirth: dobString,
      gender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      emergencyContact:
          _emergencyContactController.text.isNotEmpty ? _emergencyContactController.text : null,
      emergencyContactName:
          _emergencyNameController.text.isNotEmpty ? _emergencyNameController.text : null,
    );

    if (!mounted) return;

    if (newPatient != null) {
      _showSuccessDialog(newPatient);
    } else {
      final errorMsg = widget.controller.error ?? 'Unable to create patient. Please try again.';
      _showErrorDialog(errorMsg);
    }
  }

  void _showSuccessDialog(Patient patient) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.successBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('Patient Created'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.fullName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Patient ID',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  Text(
                    patient.patientId,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mobile: ${patient.mobile}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (patient.driveFolderId != null && patient.driveFolderId!.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                '✓ Google Drive Folder Created',
                style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              widget.onPatientCreated(patient); // Navigate to detail or back
            },
            child: const Text('View Patient Profile'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.errorBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('Patient Creation Failed'),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.controller.isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        title: const Text(
          'Add New Patient',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        scaffoldModeBanner: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            maxWidth: 700,
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Required Section Header
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Required Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'e.g. Rahul Patel',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (val) => Validators.validateRequired(val, 'Full Name'),
                  ),
                  const SizedBox(height: 16),

                  // Mobile Number
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number *',
                      hintText: 'e.g. 9876543210',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validators.validateMobile,
                  ),
                  const SizedBox(height: 16),

                  // DOB & Gender Row
                  Row(
                    children: [
                      // Date of Birth
                      Expanded(
                        child: InkWell(
                          onTap: isSaving ? null : _selectDateOfBirth,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth *',
                              prefixIcon: Icon(Icons.calendar_month_outlined),
                            ),
                            child: Text(
                              _selectedDob != null
                                  ? DateFormat('dd MMM yyyy').format(_selectedDob!)
                                  : 'Select DOB',
                              style: TextStyle(
                                color: _selectedDob != null
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Gender Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender *',
                            prefixIcon: Icon(Icons.wc_outlined),
                          ),
                          items: _genderOptions
                              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: isSaving
                              ? null
                              : (val) {
                                  if (val != null) setState(() => _selectedGender = val);
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Optional Section Header
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Optional Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Blood Group & Email Row
                  Row(
                    children: [
                      // Blood Group
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedBloodGroup,
                          decoration: const InputDecoration(
                            labelText: 'Blood Group',
                            prefixIcon: Icon(Icons.bloodtype_outlined),
                          ),
                          hint: const Text('Select'),
                          items: _bloodGroupOptions
                              .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                              .toList(),
                          onChanged: isSaving
                              ? null
                              : (val) => setState(() => _selectedBloodGroup = val),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Email
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'e.g. rahul@example.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: Validators.validateEmail,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Residential Address',
                      hintText: 'Street address, city, pin code',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Emergency Contact Name & Number
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emergencyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Emergency Contact Name',
                            hintText: 'Relative / Guardian name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emergencyContactController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Emergency Contact Phone',
                            hintText: '10-digit number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _handleSubmit,
                      child: isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Creating patient...'),
                              ],
                            )
                          : const Text(
                              'Create Patient',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
