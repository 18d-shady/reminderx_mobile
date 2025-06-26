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
import 'package:flutter_svg/flutter_svg.dart';

class DocumentList extends StatefulWidget {
  final Isar? isar;
  final bool showTabs;

  const DocumentList({super.key, this.isar, this.showTabs = true});

  @override
  State<DocumentList> createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentList>
    with SingleTickerProviderStateMixin {
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no-documents.svg',
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isar == null
                ? 'Database not connected'
                : 'No documents here',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isar == null
                ? 'Please check your connection and try again'
                : 'Click the add button above to add documents',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final bool isSelected = _selectedTab == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.secondary : Colors.white,
          foregroundColor: isSelected ? Colors.black87 : Colors.black54,
          side: BorderSide(color: Colors.grey[300]!, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          setState(() {
            _selectedTab = label;
          });
        },
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    return Column(
      children: [
        if (widget.showTabs)
          Container(
            color: bgColor,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTabButton('All'),
                _buildTabButton('Expiring Soon'),
                _buildTabButton('Up to Date'),
              ],
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

                      return ListView.separated(
                        padding: const EdgeInsets.all(4),
                        itemCount: filteredParticulars.length,
                        separatorBuilder:
                            (context, index) =>
                                Divider(color: Colors.grey[200], height: 1),
                        itemBuilder: (context, index) {
                          final particular = filteredParticulars[index];
                          final isExpired = particular.expiryDate.isBefore(now);
                          final isExpiringSoon =
                              !isExpired &&
                              particular.expiryDate.isAfter(now) &&
                              particular.expiryDate.isBefore(thirtyDaysFromNow);

                          return InkWell(
                            onTap: () {
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
                            },
                            child: Container(
                              color: bgColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
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
                                            fontSize: 11,
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
                                                isExpired
                                                    ? Colors.red[50]
                                                    : isExpiringSoon
                                                    ? Colors.red[50]
                                                    : Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            isExpired
                                                ? 'Expired: ${DateFormat('MMM dd, yyyy').format(particular.expiryDate)}'
                                                : 'Expires: ${DateFormat('MMM dd, yyyy').format(particular.expiryDate)}',
                                            style: TextStyle(
                                              color:
                                                  isExpired
                                                      ? Colors.red[700]
                                                      : isExpiringSoon
                                                      ? Colors.red[700]
                                                      : Colors.green[700],
                                              fontSize: 8,
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
                                        size: 16,
                                      ),
                                    ),
                                    color: Colors.white,
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  color: AppColors.primary,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                    onSelected: (value) {
                                      if (value == 'edit' &&
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
