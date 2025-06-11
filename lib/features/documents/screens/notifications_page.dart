import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  final Isar isar;

  const NotificationsPage({super.key, required this.isar});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final notifications = await widget.isar.appNotifications
          .where()
          .sortByCreatedAtDesc()
          .findAll();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications available.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(
                              notification.particularTitle,
                              style: const TextStyle(
                                fontFamily: 'IranSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.message,
                                  style: const TextStyle(fontFamily: 'IranSans'),
                                ),
                                Text(
                                  DateFormat('h:mm a').format(notification.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 