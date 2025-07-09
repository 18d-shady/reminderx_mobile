import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../auth/services/auth_service.dart';
import '../services/document_api_service.dart';
import '../services/sync_service.dart';
import '../models/profile_model.dart';
import '../services/isar_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SettingsPage extends StatefulWidget {
  final Isar isar;

  const SettingsPage({super.key, required this.isar});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _whatsappNotifications = false;
  bool _isSaving = false;
  String? _error;
  bool _showNotificationEdit = false;
  bool _showPhoneEdit = false;
  Profile? _profile;
  final ImagePicker _picker = ImagePicker();
  PhoneNumber? _phoneNumber;
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();
  bool _isUpdatingProfile = false;
  String? _phoneIsoCode = 'NG';
  bool _isPhoneValid = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final subscription = widget.isar.profiles
        .where()
        .watch(fireImmediately: true)
        .listen((profiles) async {
          if (profiles.isNotEmpty && mounted) {
            final phone = profiles.first.phoneNumber ?? '';
            PhoneNumber number = PhoneNumber(isoCode: _phoneIsoCode ?? 'NG');
            if (phone.isNotEmpty) {
              number = await PhoneNumber.getRegionInfoFromPhoneNumber(phone);
            }
            setState(() {
              _profile = profiles.first;
              _emailNotifications = _profile?.emailNotifications ?? true;
              _smsNotifications = _profile?.smsNotifications ?? false;
              _pushNotifications = _profile?.pushNotifications ?? true;
              _whatsappNotifications = _profile?.whatsappNotifications ?? false;
              _phoneNumber = number;
              _phoneController.text =
                  number.phoneNumber?.replaceFirst(number.dialCode ?? '', '') ??
                  '';
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && _profile != null) {
        setState(() {
          _isUpdatingProfile = true;
        });

        try {
          // Update profile picture on server
          final response = await DocumentApiService.updateProfile(
            profilePicturePath: image.path,
          );

          if (response.statusCode == 200) {
            // Sync with backend to get latest data
            final syncService = SyncService();
            await syncService.fetchAndStoreAll();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile picture updated')),
              );
            }
          } else {
            throw Exception('Failed to update profile picture');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating profile picture: $e')),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isUpdatingProfile = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _updatePhoneNumber() async {
    if (_profile == null || !_isPhoneValid) return;
    if (!_phoneFormKey.currentState!.validate()) return;
    setState(() {
      _isUpdatingProfile = true;
      _error = null;
    });
    try {
      final phoneNumber = _phoneNumber?.phoneNumber ?? '';
      final response = await DocumentApiService.updateProfile(
        phoneNumber: phoneNumber,
      );
      if (response.statusCode == 200) {
        final syncService = SyncService();
        await syncService.fetchAndStoreAll();
        setState(() {
          _showPhoneEdit = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Phone number updated')));
        }
      } else {
        throw Exception('Failed to update phone number');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to update phone number';
      });
    } finally {
      setState(() {
        _isUpdatingProfile = false;
      });
    }
  }

  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  if (_profile?.profilePictureUrl != null) {
                    OpenFilex.open(_profile!.profilePictureUrl!);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Change Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveNotificationPreferences() async {
    if (_profile == null) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      // First update the local profile
      await widget.isar.writeTxn(() async {
        _profile!.emailNotifications = _emailNotifications;
        _profile!.smsNotifications = _smsNotifications;
        _profile!.pushNotifications = _pushNotifications;
        _profile!.whatsappNotifications = _whatsappNotifications;
        await widget.isar.profiles.put(_profile!);
      });

      // Then update online
      final response = await DocumentApiService.updateNotificationPreferences(
        emailNotifications: _emailNotifications,
        smsNotifications: _smsNotifications,
        pushNotifications: _pushNotifications,
        whatsappNotifications: _whatsappNotifications,
      );

      if (response.statusCode == 200) {
        // Sync with backend to get latest data
        final syncService = SyncService();
        await syncService.fetchAndStoreAll();

        setState(() {
          _showNotificationEdit = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification preferences updated')),
          );
        }
      } else {
        // If online update fails, revert local changes
        await widget.isar.writeTxn(() async {
          _profile!.emailNotifications = _profile!.emailNotifications;
          _profile!.smsNotifications = _profile!.smsNotifications;
          _profile!.pushNotifications = _profile!.pushNotifications;
          _profile!.whatsappNotifications = _profile!.whatsappNotifications;
          await widget.isar.profiles.put(_profile!);
        });
        throw Exception('Failed to update notification preferences');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save notification settings';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      // First logout from auth service
      await AuthService.logout();

      // Navigate to login screen first
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }

      // Close the Isar database after navigation
      await IsarService.closeInstance();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProfile() async {
    // Show confirmation dialog with implications
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Profile'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete your profile? This action cannot be undone.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('This will:'),
                SizedBox(height: 8),
                Text('• Delete all your documents and reminders'),
                Text('• Remove your profile and settings'),
                Text('• Cancel any active subscriptions'),
                Text('• Delete all your data permanently'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete Profile'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleting profile...')));
      }

      // Delete profile from server
      final response = await DocumentApiService.deleteProfile();

      if (response.statusCode == 204) {
        // Logout and navigate to login screen
        await AuthService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        // Close the Isar database after navigation
        await IsarService.closeInstance();
      } else {
        throw Exception('Failed to delete profile: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showProfilePictureOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              isDark
                                  ? AppColors.darkSurface
                                  : Colors.grey.shade200,
                          backgroundImage:
                              _profile?.profilePictureUrl != null
                                  ? FileImage(
                                    File(_profile!.profilePictureUrl!),
                                  )
                                  : null,
                          onBackgroundImageError:
                              _profile?.profilePictureUrl != null
                                  ? (exception, stackTrace) {
                                    print(
                                      'Error loading profile image: $exception',
                                    );
                                  }
                                  : null,
                          child:
                              _profile?.profilePictureUrl == null
                                  ? Text(
                                    _profile?.username
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        'U',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: AppTheme.getSecondaryTextColor(
                                        isDark,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),
                        if (_isUpdatingProfile)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile?.username ?? 'User',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextColor(isDark),
                          ),
                        ),
                        Text(
                          _profile?.email ?? 'No email',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getSecondaryTextColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Phone Number Section
            Container(
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? AppColors.darkSurface
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.phone_outlined, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.getTextColor(isDark),
                                  ),
                                ),
                                if (_profile?.phoneNumber != null)
                                  Text(
                                    _profile!.phoneNumber!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.getSecondaryTextColor(
                                        isDark,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            _showPhoneEdit
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPhoneEdit = !_showPhoneEdit;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_showPhoneEdit)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Form(
                        key: _phoneFormKey,
                        child: Column(
                          children: [
                            InternationalPhoneNumberInput(
                              onInputChanged: (PhoneNumber number) {
                                setState(() {
                                  _phoneNumber = number;
                                  _phoneController.text =
                                      number.phoneNumber?.replaceFirst(
                                        number.dialCode ?? '',
                                        '',
                                      ) ??
                                      '';
                                  _isPhoneValid =
                                      number.phoneNumber != null &&
                                      number.phoneNumber!.length > 6;
                                });
                              },
                              onInputValidated: (bool value) {
                                setState(() {
                                  _isPhoneValid = value;
                                });
                              },
                              selectorConfig: const SelectorConfig(
                                selectorType: PhoneInputSelectorType.DROPDOWN,
                              ),
                              ignoreBlank: false,
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              initialValue: _phoneNumber,
                              textFieldController: _phoneController,
                              formatInput: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: false,
                                  ),
                              inputDecoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isUpdatingProfile || !_isPhoneValid
                                        ? null
                                        : _updatePhoneNumber,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    _isUpdatingProfile
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : const Text('Update Phone Number'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification Preferences
            Container(
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? AppColors.darkSurface
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Notification Preferences',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.getTextColor(isDark),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            _showNotificationEdit
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showNotificationEdit = !_showNotificationEdit;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_showNotificationEdit)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Email Notifications'),
                            subtitle: const Text(
                              'Receive notifications via email',
                            ),
                            value: _emailNotifications,
                            onChanged: (value) {
                              setState(() {
                                _emailNotifications = value;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('SMS Notifications'),
                            subtitle: const Text(
                              'Receive notifications via SMS',
                            ),
                            value: _smsNotifications,
                            onChanged: (value) {
                              setState(() {
                                _smsNotifications = value;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Push Notifications'),
                            subtitle: const Text(
                              'Receive push notifications on your device',
                            ),
                            value: _pushNotifications,
                            onChanged: (value) {
                              setState(() {
                                _pushNotifications = value;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('WhatsApp Notifications'),
                            subtitle: const Text(
                              'Receive notifications via WhatsApp',
                            ),
                            value: _whatsappNotifications,
                            onChanged: (value) {
                              setState(() {
                                _whatsappNotifications = value;
                              });
                            },
                          ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isSaving
                                      ? null
                                      : _saveNotificationPreferences,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  _isSaving
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text('Save Preferences'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subscription Info
            /*
            Container(
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.darkSurface
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.credit_card_outlined, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_profile?.subscriptionPlan?.toUpperCase() ?? 'FREE'} Plan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTextColor(isDark),
                            ),
                          ),
                          Text(
                            'Active until May 15, 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getSecondaryTextColor(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement subscription renewal
                      },
                      child: const Text('Renew'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          */

            // Delete Profile Section
            Container(
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.darkSurface
                                : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Profile',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTextColor(isDark),
                            ),
                          ),
                          Text(
                            'Permanently delete your account and all data',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.getSecondaryTextColor(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _deleteProfile,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
