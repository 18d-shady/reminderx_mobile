import 'dart:convert';
import 'package:reminderx_mobile/features/documents/models/profile_model.dart';
import 'package:reminderx_mobile/features/documents/models/particular_model.dart';
import 'package:reminderx_mobile/features/documents/models/reminder_model.dart';
import 'package:reminderx_mobile/features/documents/models/notification_model.dart';
import 'package:reminderx_mobile/features/documents/services/isar_service.dart';
import 'package:reminderx_mobile/features/documents/services/document_api_service.dart';
import 'package:reminderx_mobile/features/documents/services/document_storage_service.dart';

class SyncService {
  Future<void> fetchAndStoreAll() async {
    await Future.wait([
      _fetchAndStoreProfile(),
      _fetchAndStoreParticularsAndReminders(),
      _fetchAndStoreNotifications(),
    ]);
  }

  Future<void> _fetchAndStoreProfile() async {
    final response = await DocumentApiService.getProfile();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];

      final profile =
          Profile()
            ..userId = user['id'].toString()
            ..username = user['username']
            ..email = user['email']
            ..phoneNumber = data['phone_number']
            ..reminderTime = data['reminder_time']
            ..emailNotifications = data['email_notifications']
            ..smsNotifications = data['sms_notifications']
            ..pushNotifications = data['push_notifications']
            ..whatsappNotifications = data['whatsapp_notifications']
            ..subscriptionPlan = data['subscription_plan']?.toString()
            ..profilePictureUrl = data['profile_picture_url'];

      final isar = await IsarService.getInstance();
      await isar.writeTxn(() async {
        await isar.profiles.clear();
        await isar.profiles.put(profile);
      });
    }
  }

  Future<void> _fetchAndStoreParticularsAndReminders() async {
    final response = await DocumentApiService.getDocuments();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      final isar = await IsarService.getInstance();

      await isar.writeTxn(() async {
        await isar.reminders.clear();
        await isar.particulars.clear();

        for (final item in data) {
          String? localDocumentPath;
          if (item['document_url'] != null) {
            try {
              localDocumentPath = await DocumentStorageService.downloadAndSaveDocument(
                item['document_url'],
                item['id'].toString(),
              );
            } catch (e) {
              print('Error downloading document: $e');
              // Optionally: localDocumentPath = null;
            }
          }

          final particular =
              Particular()
                ..docId = item['id'].toString()
                ..title = item['title']
                ..category = item['category']
                ..documentPath = localDocumentPath
                ..expiryDate = DateTime.parse(item['expiry_date'])
                ..reminded = item['reminded'];

          final reminders =
              (item['reminders'] as List).map((r) {
                return Reminder()
                  ..id = r['id']
                  ..reminderMessage = r['message']
                  ..scheduledDate = DateTime.parse(r['scheduled_date'])
                  ..sent = r['sent']
                  ..sentAt =
                      r['sent_at'] is DateTime
                          ? r['sent_at'] as DateTime
                          : r['sent_at'] is String
                          ? DateTime.parse(r['sent_at'] as String)
                          : null
                  ..reminderMethods = List<String>.from(r['reminder_methods'] ?? [])
                  ..recurrence = r['recurrence'] ?? 'none'
                  ..startDaysBefore = r['start_days_before'] ?? 3
                  ..particular.value = particular;
              }).toList();

          await isar.particulars.put(particular);
          await isar.reminders.putAll(reminders);
          
          // Save the links from both sides
          for (final reminder in reminders) {
            await reminder.particular.save();
            await particular.reminders.add(reminder);
          }
        }
      });
    }
  }

  Future<void> _fetchAndStoreNotifications() async {
    final response = await DocumentApiService.getNotifications();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      final isar = await IsarService.getInstance();

      await isar.writeTxn(() async {
        await isar.appNotifications.clear();

        for (final item in data) {
          final notification = AppNotification()
            ..id = item['id']
            ..particularTitle = item['particular_title']
            ..message = item['message']
            ..createdAt = DateTime.parse(item['created_at'])
            ..sendEmail = item['send_email'] ?? false
            ..sendSms = item['send_sms'] ?? false
            ..sendPush = item['send_push'] ?? false
            ..sendWhatsapp = item['send_whatsapp'] ?? false;

          await isar.appNotifications.put(notification);
        }
      });
    }
  }
}
