import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../models/particular_model.dart';
import '../models/reminder_model.dart';
import 'package:path/path.dart' as path;
import 'package:pdfrx/pdfrx.dart';
import 'package:open_filex/open_filex.dart';
import 'edit_document.dart';
import '../services/document_api_service.dart';
import '../services/sync_service.dart';
import '../../../core/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewPage extends StatefulWidget {
  final Isar isar;
  final Particular particular;

  const DocumentViewPage({
    super.key,
    required this.isar,
    required this.particular,
  });

  @override
  State<DocumentViewPage> createState() => _DocumentViewPageState();
}

class _DocumentViewPageState extends State<DocumentViewPage> {
  bool showRenewModal = false;

  bool get isExpiringSoon {
    final expiry = widget.particular.expiryDate;
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    return daysLeft < 30;
  }

  List<Map<String, String>> getRenewalLinks(String category) {
    switch (category.toLowerCase()) {
      case 'driver':
        return [
          {
            'label': "Renew Driver's License (Nigerian Government)",
            'url': 'https://www.nigeriadriverslicence.org/dlApplication/renew',
          },
          {
            'label': "FRSC Driver's License Portal",
            'url': 'https://www.nigeriadriverslicence.org/',
          },
        ];
      case 'vehicle':
        return [
          {
            'label': "Renew Vehicle License (Lagos State)",
            'url': 'https://www.lsmvaapvs.org/',
          },
          {
            'label': "Renew Vehicle License (Nigerian Government)",
            'url': 'https://www.nigeriavehiclelicence.com/',
          },
        ];
      case 'international passport':
        return [
          {
            'label': "Renew International Passport",
            'url': 'https://portal.immigration.gov.ng/',
          },
        ];
      default:
        return [
          {
            'label': "General Renewal Portal",
            'url': 'https://www.nigeria.gov.ng/',
          },
        ];
    }
  }

