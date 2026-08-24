import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/models/patient_document.dart';
import 'package:clinicos/services/document_service.dart';

class DocumentViewerScreen extends StatefulWidget {
  final PatientDocument document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  final DocumentService _service = DocumentService();
  File? _localFile;
  bool _isLoading = true;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final file = await _service.downloadAndCacheFile(
        widget.document.fileUrl,
        widget.document.fileName,
      );
      if (mounted) {
        setState(() {
          _localFile = file;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareFile() async {
    if (_localFile == null) return;
    try {
      final xfile = XFile(_localFile!.path);
      await Share.shareXFiles([xfile], text: widget.document.fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share document: $e')),
        );
      }
    }
  }

  Future<void> _openExternal() async {
    if (_localFile == null) return;
    try {
      await OpenFilex.open(_localFile!.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file externally: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc.fileName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${doc.documentType} • ${doc.formattedFileSize}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          if (_localFile != null) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share',
              onPressed: _shareFile,
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: 'Open in App',
              onPressed: _openExternal,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
            if (doc.isPdf && _localFile != null && _totalPages > 0)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 0
                              ? () {
                                  // Handled inside PDFView controller if needed
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages - 1
                              ? () {
                                  // Handled inside PDFView controller if needed
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Fetching document from Google Drive...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              widget.document.fileName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 14),
              const Text(
                'Unable to Load Document',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadFile,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Download'),
              ),
            ],
          ),
        ),
      );
    }

    if (_localFile == null) return const SizedBox.shrink();

    if (widget.document.isImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.file(
            _localFile!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Failed to render image'));
            },
          ),
        ),
      );
    }

    if (widget.document.isPdf) {
      return PDFView(
        filePath: _localFile!.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onRender: (pages) {
          setState(() {
            _totalPages = pages ?? 0;
          });
        },
        onPageChanged: (page, total) {
          setState(() {
            _currentPage = page ?? 0;
            _totalPages = total ?? 0;
          });
        },
        onError: (error) {
          setState(() {
            _error = error.toString();
          });
        },
      );
    }

    // Default fallback for other file formats
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.document.typeIcon, size: 64, color: widget.document.categoryColor),
          const SizedBox(height: 16),
          Text(
            widget.document.fileName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Format: ${widget.document.fileType.toUpperCase()} (${widget.document.formattedFileSize})',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openExternal,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open in Device Viewer'),
          ),
        ],
      ),
    );
  }
}
