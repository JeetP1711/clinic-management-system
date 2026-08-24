import 'package:flutter/material.dart';

class PatientDocument {
  final String documentId;
  final String patientId;
  final String fileName;
  final String fileType;
  final String mimeType;
  final String documentType;
  final String driveFileId;
  final String driveFolderId;
  final String fileUrl;
  final String documentDate;
  final String? relatedVisitId;
  final String? notes;
  final String uploadedBy;
  final String uploadedAt;
  final int fileSize;
  final String status;

  PatientDocument({
    required this.documentId,
    required this.patientId,
    required this.fileName,
    required this.fileType,
    required this.mimeType,
    required this.documentType,
    required this.driveFileId,
    required this.driveFolderId,
    required this.fileUrl,
    required this.documentDate,
    this.relatedVisitId,
    this.notes,
    this.uploadedBy = 'Dr. Jeet Patel',
    required this.uploadedAt,
    this.fileSize = 0,
    this.status = 'Active',
  });

  bool get isPdf =>
      mimeType.toLowerCase().contains('pdf') ||
      fileName.toLowerCase().endsWith('.pdf') ||
      fileType.toLowerCase() == 'pdf';

  bool get isImage =>
      mimeType.toLowerCase().startsWith('image/') ||
      ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(fileType.toLowerCase()) ||
      ['.jpg', '.jpeg', '.png', '.webp'].any((ext) => fileName.toLowerCase().endsWith(ext));

  String get formattedFileSize {
    if (fileSize <= 0) return 'Unknown size';
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData get typeIcon {
    if (isPdf) return Icons.picture_as_pdf_rounded;
    if (isImage) return Icons.image_rounded;
    switch (documentType) {
      case 'Lab Report':
      case 'Blood Test':
        return Icons.science_rounded;
      case 'X-Ray':
      case 'MRI':
      case 'CT Scan':
      case 'Ultrasound':
        return Icons.document_scanner_rounded;
      case 'Prescription':
        return Icons.receipt_long_rounded;
      case 'ECG':
        return Icons.monitor_heart_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get categoryColor {
    if (isPdf) return Colors.red.shade700;
    if (isImage) return Colors.teal;
    switch (documentType) {
      case 'Lab Report':
      case 'Blood Test':
        return Colors.indigo;
      case 'Prescription':
        return Colors.green.shade700;
      case 'X-Ray':
      case 'MRI':
      case 'CT Scan':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  factory PatientDocument.fromJson(Map<String, dynamic> json) {
    return PatientDocument(
      documentId: json['document_id'] ?? json['documentId'] ?? '',
      patientId: json['patient_id'] ?? json['patientId'] ?? '',
      fileName: json['file_name'] ?? json['fileName'] ?? 'Document',
      fileType: json['file_type'] ?? json['fileType'] ?? '',
      mimeType: json['mime_type'] ?? json['mimeType'] ?? '',
      documentType: json['document_type'] ?? json['documentType'] ?? 'Other',
      driveFileId: json['drive_file_id'] ?? json['driveFileId'] ?? '',
      driveFolderId: json['drive_folder_id'] ?? json['driveFolderId'] ?? '',
      fileUrl: json['file_url'] ?? json['fileUrl'] ?? '',
      documentDate: json['document_date'] ?? json['documentDate'] ?? '',
      relatedVisitId: json['related_visit_id'] ?? json['relatedVisitId'],
      notes: json['notes'],
      uploadedBy: json['uploaded_by'] ?? json['uploadedBy'] ?? 'Dr. Jeet Patel',
      uploadedAt: json['uploaded_at'] ?? json['uploadedAt'] ?? '',
      fileSize: int.tryParse(json['file_size']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'patient_id': patientId,
      'file_name': fileName,
      'file_type': fileType,
      'mime_type': mimeType,
      'document_type': documentType,
      'drive_file_id': driveFileId,
      'drive_folder_id': driveFolderId,
      'file_url': fileUrl,
      'document_date': documentDate,
      'related_visit_id': relatedVisitId ?? '',
      'notes': notes ?? '',
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt,
      'file_size': fileSize,
      'status': status,
    };
  }
}

class DocumentTypes {
  static const List<String> all = [
    'Lab Report',
    'X-Ray',
    'MRI',
    'CT Scan',
    'Ultrasound',
    'ECG',
    'Blood Test',
    'Prescription',
    'Discharge Summary',
    'Medical Certificate',
    'Insurance Document',
    'Referral Letter',
    'Doctor Note',
    'Patient Image',
    'Other',
  ];
}
