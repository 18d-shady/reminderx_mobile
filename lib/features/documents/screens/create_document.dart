import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import '../services/document_api_service.dart';
import 'package:intl/intl.dart';
import '../services/sync_service.dart';
import '../models/profile_model.dart';

class CreateDocumentScreen extends StatefulWidget {
  final Isar isar;

  const CreateDocumentScreen({super.key, required this.isar});

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
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
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final subscription = widget.isar.profiles.where().watch(fireImmediately: true).listen((profiles) {
      if (profiles.isNotEmpty && mounted) {
        setState(() {
          _profile = profiles.first;
          // Initialize reminder methods based on profile settings
          _selectedReminderMethods = [];
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
      initialDate: DateTime.now(),
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

      // Create document on server
      final response = await DocumentApiService.createDocument(formData);

      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to create document: ${errorBody['detail'] ?? errorBody.toString()}',
        );
      }

      final responseData = jsonDecode(response.body);
      final particularId = responseData['id'];

      // Create reminder on server
      final reminderData = {
        'particular': particularId,
        'scheduled_date': _scheduleDate!.toIso8601String(),
        'reminder_methods': _selectedReminderMethods,
        'recurrence': _recurrence,
        'start_days_before': _startDaysBefore,
      };

      final reminderResponse = await DocumentApiService.createReminder(
        reminderData,
      );

      if (reminderResponse.statusCode != 201) {
        throw Exception(
          'Failed to create reminder: ${reminderResponse.statusCode}',
        );
      }

      // Sync with local database
      final syncService = SyncService();
      await syncService.fetchAndStoreAll();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Error creating document: $e';
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
      appBar: AppBar(title: const Text('Create New Document')),
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
                  DropdownMenuItem(value: 'professional', child: Text('Professional')),
                  DropdownMenuItem(value: 'household', child: Text('Household')),
                  DropdownMenuItem(value: 'finance', child: Text('Finance')),
                  DropdownMenuItem(value: 'health', child: Text('Health')),
                  DropdownMenuItem(value: 'social', child: Text('Social')),
                  DropdownMenuItem(value: 'education', child: Text('Education')),
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
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _expiryDate == null
                        ? 'Select Expiry Date'
                        : DateFormat('yyyy-MM-dd').format(_expiryDate!),
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
                  hintText: 'Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),

              // Upload Document
              const Text(
                'Upload Document',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFile?.name ?? 'Choose a file',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Reminder Settings Section
              const Text(
                'Reminder Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Reminder Date
              const Text(
                'Reminder Date*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _scheduleDate == null
                        ? 'Select Reminder Date'
                        : DateFormat('yyyy-MM-dd').format(_scheduleDate!),
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

              // Recurring Reminder
              const Text(
                'Recurring Reminder*',
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
                  DropdownMenuItem(value: 'every_2_days', child: Text('Every 2 Days')),
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
                'Start Days Before Expiry Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _startDaysBefore.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _startDaysBefore = int.tryParse(value) ?? 3;
                  });
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
                  child: _isSubmitting
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
                      : const Text('Create Document'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
