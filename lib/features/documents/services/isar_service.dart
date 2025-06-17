import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reminderx_mobile/features/documents/models/profile_model.dart';
import 'package:reminderx_mobile/features/documents/models/particular_model.dart';
import 'package:reminderx_mobile/features/documents/models/reminder_model.dart';
import 'package:reminderx_mobile/features/documents/models/notification_model.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        ProfileSchema,
        ParticularSchema,
        ReminderSchema,
        AppNotificationSchema,
      ],
      directory: dir.path,
    );

    return _isar!;
  }

  static Future<void> closeInstance() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}
