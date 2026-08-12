import '../models/patient.dart';
import 'api_service.dart';

class PatientService {
  final ApiService _api;

  PatientService({ApiService? apiService}) : _api = apiService ?? ApiService();

  Future<ApiResponse> createPatient({
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
    return await _api.post('createPatient', {
      'full_name': fullName.trim(),
      'mobile': mobile.trim(),
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'blood_group': bloodGroup?.trim() ?? '',
      'email': email?.trim() ?? '',
      'address': address?.trim() ?? '',
      'emergency_contact': emergencyContact?.trim() ?? '',
      'emergency_contact_name': emergencyContactName?.trim() ?? '',
    });
  }

  Future<List<Patient>> getPatients() async {
    final response = await _api.get('getPatients');
    if (response.success && response.data != null) {
      final List<dynamic> list = response.data;
      return list.map((json) => Patient.fromJson(json)).toList();
    }
    return [];
  }

  Future<Patient?> getPatient(String id) async {
    final response = await _api.get('getPatient', {'patient_id': id});
    if (response.success && response.data != null) {
      return Patient.fromJson(response.data);
    }
    return null;
  }

  Future<List<Patient>> searchPatients(String query) async {
    final response = await _api.get('searchPatients', {'query': query});
    if (response.success && response.data != null) {
      final List<dynamic> list = response.data;
      return list.map((json) => Patient.fromJson(json)).toList();
    }
    return [];
  }
}
