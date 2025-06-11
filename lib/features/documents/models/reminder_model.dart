import 'package:isar/isar.dart';
import 'particular_model.dart';

part 'reminder_model.g.dart';

@collection
class Reminder {
  Id id = Isar.autoIncrement;

  late DateTime scheduledDate;

  bool sent = false;

  DateTime? sentAt;

  List<String> reminderMethods = [];

  String? reminderMessage;

  String recurrence = 'none';

  int startDaysBefore = 3;

  final particular = IsarLink<Particular>();
}
