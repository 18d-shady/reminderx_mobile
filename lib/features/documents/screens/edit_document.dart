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
        type: FileType.any,
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isExpiryDate
              ? _expiryDate ?? DateTime.now()
              : _scheduleDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        if (isExpiryDate) {
          _expiryDate = picked;
        } else {
          _scheduleDate = picked;
        }
      });
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
    if (_selectedReminderMethods.isEmpty) {
      setState(() {
        _error = 'Please select at least one reminder method';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Name
              const Text(
                'Document Name*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter Document Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a document name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Document Type
              const Text(
                'Document Type*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Expiry Date
              const Text(
                'Expiry Date*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expiryDate != null
                            ? DateFormat('MMM dd, yyyy').format(_expiryDate!)
                            : 'Select Expiry Date',
                        style: TextStyle(
                          color:
                              _expiryDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              const Text(
                'Notes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter any additional notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Document File
              const Text(
                'Document File',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _selectedFile?.name ??
                            widget.particular.documentPath?.split('/').last ??
                            'No file selected',
                        style: TextStyle(
                          color:
                              (_selectedFile != null ||
                                      widget.particular.documentPath != null)
                                  ? Colors.black
                                  : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reminder Settings
              const Text(
                'Reminder Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Schedule Date
              const Text(
                'Schedule Date*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _scheduleDate != null
                            ? DateFormat('MMM dd, yyyy').format(_scheduleDate!)
                            : 'Select Schedule Date',
                        style: TextStyle(
                          color:
                              _scheduleDate != null
                                  ? Colors.black
                                  : Colors.grey,
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notification Preference
              const Text(
                'Notification Preference*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  if (_profile?.emailNotifications ?? false)
                    CheckboxListTile(
                      title: const Text('Email'),
                      value: _selectedReminderMethods.contains('email'),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedReminderMethods.add('email');
                          } else {
                            _selectedReminderMethods.remove('email');
                          }
                        });
                      },
                    ),
                  if (_profile?.smsNotifications ?? false)
                    CheckboxListTile(
                      title: const Text('SMS'),
                      value: _selectedReminderMethods.contains('sms'),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedReminderMethods.add('sms');
                          } else {
                            _selectedReminderMethods.remove('sms');
                          }
                        });
                      },
                    ),
                  if (_profile?.pushNotifications ?? false)
                    CheckboxListTile(
                      title: const Text('Push Notification'),
                      value: _selectedReminderMethods.contains('push'),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedReminderMethods.add('push');
                          } else {
                            _selectedReminderMethods.remove('push');
                          }
                        });
                      },
                    ),
                  if (_profile?.whatsappNotifications ?? false)
                    CheckboxListTile(
                      title: const Text('WhatsApp'),
                      value: _selectedReminderMethods.contains('whatsapp'),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedReminderMethods.add('whatsapp');
                          } else {
                            _selectedReminderMethods.remove('whatsapp');
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Recurrence
              const Text(
                'Recurrence',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _recurrence,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                  if (value != null) {
                    setState(() {
                      _recurrence = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Start Days Before
              const Text(
                'Start Days Before*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _startDaysBefore,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 day')),
                  DropdownMenuItem(value: 3, child: Text('3 days')),
                  DropdownMenuItem(value: 7, child: Text('7 days')),
                  DropdownMenuItem(value: 14, child: Text('14 days')),
                  DropdownMenuItem(value: 30, child: Text('30 days')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _startDaysBefore = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator()
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
