import 'package:isar/isar.dart';

part 'notification_model.g.dart';

@collection
class AppNotification {
  Id id = Isar.autoIncrement;

  late String particularTitle;
  late String message;
  late DateTime createdAt;

  bool sendEmail = false;
  bool sendSms = false;
  bool sendPush = false;
  bool sendWhatsapp = false;

  bool isSent = false;
  DateTime? sentAt;

  @override
  String toString() {
    return 'Notification for $particularTitle';
  }
} 