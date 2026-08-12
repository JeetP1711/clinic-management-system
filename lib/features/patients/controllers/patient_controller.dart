import 'package:flutter/material.dart';
import '../../../models/patient.dart';
import '../../../services/patient_service.dart';

class PatientController extends ChangeNotifier {
  final PatientService _patientService;

  List<Patient> _patients = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String _searchQuery = '';

  PatientController({PatientService? patientService})
      : _patientService = patientService ?? PatientService();

  List<Patient> get patients {
    if (_searchQuery.trim().isEmpty) return _patients;
    final q = _searchQuery.toLowerCase().trim();
    return _patients.where((p) {
      return p.patientId.toLowerCase().contains(q) ||
          p.fullName.toLowerCase().contains(q) ||
          p.mobile.contains(q);
    }).toList();
  }

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  int get totalCount => _patients.length;

  Future<void> fetchPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _patients = await _patientService.getPatients();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Patient?> createPatient({
    required String fullName,
    required String mobile,
    required String dateOfBirth,
    required String gender,
    String? bloodGroup,
    String? email,
    String? address,
    String? emergencyContact,
    String? emergencyContactName,
  }) async {
    if (_isSaving) return null; // Prevent double submit

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _patientService.createPatient(
        fullName: fullName,
        mobile: mobile,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodGroup: bloodGroup,
        email: email,
        address: address,
        emergencyContact: emergencyContact,
        emergencyContactName: emergencyContactName,
      );

      if (res.success && res.data != null) {
        final newPatient = Patient.fromJson(res.data);
        _patients.insert(0, newPatient);
        return newPatient;
      } else {
        _error = res.message;
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
