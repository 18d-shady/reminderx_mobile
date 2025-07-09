import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../../../core/theme.dart';

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

  Map<String, List<AppNotification>> _groupNotificationsByDate() {
    final grouped = <String, List<AppNotification>>{};
    
    for (final notification in _notifications) {
      final date = DateFormat('MMMM d, y').format(notification.createdAt);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(notification);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotificationsByDate();
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications available.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedNotifications.length,
                      itemBuilder: (context, index) {
                        final date = groupedNotifications.keys.elementAt(index);
                        final notifications = groupedNotifications[date]!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                date,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            ...notifications.map((notification) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Theme.of(context).cardColor,
                              child: ListTile(
                                leading: Icon(
                                  Icons.notifications,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  notification.particularTitle,
                                  style: TextStyle(
                                    fontFamily: 'IranSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getTextColor(Theme.of(context).brightness == Brightness.dark),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.message,
                                      style: TextStyle(
                                        fontFamily: 'IranSans',
                                        fontSize: 12,
                                        color: AppTheme.getTextColor(Theme.of(context).brightness == Brightness.dark),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('h:mm a').format(notification.createdAt),
                                      style: TextStyle(
                                        color: AppTheme.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )).toList(),
                          ],
                        );
                      },
                    ),
    );
  }
} 