class Patient {
  final String patientId;
  final String fullName;
  final String mobile;
  final String dateOfBirth; // YYYY-MM-DD
  final String gender;
  final String? bloodGroup;
  final String? email;
  final String? address;
  final String? emergencyContact;
  final String? emergencyContactName;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? driveFolderId;

  Patient({
    required this.patientId,
    required this.fullName,
    required this.mobile,
    required this.dateOfBirth,
    required this.gender,
    this.bloodGroup,
    this.email,
    this.address,
    this.emergencyContact,
    this.emergencyContactName,
    this.status = 'Active',
    required this.createdAt,
    required this.updatedAt,
    this.driveFolderId,
  });

  int get age {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age < 0 ? 0 : age;
    } catch (_) {
      return 0;
    }
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patient_id'] ?? json['patientId'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      mobile: json['mobile']?.toString() ?? '',
      dateOfBirth: json['date_of_birth'] ?? json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      bloodGroup: json['blood_group'] ?? json['bloodGroup'],
      email: json['email'],
      address: json['address'],
      emergencyContact: json['emergency_contact']?.toString() ?? json['emergencyContact']?.toString(),
      emergencyContactName: json['emergency_contact_name'] ?? json['emergencyContactName'],
      status: json['status'] ?? 'Active',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      updatedAt: json['updated_at'] ?? json['updatedAt'] ?? '',
      driveFolderId: json['drive_folder_id'] ?? json['driveFolderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'full_name': fullName,
      'mobile': mobile,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'blood_group': bloodGroup ?? '',
      'email': email ?? '',
      'address': address ?? '',
      'emergency_contact': emergencyContact ?? '',
      'emergency_contact_name': emergencyContactName ?? '',
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'drive_folder_id': driveFolderId ?? '',
    };
  }
}
