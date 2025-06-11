import 'package:isar/isar.dart';

part 'profile_model.g.dart';

@collection
class Profile {
  Id id = 0; // Always one profile

  String? userId; // Backend user ID

  String? username; // From Django User

  String? email; // From Django User

  String? phoneNumber;

  bool emailNotifications = true;

  bool smsNotifications = false;

  bool pushNotifications = true;

  bool whatsappNotifications = false;

  int reminderTime = 3;

  String? subscriptionPlan; // 'free', 'premium', 'enterprise'

  String? profilePictureUrl;
}
