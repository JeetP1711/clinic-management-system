import 'dart:convert';
import 'dart:io';
import 'package:clinicos/models/patient_document.dart';
import 'package:clinicos/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DocumentService {
  final ApiService _apiService;

  DocumentService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<PatientDocument>> getPatientDocuments(String patientId) async {
    final response = await _apiService.get('getPatientDocuments', {
      'patient_id': patientId,
    });

    if (response.success && response.data != null) {
      final List list = response.data as List;
      return list.map((json) => PatientDocument.fromJson(json)).toList();
    } else {
      throw Exception(response.message);
    }
  }

  Future<PatientDocument> uploadDocument({
    required String patientId,
    required String fileName,
    required String mimeType,
    required String base64Data,
    required String documentType,
    required String documentDate,
    String? relatedVisitId,
    String? notes,
    int? fileSize,
    String? uploadedBy,
  }) async {
    final response = await _apiService.post('uploadDocument', {
      'patient_id': patientId,
      'file_name': fileName,
      'mime_type': mimeType,
      'file_data': base64Data,
      'document_type': documentType,
      'document_date': documentDate,
      'related_visit_id': relatedVisitId ?? '',
      'notes': notes ?? '',
      'file_size': fileSize ?? 0,
      'uploaded_by': uploadedBy ?? 'Dr. Jeet Patel',
    });

    if (response.success && response.data != null) {
      return PatientDocument.fromJson(response.data);
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> updateDocument({
    required String documentId,
    String? documentType,
    String? documentDate,
    String? relatedVisitId,
    String? notes,
  }) async {
    final response = await _apiService.post('updateDocument', {
      'document_id': documentId,
      if (documentType != null) 'document_type': documentType,
      if (documentDate != null) 'document_date': documentDate,
      if (relatedVisitId != null) 'related_visit_id': relatedVisitId,
      if (notes != null) 'notes': notes,
    });

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final response = await _apiService.post('deleteDocument', {
      'document_id': documentId,
    });

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<Map<String, dynamic>> getDocument(String documentId) async {
    final response = await _apiService.get('getDocument', {
      'document_id': documentId,
    });

    if (response.success && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    } else {
      throw Exception(response.message);
    }
  }

  Future<File> downloadAndCacheFile(String url, String fileName, {String? documentId}) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    // 1. Try direct Google Drive download URL
    String downloadUrl = url;
    if (url.contains('drive.google.com/file/d/')) {
      final matches = RegExp(r'/file/d/([^/]+)').firstMatch(url);
      if (matches != null && matches.groupCount >= 1) {
        final fileId = matches.group(1);
        downloadUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }

    try {
      if (downloadUrl.isNotEmpty && downloadUrl.startsWith('http')) {
        final response = await http.get(Uri.parse(downloadUrl)).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          await file.writeAsBytes(response.bodyBytes);
          return file;
        }
      }
    } catch (_) {
      // Fallthrough to backend proxy fallback below
    }

    // 2. Fallback: fetch binary file_data via Apps Script proxy if documentId provided
    if (documentId != null && documentId.isNotEmpty) {
      final data = await getDocument(documentId);
      final base64Str = data['file_data']?.toString();
      if (base64Str != null && base64Str.isNotEmpty) {
        final bytes = base64Decode(base64Str);
        await file.writeAsBytes(bytes);
        return file;
      }
    }

    throw Exception('Failed to download document file. Please check network connection.');
  }
}

