import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:reminderx_mobile/core/theme.dart';
import '../features/documents/models/particular_model.dart';
import 'package:intl/intl.dart';
import '../features/documents/screens/document_view_page.dart';
import 'dart:io';
import '../features/documents/screens/edit_document.dart';
import 'package:path/path.dart' as path;
import 'package:pdfrx/pdfrx.dart';

class DocumentList extends StatefulWidget {
  final Isar? isar;
  final bool showTabs;

  const DocumentList({super.key, this.isar, this.showTabs = true});

  @override
  State<DocumentList> createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedTab = 'All';
            break;
          case 1:
            _selectedTab = 'Expiring Soon';
            break;
          case 2:
            _selectedTab = 'Up to Date';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            widget.isar == null
                ? 'Database not connected'
                : 'No documents here',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isar == null
                ? 'Please check your connection and try again'
                : 'Click the add button above to add documents',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showTabs)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(child: Center(child: Text('All'))),
                Tab(child: Center(child: Text('Expiring Soon'))),
                Tab(child: Center(child: Text('Up to Date'))),
              ],
              isScrollable: false,
            ),
          ),
        Expanded(
          child:
              widget.isar == null
                  ? _buildEmptyState()
                  : StreamBuilder<List<Particular>>(
                    stream: widget.isar!.particulars.where().watch(
                      fireImmediately: true,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final particulars = snapshot.data!;
                      final now = DateTime.now();
                      final thirtyDaysFromNow = now.add(
                        const Duration(days: 30),
                      );

                      final filteredParticulars =
                          particulars.where((p) {
                            if (_selectedTab == 'All') return true;
                            if (_selectedTab == 'Expiring Soon') {
                              return p.expiryDate.isAfter(now) &&
                                  p.expiryDate.isBefore(thirtyDaysFromNow);
                            }
                            if (_selectedTab == 'Up to Date') {
                              return p.expiryDate.isAfter(thirtyDaysFromNow);
                            }
                            return true;
                          }).toList();

                      if (filteredParticulars.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredParticulars.length,
                        itemBuilder: (context, index) {
                          final particular = filteredParticulars[index];
                          final isExpiringSoon =
                              particular.expiryDate.isAfter(now) &&
                              particular.expiryDate.isBefore(thirtyDaysFromNow);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Document Image/Icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _buildDocumentPreview(particular),
                                  ),
                                  const SizedBox(width: 12),
                                  // Document Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          particular.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isExpiringSoon
                                                    ? Colors.red[50]
                                                    : Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'Expires: ${DateFormat('MMM dd, yyyy').format(particular.expiryDate)}',
                                            style: TextStyle(
                                              color:
                                                  isExpiringSoon
                                                      ? Colors.red[700]
                                                      : Colors.green[700],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Options Button
                                  PopupMenuButton<String>(
                                    icon: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                    ),
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'view',
                                            child: Row(
                                              children: [
                                                Icon(Icons.visibility),
                                                SizedBox(width: 8),
                                                Text('View'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                        ],
                                    onSelected: (value) {
                                      if (value == 'view' &&
                                          widget.isar != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => DocumentViewPage(
                                                  isar: widget.isar!,
                                                  particular: particular,
                                                ),
                                          ),
                                        );
                                      } else if (value == 'edit' &&
                                          widget.isar != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => EditDocumentScreen(
                                                  isar: widget.isar!,
                                                  particular: particular,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildDocumentIcon(String? path) {
    IconData icon;
    if (path == null) {
      icon = Icons.description;
    } else {
      final extension = path.split('.').last.toLowerCase();
      switch (extension) {
        case 'pdf':
          icon = Icons.picture_as_pdf;
          break;
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
          icon = Icons.image;
          break;
        case 'doc':
        case 'docx':
          icon = Icons.description;
          break;
        default:
          icon = Icons.insert_drive_file;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 32, color: Colors.grey[600]),
    );
  }

  Future<Widget> _buildPdfPreview(File file) async {
    try {
      if (!await file.exists()) {
        return _buildDocumentIcon(file.path);
      }

      final document = await PdfDocument.openFile(file.path);
      if (document.pages.isEmpty) {
        return _buildDocumentIcon(file.path);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 60,
          height: 60,
          child: PdfPageView(document: document, pageNumber: 1),
        ),
      );
    } catch (e) {
      print('Error rendering PDF preview: $e');
      return _buildDocumentIcon(file.path);
    }
  }

  Widget _buildDocumentPreview(Particular particular) {
    if (particular.documentPath == null) {
      return _buildDocumentIcon(null);
    }

    final extension = path.extension(particular.documentPath!).toLowerCase();
    final file = File(particular.documentPath!);

    if (!file.existsSync()) {
      return _buildDocumentIcon(particular.documentPath);
    }

    switch (extension) {
      case '.pdf':
        return FutureBuilder<Widget>(
          future: _buildPdfPreview(file),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildDocumentIcon(particular.documentPath);
            }
            if (snapshot.hasError) {
              print('Error rendering PDF preview: ${snapshot.error}');
              return _buildDocumentIcon(particular.documentPath);
            }
            return snapshot.data!;
          },
        );
      case '.jpg':
      case '.jpeg':
      case '.png':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return _buildDocumentIcon(particular.documentPath);
            },
          ),
        );
      default:
        return _buildDocumentIcon(particular.documentPath);
    }
  }
}
