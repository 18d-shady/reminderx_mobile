import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../auth/services/auth_service.dart';
import '../services/document_api_service.dart';
import '../services/sync_service.dart';
import '../models/profile_model.dart';

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
  Profile? _profile;

  @override
  void initState() {
    super.initState();
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
              _emailNotifications = _profile?.emailNotifications ?? true;
              _smsNotifications = _profile?.smsNotifications ?? false;
              _pushNotifications = _profile?.pushNotifications ?? true;
              _whatsappNotifications = _profile?.whatsappNotifications ?? false;
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
    // Cancel any active subscriptions
    widget.isar.profiles.where().watch().listen((_) {}).cancel();
    super.dispose();
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
      // Logout from auth service
      await AuthService.logout();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
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

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        _profile?.profilePictureUrl != null
                            ? NetworkImage(_profile!.profilePictureUrl!)
                            : null,
                    child:
                        _profile?.profilePictureUrl == null
                            ? Text(
                              _profile?.username
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.grey,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile?.username ?? 'User',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _profile?.email ?? 'No email',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification Preferences
            const Text(
              'Account Settings',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications_outlined),
                ),
                title: const Text(
                  'Notification Preferences',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: IconButton(
                  icon: Icon(
                    _showNotificationEdit
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    setState(() {
                      _showNotificationEdit = !_showNotificationEdit;
                    });
                  },
                ),
              ),
            ),

            // Notification Edit Section
            if (_showNotificationEdit)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Email Notifications'),
                      subtitle: const Text('Receive notifications via email'),
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('SMS Notifications'),
                      subtitle: const Text('Receive notifications via SMS'),
                      value: _smsNotifications,
                      onChanged: (value) {
                        setState(() {
                          _smsNotifications = value;
                        });
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
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
                    const Divider(),
                    SwitchListTile(
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
                            _isSaving ? null : _saveNotificationPreferences,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('Save Notifications'),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Subscription Info
            const Text(
              'Subscription',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.credit_card_outlined),
                ),
                title: Text(
                  '${_profile?.subscriptionPlan?.toUpperCase() ?? 'FREE'} Plan',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Active until May 15, 2025',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: TextButton(
                  onPressed: () {
                    // TODO: Implement subscription renewal
                  },
                  child: const Text('Renew'),
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
                    borderRadius: BorderRadius.circular(8),
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
