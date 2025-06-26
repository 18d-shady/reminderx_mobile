import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/profile_model.dart';
import '../services/isar_service.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'documents_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';
import 'create_document.dart';
import '../../../shared/bottom_nav_bar.dart';
import '../../../shared/top_bar.dart';
import '../../../shared/search_bar.dart';
import 'package:reminderx_mobile/features/documents/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Isar? _isar;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initializeIsar();
  }

  Future<void> _initializeIsar() async {
    try {
      final isar = await IsarService.getInstance();
      if (mounted) {
        setState(() {
          _isar = isar;
        });
        _attemptSyncIfNeeded();
      }
    } catch (e) {
      print('Error initializing Isar: $e');
    }
  }

  Future<void> _attemptSyncIfNeeded() async {
    if (_isSyncing || _isar == null) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final isOnline = await _checkInternetConnection();
      if (isOnline) {
        // Start sync but don't wait for it
        SyncService().fetchAndStoreAll().catchError((error) {
          print('Sync error: $error');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<bool> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isar == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            StreamBuilder<List<Profile>>(
              stream: _isar!.profiles.where().watch(fireImmediately: true),
              builder: (context, snapshot) {
                final profile = snapshot.data?.firstOrNull;

                // Dynamically create the current page
                final currentPage =
                    [
                      HomePage(isar: _isar!),
                      CalendarPage(isar: _isar!),
                      DocumentsPage(isar: _isar!),
                      SettingsPage(isar: _isar!),
                    ][_currentIndex];

                return Column(
                  children: [
                    // Top Bar
                    TopBar(
                      userName: profile?.username ?? 'User',
                      profileImageUrl: profile?.profilePictureUrl,
                      notificationCount: 0,
                      onNotificationTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => NotificationsPage(isar: _isar!),
                          ),
                        );
                      },
                      onAddTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CreateDocumentScreen(isar: _isar!),
                          ),
                        );
                      },
                      onSyncTap: () async {
                        if (_isSyncing) return;
                        setState(() => _isSyncing = true);
                        try {
                          await SyncService().fetchAndStoreAll();
                        } catch (e) {
                          print('Sync error: $e');
                        } finally {
                          if (mounted) setState(() => _isSyncing = false);
                        }
                      },
                      isSyncing: _isSyncing,
                    ),
                    // Search Bar (show on all pages except settings)
                    if (_currentIndex != 3) // Not settings page
                      DocumentSearchBar(
                        controller: TextEditingController(),
                        isar: _isar!,
                      ),
                    // Page Content
                    Expanded(child: currentPage),
                  ],
                );
              },
            ),
            if (_isSyncing)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
