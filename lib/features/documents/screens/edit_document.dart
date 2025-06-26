import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import '../services/document_api_service.dart';
import 'package:intl/intl.dart';
import '../services/sync_service.dart';
import '../models/particular_model.dart';
import '../models/reminder_model.dart';
import '../models/profile_model.dart';
import '../../../core/theme.dart';

class EditDocumentScreen extends StatefulWidget {
  final Isar isar;
  final Particular particular;

  const EditDocumentScreen({
    super.key,
    required this.isar,
    required this.particular,
  });

  @override
  State<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _expiryDate;
  DateTime? _scheduleDate;
  String _category = 'other';
  List<String> _selectedReminderMethods = [];
  String _recurrence = 'none';
  int _startDaysBefore = 3;
  PlatformFile? _selectedFile;
  String? _error;
  bool _isSubmitting = false;
  Reminder? _existingReminder;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _loadProfile();
  }

  void _loadProfile() {
    final subscription = widget.isar.profiles
        .where()
        .watch(fireImmediately: true)
        .listen((profiles) {
          if (profiles.isNotEmpty && mounted) {
            setState(() {
              _profile = profiles.first;
              // Only initialize reminder methods if we don't have existing ones
              if (_selectedReminderMethods.isEmpty) {
                // Only add methods that are enabled in profile
                if (_profile?.emailNotifications ?? false) {
                  _selectedReminderMethods.add('email');
                }
                if (_profile?.smsNotifications ?? false) {
                  _selectedReminderMethods.add('sms');
                }
                if (_profile?.pushNotifications ?? false) {
                  _selectedReminderMethods.add('push');
                }
                if (_profile?.whatsappNotifications ?? false) {
                  _selectedReminderMethods.add('whatsapp');
                }
              }
            });
          }
        });

    // Clean up subscription when widget is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        subscription.cancel();
      }
    });
  }

  Future<void> _loadExistingData() async {
    // Load document data
    _titleController.text = widget.particular.title;
    _notesController.text = widget.particular.notes ?? '';
    _expiryDate = widget.particular.expiryDate;
    _category = widget.particular.category;

    // Load reminder data
    final reminders = await widget.particular.reminders.filter().findAll();
    if (reminders.isNotEmpty) {
      _existingReminder = reminders.first;
      _scheduleDate = _existingReminder!.scheduledDate;
      // Create a new list from the existing reminder methods
      _selectedReminderMethods = List<String>.from(
        _existingReminder!.reminderMethods,
      );
      _recurrence = _existingReminder!.recurrence;
      _startDaysBefore = _existingReminder!.startDaysBefore;
    }

    // Set the existing document file if available
    if (widget.particular.documentPath != null &&
        widget.particular.documentPath!.isNotEmpty) {
      setState(() {
        _selectedFile = PlatformFile(
          name: widget.particular.documentPath!.split('/').last,
          path: widget.particular.documentPath,
          size: 0, // We don't have the file size
        );
      });
    }

    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt',
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'
        ],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking file: $e';
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isExpiryDate) async {
    if (isExpiryDate) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _expiryDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
      );

      if (picked != null) {
        setState(() {
          _expiryDate = picked;
        });
      }
    } else {
      // For scheduled date, show date picker first
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _scheduleDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
      );

      if (pickedDate != null) {
        // Then show time picker
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime:
              _scheduleDate != null
                  ? TimeOfDay(
                    hour: _scheduleDate!.hour,
                    minute: _scheduleDate!.minute,
                  )
                  : TimeOfDay.now(),
        );

        if (pickedTime != null) {
          setState(() {
            _scheduleDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null || _scheduleDate == null) {
      setState(() {
        _error = 'Please select both expiry and schedule dates';
      });
      return;
    }
    final now = DateTime.now();
    if (_expiryDate!.isBefore(DateTime(now.year, now.month, now.day))) {
      setState(() {
        _error = 'Expiry date cannot be before today.';
      });
      return;
    }
    if (_scheduleDate!.isBefore(now)) {
      setState(() {
        _error = 'Reminder date must be on or after now.';
      });
      return;
    }
    if (_scheduleDate!.isAfter(_expiryDate!)) {
      setState(() {
        _error = 'Reminder date cannot be after expiry date.';
      });
      return;
    }
    if (_selectedReminderMethods.isEmpty) {
      setState(() {
        _error = 'Please select at least one reminder method';
      });
      return;
    }
    if (_selectedFile != null && _selectedFile!.size > 20 * 1024 * 1024) {
      setState(() {
        _error = 'File size must be less than 20MB.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (!isOnline) {
        throw Exception('No internet connection');
      }

      // Create FormData for document
      final formData = {
        'title': _titleController.text,
        'category': _category,
        'expiry_date': _expiryDate!.toIso8601String().split('T')[0],
        'notes': _notesController.text,
      };

      if (_selectedFile != null && _selectedFile!.path != null) {
        formData['document'] = _selectedFile!.path!;
      }

      // Update document on server
      final response = await DocumentApiService.updateDocument(
        widget.particular.docId,
        formData,
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to update document: ${errorBody['detail'] ?? errorBody.toString()}',
        );
      }

      // Update reminder on server if it exists
      if (_existingReminder != null) {
        final reminderData = {
          'scheduled_date': _scheduleDate!.toIso8601String(),
          'reminder_methods': _selectedReminderMethods,
          'recurrence': _recurrence,
          'start_days_before': _startDaysBefore,
        };

        final reminderResponse = await DocumentApiService.updateReminder(
          _existingReminder!.id.toString(),
          reminderData,
        );

        if (reminderResponse.statusCode != 200) {
          throw Exception(
            'Failed to update reminder: ${reminderResponse.statusCode}',
          );
        }
      }

      // Sync with local database
      final syncService = SyncService();
      await syncService.fetchAndStoreAll();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Error updating document: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter document title',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'vehicle', child: Text('Vehicle')),
                  DropdownMenuItem(value: 'travels', child: Text('Travels')),
                  DropdownMenuItem(value: 'personal', child: Text('Personal')),
                  DropdownMenuItem(value: 'work', child: Text('Work')),
                  DropdownMenuItem(
                    value: 'professional',
                    child: Text('Professional'),
                  ),
                  DropdownMenuItem(
                    value: 'household',
                    child: Text('Household'),
                  ),
                  DropdownMenuItem(value: 'finance', child: Text('Finance')),
                  DropdownMenuItem(value: 'health', child: Text('Health')),
                  DropdownMenuItem(value: 'social', child: Text('Social')),
                  DropdownMenuItem(
                    value: 'education',
                    child: Text('Education'),
                  ),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Expiry Date Field
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : Colors.white,
                  ),
                  child: Text(
                    _expiryDate == null
                        ? 'Select expiry date'
                        : DateFormat('MMM dd, yyyy').format(_expiryDate!),
                    style: TextStyle(
                      color:
                          _expiryDate == null
                              ? AppTheme.getSecondaryTextColor(isDark)
                              : AppTheme.getTextColor(isDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Enter any additional notes',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // File Upload Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkDivider : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document File',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFile != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? AppColors.darkCard
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              color: AppTheme.getTextColor(isDark),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFile!.name,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(isDark),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.particular.documentPath != null &&
                                      widget
                                          .particular
                                          .documentPath!
                                          .isNotEmpty &&
                                      _selectedFile!.path ==
                                          widget.particular.documentPath)
                                    Text(
                                      'Current document',
                                      style: TextStyle(
                                        color: AppTheme.getSecondaryTextColor(
                                          isDark,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Document (Allowed: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, TXT, JPG, JPEG, PNG, GIF, BMP, SVG, WEBP. Max 20MB)'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reminder Settings Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkDivider : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Schedule Date
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Schedule Date & Time',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                        ),
                        child: Text(
                          _scheduleDate == null
                              ? 'Select schedule date and time'
                              : DateFormat(
                                'MMM dd, yyyy h:mm a',
                              ).format(_scheduleDate!),
                          style: TextStyle(
                            color:
                                _scheduleDate == null
                                    ? AppTheme.getSecondaryTextColor(isDark)
                                    : AppTheme.getTextColor(isDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reminder Methods
                    Text(
                      'Reminder Methods',
                      style: TextStyle(
                        color: AppTheme.getTextColor(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Email'),
                          selected: _selectedReminderMethods.contains('email'),
                          onSelected:
                              (_profile?.emailNotifications ?? false)
                                  ? (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedReminderMethods.add('email');
                                      } else {
                                        _selectedReminderMethods.remove(
                                          'email',
                                        );
                                      }
                                    });
                                  }
                                  : null,
                        ),
                        FilterChip(
                          label: const Text('SMS'),
                          selected: _selectedReminderMethods.contains('sms'),
                          onSelected:
                              (_profile?.smsNotifications ?? false)
                                  ? (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedReminderMethods.add('sms');
                                      } else {
                                        _selectedReminderMethods.remove('sms');
                                      }
                                    });
                                  }
                                  : null,
                        ),
                        FilterChip(
                          label: const Text('Push'),
                          selected: _selectedReminderMethods.contains('push'),
                          onSelected:
                              (_profile?.pushNotifications ?? false)
                                  ? (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedReminderMethods.add('push');
                                      } else {
                                        _selectedReminderMethods.remove('push');
                                      }
                                    });
                                  }
                                  : null,
                        ),
                        FilterChip(
                          label: const Text('WhatsApp'),
                          selected: _selectedReminderMethods.contains(
                            'whatsapp',
                          ),
                          onSelected:
                              (_profile?.whatsappNotifications ?? false)
                                  ? (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedReminderMethods.add(
                                          'whatsapp',
                                        );
                                      } else {
                                        _selectedReminderMethods.remove(
                                          'whatsapp',
                                        );
                                      }
                                    });
                                  }
                                  : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recurrence
                    DropdownButtonFormField<String>(
                      value: _recurrence,
                      decoration: InputDecoration(
                        labelText: 'Recurrence',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('None')),
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(
                          value: 'every_2_days',
                          child: Text('Every 2 Days'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _recurrence = value!;
                          if (value == 'none') {
                            _startDaysBefore = 3; // Reset to default
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start Days Before
                    TextFormField(
                      initialValue: _startDaysBefore.toString(),
                      enabled: _recurrence != 'none',
                      decoration: InputDecoration(
                        labelText: 'Start Days Before Expiry',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (_recurrence != 'none') {
                          final days = int.tryParse(value) ?? 3;
                          setState(() {
                            _startDaysBefore = days.clamp(1, 7);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text('Update Document'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
