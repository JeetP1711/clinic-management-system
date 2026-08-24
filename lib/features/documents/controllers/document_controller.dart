import 'package:flutter/material.dart';
import 'package:clinicos/models/patient_document.dart';
import 'package:clinicos/services/document_service.dart';

enum DocumentSortOption { newest, oldest, nameAsc, nameDesc, sizeDesc, sizeAsc }
enum DateRangeFilterOption { all, today, thisWeek, thisMonth, custom }

class DocumentController extends ChangeNotifier {
  final DocumentService _service;

  List<PatientDocument> _allDocuments = [];
  List<PatientDocument> _filteredDocuments = [];

  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  DocumentSortOption _sortOption = DocumentSortOption.newest;
  DateRangeFilterOption _dateFilterOption = DateRangeFilterOption.all;
  DateTimeRange? _customDateRange;

  DocumentController({DocumentService? service})
      : _service = service ?? DocumentService();

  List<PatientDocument> get documents => _filteredDocuments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  DocumentSortOption get sortOption => _sortOption;
  DateRangeFilterOption get dateFilterOption => _dateFilterOption;
  DateTimeRange? get customDateRange => _customDateRange;

  int get totalCount => _allDocuments.length;

  int getCategoryCount(String category) {
    if (category == 'All') return _allDocuments.length;
    if (category == 'Reports') {
      return _allDocuments
          .where((d) =>
              ['Lab Report', 'Blood Test', 'ECG', 'Other medical reports'].contains(d.documentType) ||
              d.isPdf)
          .length;
    }
    if (category == 'Images') {
      return _allDocuments
          .where((d) =>
              ['Patient Image', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound'].contains(d.documentType) ||
              d.isImage)
          .length;
    }
    if (category == 'Prescriptions') {
      return _allDocuments.where((d) => d.documentType == 'Prescription').length;
    }
    if (category == 'Documents') {
      return _allDocuments
          .where((d) =>
              !['Lab Report', 'Blood Test', 'ECG', 'Prescription', 'Patient Image', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound'].contains(d.documentType) &&
              !d.isImage)
          .length;
    }
    return _allDocuments.where((d) => d.documentType == category).length;
  }

  Future<void> fetchDocuments(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allDocuments = await _service.getPatientDocuments(patientId);
      _applyFilterAndSort();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilterAndSort();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilterAndSort();
    notifyListeners();
  }

  void setSortOption(DocumentSortOption option) {
    _sortOption = option;
    _applyFilterAndSort();
    notifyListeners();
  }

  void _applyFilterAndSort() {
    List<PatientDocument> result = List.from(_allDocuments);

    // Filter by category tab
    if (_selectedCategory != 'All') {
      if (_selectedCategory == 'Reports') {
        result = result
            .where((d) =>
                ['Lab Report', 'Blood Test', 'ECG', 'Other medical reports'].contains(d.documentType) ||
                d.isPdf)
            .toList();
      } else if (_selectedCategory == 'Images') {
        result = result
            .where((d) =>
                ['Patient Image', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound'].contains(d.documentType) ||
                d.isImage)
            .toList();
      } else if (_selectedCategory == 'Prescriptions') {
        result = result.where((d) => d.documentType == 'Prescription').toList();
      } else if (_selectedCategory == 'Documents') {
        result = result
            .where((d) =>
                !['Lab Report', 'Blood Test', 'ECG', 'Prescription', 'Patient Image', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound'].contains(d.documentType) &&
                !d.isImage)
            .toList();
      } else {
        result = result.where((d) => d.documentType == _selectedCategory).toList();
      }
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((d) {
        return d.fileName.toLowerCase().contains(q) ||
            d.documentType.toLowerCase().contains(q) ||
            d.documentId.toLowerCase().contains(q) ||
            (d.notes != null && d.notes!.toLowerCase().contains(q));
      }).toList();
    }

    // Sort
    switch (_sortOption) {
      case DocumentSortOption.newest:
        result.sort((a, b) => b.documentDate.compareTo(a.documentDate));
        break;
      case DocumentSortOption.oldest:
        result.sort((a, b) => a.documentDate.compareTo(b.documentDate));
        break;
      case DocumentSortOption.nameAsc:
        result.sort((a, b) => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
        break;
      case DocumentSortOption.nameDesc:
        result.sort((a, b) => b.fileName.toLowerCase().compareTo(a.fileName.toLowerCase()));
        break;
      case DocumentSortOption.sizeDesc:
        result.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case DocumentSortOption.sizeAsc:
        result.sort((a, b) => a.fileSize.compareTo(b.fileSize));
        break;
    }

    _filteredDocuments = result;
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
  }) async {
    final doc = await _service.uploadDocument(
      patientId: patientId,
      fileName: fileName,
      mimeType: mimeType,
      base64Data: base64Data,
      documentType: documentType,
      documentDate: documentDate,
      relatedVisitId: relatedVisitId,
      notes: notes,
      fileSize: fileSize,
    );

    _allDocuments.insert(0, doc);
    _applyFilterAndSort();
    notifyListeners();
    return doc;
  }

  Future<void> updateDocument({
    required String documentId,
    String? documentType,
    String? documentDate,
    String? relatedVisitId,
    String? notes,
  }) async {
    await _service.updateDocument(
      documentId: documentId,
      documentType: documentType,
      documentDate: documentDate,
      relatedVisitId: relatedVisitId,
      notes: notes,
    );

    final index = _allDocuments.indexWhere((d) => d.documentId == documentId);
    if (index != -1) {
      final old = _allDocuments[index];
      _allDocuments[index] = PatientDocument(
        documentId: old.documentId,
        patientId: old.patientId,
        fileName: old.fileName,
        fileType: old.fileType,
        mimeType: old.mimeType,
        documentType: documentType ?? old.documentType,
        driveFileId: old.driveFileId,
        driveFolderId: old.driveFolderId,
        fileUrl: old.fileUrl,
        documentDate: documentDate ?? old.documentDate,
        relatedVisitId: relatedVisitId ?? old.relatedVisitId,
        notes: notes ?? old.notes,
        uploadedBy: old.uploadedBy,
        uploadedAt: old.uploadedAt,
        fileSize: old.fileSize,
        status: old.status,
      );
      _applyFilterAndSort();
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String documentId) async {
    await _service.deleteDocument(documentId);
    _allDocuments.removeWhere((d) => d.documentId == documentId);
    _applyFilterAndSort();
    notifyListeners();
  }
}
