import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/core/utils/responsive.dart';
import 'package:clinicos/core/utils/validators.dart';
import 'package:clinicos/features/patients/controllers/patient_controller.dart';
import 'package:clinicos/models/patient.dart';

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
  final _emergencyNameController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();

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
    _emergencyNameController.dispose();
    _emergencyContactController.dispose();
    _emergencyRelationshipController.dispose();
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
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Patient Created',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
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
                  const Text('Patient ID', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(
                    patient.patientId,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Mobile: ${patient.mobile}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            if (patient.driveFolderId != null && patient.driveFolderId!.isNotEmpty) ...[
              const SizedBox(height: 6),
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
              Navigator.of(context).pop();
              widget.onPatientCreated(patient);
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
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('Creation Failed'),
          ],
        ),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.controller.isSaving;
    final isMobile = Responsive.isMobile(context);

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              padding: EdgeInsets.all(isMobile ? 18.0 : 28.0),
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
                    // Profile Photo Placeholder
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primarySurface,
                            child: const Icon(Icons.person, size: 40, color: AppColors.primary),
                          ),
                          const SizedBox(height: 6),
                          const Text('Profile Photo (Optional)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 1: Personal Information
                    _buildSectionHeader('Personal Information'),
                    const SizedBox(height: 16),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        hintText: 'e.g. Rahul Patel',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      ),
                      validator: (val) => Validators.validateRequired(val, 'Full Name'),
                    ),
                    const SizedBox(height: 14),

                    // Mobile Number
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number *',
                        hintText: 'e.g. 9876543210',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                      validator: Validators.validateMobile,
                    ),
                    const SizedBox(height: 14),

                    // DOB & Gender Row / Stack
                    if (isMobile) ...[
                      InkWell(
                        onTap: isSaving ? null : _selectDateOfBirth,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth *',
                            prefixIcon: Icon(Icons.calendar_month_outlined, size: 20),
                          ),
                          child: Text(
                            _selectedDob != null
                                ? DateFormat('dd MMM yyyy').format(_selectedDob!)
                                : 'Select DOB',
                            style: TextStyle(
                              color: _selectedDob != null ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender *',
                          prefixIcon: Icon(Icons.wc_outlined, size: 20),
                        ),
                        items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: isSaving ? null : (val) => setState(() => _selectedGender = val!),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: isSaving ? null : _selectDateOfBirth,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth *',
                                  prefixIcon: Icon(Icons.calendar_month_outlined, size: 20),
                                ),
                                child: Text(
                                  _selectedDob != null
                                      ? DateFormat('dd MMM yyyy').format(_selectedDob!)
                                      : 'Select DOB',
                                  style: TextStyle(
                                    color: _selectedDob != null ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender *',
                                prefixIcon: Icon(Icons.wc_outlined, size: 20),
                              ),
                              items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: isSaving ? null : (val) => setState(() => _selectedGender = val!),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Blood Group Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: const InputDecoration(
                        labelText: 'Blood Group',
                        prefixIcon: Icon(Icons.bloodtype_outlined, size: 20),
                      ),
                      hint: const Text('Select Blood Group'),
                      items: _bloodGroupOptions.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                      onChanged: isSaving ? null : (val) => setState(() => _selectedBloodGroup = val),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Contact Information
                    _buildSectionHeader('Contact Information'),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'e.g. rahul@example.com',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 14),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: 'Street address, city, pin code',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Emergency Contact
                    _buildSectionHeader('Emergency Contact'),
                    const SizedBox(height: 16),

                    // Emergency Contact Name
                    TextFormField(
                      controller: _emergencyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Name',
                        hintText: 'Relative / Guardian name',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Emergency Contact Number
                    TextFormField(
                      controller: _emergencyContactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        hintText: '10-digit phone number',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Relationship
                    TextFormField(
                      controller: _emergencyRelationshipController,
                      decoration: const InputDecoration(
                        labelText: 'Relationship',
                        hintText: 'e.g. Spouse, Father, Friend',
                        prefixIcon: Icon(Icons.family_restroom_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _handleSubmit,
                        child: isSaving
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Creating patient...'),
                                ],
                              )
                            : const Text(
                                'Create Patient',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