  void _showRenewModal() {
    showDialog(
      context: context,
      builder: (context) {
        final links = getRenewalLinks(widget.particular.category);
        return AlertDialog(
          title: Text('Renew ${widget.particular.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose a renewal option:'),
              ...links.map(
                (link) => ListTile(
                  title: Text(link['label']!),
                  onTap: () async {
                    final url = link['url']!;
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDocument(BuildContext context) async {
    if (widget.particular.documentPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No document file available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final file = File(widget.particular.documentPath!);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document file not found'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final extension = _getFileExtension();

      // Check if we can handle the file type
      if ([
        '.pdf',
        '.jpg',
        '.jpeg',
        '.png',
        '.doc',
        '.docx',
      ].contains(extension)) {
        // Use open_filex to open the file
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error opening file: ${result.message}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unsupported file type: $extension'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getFileExtension() {
    if (widget.particular.documentPath == null) return '';
    return path.extension(widget.particular.documentPath!).toLowerCase();
  }

  Widget _buildDocumentPreview() {
    if (widget.particular.documentPath == null) {
      return _buildDocumentIcon(null);
    }

    final extension = _getFileExtension();
    final file = File(widget.particular.documentPath!);

    if (!file.existsSync()) {
      return _buildDocumentIcon(widget.particular.documentPath);
    }

    switch (extension) {
      case '.pdf':
        return FutureBuilder<Widget>(
          future: _buildPdfPreview(file),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildDocumentIcon(widget.particular.documentPath);
            }
            if (snapshot.hasError) {
              print('Error rendering PDF preview: ${snapshot.error}');
              return _buildDocumentIcon(widget.particular.documentPath);
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
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return _buildDocumentIcon(widget.particular.documentPath);
            },
          ),
        );
      default:
        return _buildDocumentIcon(widget.particular.documentPath);
    }
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
      width: 80,
      height: 80,
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
        return _buildDocumentIcon(widget.particular.documentPath);
      }

      final document = await PdfDocument.openFile(file.path);
      if (document.pages.isEmpty) {
        return _buildDocumentIcon(widget.particular.documentPath);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 80,
          height: 80,
          child: PdfPageView(document: document, pageNumber: 1),
        ),
      );
    } catch (e) {
      print('Error rendering PDF preview: $e');
      return _buildDocumentIcon(widget.particular.documentPath);
    }
  }

  Future<void> _deleteDocument(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: const Text(
              'Are you sure you want to delete this document? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleting document...')));
      }

      // Delete document from server
      final response = await DocumentApiService.deleteDocument(
        widget.particular.docId,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete document: ${response.statusCode}');
      }

      // Sync with local database
      final syncService = SyncService();
      await syncService.fetchAndStoreAll();

      if (context.mounted) {
        // Show success message and pop back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting document: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    final isExpiringSoon = widget.particular.expiryDate.isBefore(
      thirtyDaysFromNow,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 0,
        title: Text(
          'Document Details',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<List<Reminder>>(
        future: widget.particular.reminders.filter().findAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading reminders: ${snapshot.error}'),
            );
          }

          final reminders = snapshot.data ?? [];
          print(
            'Loaded ${reminders.length} reminders for document ${widget.particular.title}',
          );
          for (final reminder in reminders) {
            print(
              'Reminder: ${reminder.scheduledDate}, Method: ${reminder.reminderMethods.join(', ')}',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Document Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document Preview and Title Row
                      Row(
                        children: [
                          // Document Preview
                          widget.particular.documentPath != null
                              ? GestureDetector(
                                onTap: () => _openDocument(context),
                                child: _buildDocumentPreview(),
                              )
                              : _buildDocumentPreview(),
                          const SizedBox(width: 16),
                          // Document Title
                          Expanded(
                            child: Text(
                              widget.particular.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getTextColor(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Expiry Status Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.getExpiryColor(
                            isExpiringSoon,
                            isDark,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expires in',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.getSecondaryTextColor(
                                        isDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(widget.particular.expiryDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getExpiryColor(
                                        isExpiringSoon,
                                        isDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpiringSoon
                                  ? Icons.warning
                                  : Icons.check_circle,
                              color: AppTheme.getExpiryColor(
                                isExpiringSoon,
                                isDark,
                              ),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Document Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Document Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isExpiringSoon)
                        ElevatedButton(
                          onPressed: _showRenewModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Renew'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        'Document Name',
                        widget.particular.title,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        context,
                        'Expiry Date',
                        DateFormat(
                          'MMM dd, yyyy',
                        ).format(widget.particular.expiryDate),
                      ),
                      const Divider(),
                      _buildDetailRow(
                        context,
                        'Category',
                        widget.particular.category,
                      ),
                      if (widget.particular.notes?.isNotEmpty ?? false) ...[
                        const Divider(),
                        _buildDetailRow(
                          context,
                          'Notes',
                          widget.particular.notes!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Reminders Section
                if (reminders.isNotEmpty) ...[
                  Text(
                    'Reminders',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children:
                          reminders
                              .map(
                                (reminder) => Column(
                                  children: [
                                    _buildDetailRow(
                                      context,
                                      'Reminder Date',
                                      DateFormat(
                                        'MMM dd, yyyy h:mm a',
                                      ).format(reminder.scheduledDate),
                                    ),
                                    const Divider(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Methods',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                AppTheme.getSecondaryTextColor(
                                                  isDark,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...reminder.reminderMethods.map(
                                          (method) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _getMethodIcon(method),
                                                  size: 16,
                                                  color: AppTheme.getTextColor(
                                                    isDark,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  method.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppTheme.getTextColor(
                                                          isDark,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (reminder.reminderMessage?.isNotEmpty ??
                                        false) ...[
                                      const Divider(),
                                      _buildDetailRow(
                                        context,
                                        'Message',
                                        reminder.reminderMessage!,
                                      ),
                                    ],
                                    if (reminder != reminders.last)
                                      const Divider(),
                                  ],
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Edit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditDocumentScreen(
                                isar: widget.isar,
                                particular: widget.particular,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Edit Document'),
                  ),
                ),
                const SizedBox(height: 12),
                // Delete Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _deleteDocument(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Delete Document'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getSecondaryTextColor(isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      case 'push':
        return Icons.notifications;
      case 'whatsapp':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }
}
