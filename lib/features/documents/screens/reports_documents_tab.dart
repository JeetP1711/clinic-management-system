import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/features/documents/controllers/document_controller.dart';
import 'package:clinicos/features/documents/widgets/document_card.dart';
import 'package:clinicos/features/documents/widgets/upload_document_modal.dart';
import 'package:clinicos/models/patient.dart';

class ReportsDocumentsTab extends StatefulWidget {
  final Patient patient;

  const ReportsDocumentsTab({super.key, required this.patient});

  @override
  State<ReportsDocumentsTab> createState() => _ReportsDocumentsTabState();
}

class _ReportsDocumentsTabState extends State<ReportsDocumentsTab> {
  late DocumentController _controller;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Reports',
    'Images',
    'Prescriptions',
    'Documents',
  ];

  @override
  void initState() {
    super.initState();
    _controller = DocumentController();
    _controller.fetchDocuments(widget.patient.patientId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openUploadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UploadDocumentModal(
        patientId: widget.patient.patientId,
        controller: _controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openUploadModal,
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
            label: const Text('Upload', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: RefreshIndicator(
            onRefresh: () => _controller.fetchDocuments(widget.patient.patientId),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top Search & Sort Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => _controller.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search documents...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _controller.setSearchQuery('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<DocumentSortOption>(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.sort_rounded, color: AppColors.textSecondary, size: 20),
                      ),
                      tooltip: 'Sort Documents',
                      onSelected: (option) => _controller.setSortOption(option),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: DocumentSortOption.newest,
                          child: Text('Newest First'),
                        ),
                        const PopupMenuItem(
                          value: DocumentSortOption.oldest,
                          child: Text('Oldest First'),
                        ),
                        const PopupMenuItem(
                          value: DocumentSortOption.nameAsc,
                          child: Text('Name A-Z'),
                        ),
                        const PopupMenuItem(
                          value: DocumentSortOption.nameDesc,
                          child: Text('Name Z-A'),
                        ),
                        const PopupMenuItem(
                          value: DocumentSortOption.sizeDesc,
                          child: Text('Largest File'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Horizontal Category Badges
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _controller.selectedCategory == cat;
                      final count = _controller.getCategoryCount(cat);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('$cat ($count)'),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          onSelected: (_) => _controller.setCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Main Content State
                if (_controller.isLoading) ...[
                  const SizedBox(height: 40),
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Loading patient documents from Drive...', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ] else if (_controller.error != null) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.error),
                        const SizedBox(height: 12),
                        const Text('Unable to Load Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(_controller.error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _controller.fetchDocuments(widget.patient.patientId),
                          child: const Text('Retry Synchronization'),
                        ),
                      ],
                    ),
                  ),
                ] else if (_controller.documents.isEmpty) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.folder_open_rounded, size: 48, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No documents found matching "${_searchController.text}"'
                              : 'No ${_controller.selectedCategory.toLowerCase()} uploaded yet',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Upload PDFs, X-Rays, Lab Reports, or photos to Google Drive.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _openUploadModal,
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: const Text('+ Upload First Document'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.documents.length,
                    itemBuilder: (context, index) {
                      final doc = _controller.documents[index];
                      return DocumentCard(
                        document: doc,
                        controller: _controller,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
