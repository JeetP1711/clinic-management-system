import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/features/documents/controllers/document_controller.dart';
import 'package:clinicos/models/patient_document.dart';

class UploadDocumentModal extends StatefulWidget {
  final String patientId;
  final DocumentController controller;
  final List<String> availableVisits;

  const UploadDocumentModal({
    super.key,
    required this.patientId,
    required this.controller,
    this.availableVisits = const [],
  });

  @override
  State<UploadDocumentModal> createState() => _UploadDocumentModalState();
}

class _UploadDocumentModalState extends State<UploadDocumentModal> {
  File? _selectedFile;
  String? _fileName;
  String? _mimeType;
  int _fileSize = 0;

  String _selectedDocumentType = DocumentTypes.all.first;
  late DateTime _selectedDate;
  String? _selectedVisitId;
  final _notesController = TextEditingController();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        final file = File(photo.path);
        final size = await file.length();
        setState(() {
          _selectedFile = file;
          _fileName = 'Photo_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.jpg';
          _mimeType = 'image/jpeg';
          _fileSize = size;
          _selectedDocumentType = 'Patient Image';
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to capture photo: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final file = File(image.path);
        final size = await file.length();
        final ext = image.name.split('.').last.toLowerCase();
        final mime = ext == 'png'
            ? 'image/png'
            : ext == 'webp'
                ? 'image/webp'
                : 'image/jpeg';

        setState(() {
          _selectedFile = file;
          _fileName = image.name;
          _mimeType = mime;
          _fileSize = size;
          _selectedDocumentType = 'Patient Image';
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select image from gallery: $e';
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final file = File(platformFile.path!);
        final size = platformFile.size;
        final ext = (platformFile.extension ?? '').toLowerCase();

        String mime = 'application/octet-stream';
        String defaultDocType = 'Lab Report';

        if (ext == 'pdf') {
          mime = 'application/pdf';
          defaultDocType = 'Lab Report';
        } else if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
          mime = ext == 'png'
              ? 'image/png'
              : ext == 'webp'
                  ? 'image/webp'
                  : 'image/jpeg';
          defaultDocType = 'Patient Image';
        } else {
          setState(() {
            _errorMessage = 'This file type is not supported. Please select a PDF or image.';
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileName = platformFile.name;
          _mimeType = mime;
          _fileSize = size;
          _selectedDocumentType = defaultDocType;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select file: $e';
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null || _fileName == null || _mimeType == null) {
      setState(() {
        _errorMessage = 'Please select a file to upload';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.2;
      _errorMessage = null;
    });

    try {
      final bytes = await _selectedFile!.readAsBytes();
      setState(() {
        _uploadProgress = 0.5;
      });

      final base64String = base64Encode(bytes);
      setState(() {
        _uploadProgress = 0.7;
      });

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      await widget.controller.uploadDocument(
        patientId: widget.patientId,
        fileName: _fileName!,
        mimeType: _mimeType!,
        base64Data: base64String,
        documentType: _selectedDocumentType,
        documentDate: dateStr,
        relatedVisitId: _selectedVisitId,
        notes: _notesController.text.trim(),
        fileSize: _fileSize,
      );

      setState(() {
        _uploadProgress = 1.0;
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upload Document',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            if (_selectedFile == null) ...[
              const Text(
                'Select Source',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SourceTile(
                      icon: Icons.camera_alt_outlined,
                      label: 'Take Photo',
                      color: Colors.blue,
                      onTap: _pickFromCamera,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SourceTile(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      color: Colors.purple,
                      onTap: _pickFromGallery,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SourceTile(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Choose File',
                      color: Colors.orange,
                      onTap: _pickFile,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // File Selected Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _mimeType?.contains('pdf') == true
                            ? Icons.picture_as_pdf_rounded
                            : Icons.image_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName ?? 'Selected File',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(_fileSize / 1024).toStringAsFixed(1)} KB • ${_mimeType?.split('/').last.toUpperCase()}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                      tooltip: 'Change File',
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                          _fileName = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Form Controls
              DropdownButtonFormField<String>(
                value: _selectedDocumentType,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                ),
                items: DocumentTypes.all.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedDocumentType = val);
                  }
                },
              ),
              const SizedBox(height: 14),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Document Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 14),

              if (widget.availableVisits.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedVisitId,
                  decoration: const InputDecoration(
                    labelText: 'Related Visit (Optional)',
                    prefixIcon: Icon(Icons.medical_services_outlined, size: 20),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('None / General Document'),
                    ),
                    ...widget.availableVisits.map((vId) {
                      return DropdownMenuItem(
                        value: vId,
                        child: Text('Visit: $vId'),
                      );
                    }),
                  ],
                  onChanged: (val) => setState(() => _selectedVisitId = val),
                ),
                const SizedBox(height: 14),
              ],

              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.notes_outlined, size: 20),
                  hintText: 'Add clinical comments, findings, or notes...',
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_isUploading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Uploading to Google Drive & Syncing Database... (${(_uploadProgress * 100).toInt()}%)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ] else if (_selectedFile != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleUpload,
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('Upload to Google Drive'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
