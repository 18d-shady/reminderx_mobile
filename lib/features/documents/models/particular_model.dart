import 'package:isar/isar.dart';
import 'reminder_model.dart';

part 'particular_model.g.dart';

@collection
class Particular {
  Id id = Isar.autoIncrement; // Local DB ID

  late String docId; // Match this with backend user ID

  late String title;

  String? documentPath; // Local path to file or null

  late String category;

  late DateTime expiryDate;

  String? notes;

  bool reminded = false;

  @Backlink(to: 'particular')
  final reminders = IsarLinks<Reminder>();
}
