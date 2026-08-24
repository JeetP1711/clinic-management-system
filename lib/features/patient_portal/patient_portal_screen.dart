import 'package:flutter/material.dart';
import 'package:clinicos/core/theme/app_colors.dart';
import 'package:clinicos/features/documents/controllers/document_controller.dart';
import 'package:clinicos/features/documents/widgets/document_card.dart';
import 'package:clinicos/models/patient.dart';

class PatientPortalScreen extends StatefulWidget {
  final Patient patient;
  final VoidCallback onLogout;

  const PatientPortalScreen({
    super.key,
    required this.patient,
    required this.onLogout,
  });

  @override
  State<PatientPortalScreen> createState() => _PatientPortalScreenState();
}

class _PatientPortalScreenState extends State<PatientPortalScreen> {
  late DocumentController _controller;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Patient Portal • ${patient.patientId}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout Patient',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.folder_shared_rounded), label: 'My Documents'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Medical History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildDocumentsSection(),
          _buildHistorySection(),
          _buildProfileSection(),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: () => _controller.fetchDocuments(widget.patient.patientId),
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Secure Patient Health Portal. Access & view your official medical reports.',
                        style: TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => _controller.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search my documents...',
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
                  const SizedBox(width: 8),
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
                      const PopupMenuItem(value: DocumentSortOption.newest, child: Text('Newest First')),
                      const PopupMenuItem(value: DocumentSortOption.oldest, child: Text('Oldest First')),
                      const PopupMenuItem(value: DocumentSortOption.nameAsc, child: Text('Name A-Z')),
                      const PopupMenuItem(value: DocumentSortOption.sizeDesc, child: Text('Largest File')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Categories
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
                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                        onSelected: (_) => _controller.setCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Document list
              if (_controller.isLoading) ...[
                const SizedBox(height: 40),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Retrieving your medical records...', style: TextStyle(color: AppColors.textSecondary)),
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
                      const Text('Unable to fetch documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(_controller.error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _controller.fetchDocuments(widget.patient.patientId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ] else if (_controller.documents.isEmpty) ...[
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 48, color: AppColors.primary),
                      const SizedBox(height: 16),
                      const Text('No documents available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('Your clinic reports will appear here once uploaded by your doctor.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                      isPatientPortal: true,
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistorySection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Medical History & Visits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Registration Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(widget.patient.createdAt.isNotEmpty ? widget.patient.createdAt : 'Registered', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Patient ID: ${widget.patient.patientId}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('Drive Vault Active: ${widget.patient.driveFolderId ?? "Linked"}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    final patient = widget.patient;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  patient.fullName.isNotEmpty ? patient.fullName[0].toUpperCase() : 'P',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text('ID: ${patient.patientId}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _profileRow('Mobile', patient.mobile),
              _profileRow('Date of Birth', patient.dateOfBirth),
              _profileRow('Gender', patient.gender),
              _profileRow('Blood Group', patient.bloodGroup ?? 'Not specified'),
              _profileRow('Email', patient.email ?? 'Not specified'),
              _profileRow('Emergency Contact', patient.emergencyContact ?? 'Not specified'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          label: const Text('Exit Patient Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _profileRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
