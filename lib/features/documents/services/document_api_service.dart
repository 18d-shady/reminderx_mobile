import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reminderx_mobile/features/auth/services/auth_service.dart';
import '../../../core/constants.dart';

class DocumentApiService {
  static Future<http.Response> authorizedRequest(
    Future<http.Response> Function(String token) requestFn,
  ) async {
    String? token = await AuthService.getAccessToken();
    if (token == null) return http.Response('Unauthorized', 401);

    http.Response response = await requestFn(token);

    if (response.statusCode == 401) {
      bool refreshed = await AuthService.refreshAccessToken();
      if (refreshed) {
        token = await AuthService.getAccessToken();
        return requestFn(token!);
      } else {
        await AuthService.logout();
        return http.Response('Unauthorized', 401);
      }
    }

    return response;
  }

  static Future<http.Response> getDocuments() async {
    return authorizedRequest((token) {
      return http.get(
        Uri.parse('${baseUrl}api/particulars/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });
  }

  static Future<http.Response> getProfile() async {
    return authorizedRequest((token) {
      return http.get(
        Uri.parse('${baseUrl}api/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });
  }

  static Future<http.Response> createDocument(Map<String, dynamic> data) async {
    return authorizedRequest((token) async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}api/particulars/'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['title'] = data['title'] as String;
      request.fields['category'] = data['category'] as String;
      request.fields['expiry_date'] = data['expiry_date'] as String;
      if (data['notes'] != null) {
        request.fields['notes'] = data['notes'] as String;
      }

      // Add file if present
      if (data['document'] != null) {
        final file = await http.MultipartFile.fromPath(
          'document',
          data['document'] as String,
        );
        request.files.add(file);
      }

      print('Sending request with fields: ${request.fields}');
      if (request.files.isNotEmpty) {
        print('Including file: ${request.files.first.filename}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        print('Error response: ${response.body}');
      }

      return response;
    });
  }

  static Future<http.Response> createReminder(Map<String, dynamic> data) async {
    return authorizedRequest((token) {
      return http.post(
        Uri.parse('${baseUrl}api/reminders/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    });
  }

  static Future<http.Response> updateDocument(
    String id,
    Map<String, dynamic> data,
  ) async {
    return authorizedRequest((token) async {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${baseUrl}api/particulars/$id/'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['title'] = data['title'] as String;
      request.fields['category'] = data['category'] as String;
      request.fields['expiry_date'] = data['expiry_date'] as String;
      if (data['notes'] != null) {
        request.fields['notes'] = data['notes'] as String;
      }

      // Add file if present
      if (data['document'] != null) {
        final file = await http.MultipartFile.fromPath(
          'document',
          data['document'] as String,
        );
        request.files.add(file);
      }

      print('Sending update request with fields: ${request.fields}');
      if (request.files.isNotEmpty) {
        print('Including file: ${request.files.first.filename}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
      }

      return response;
    });
  }

  static Future<http.Response> updateReminder(
    String id,
    Map<String, dynamic> data,
  ) async {
    return authorizedRequest((token) {
      return http.patch(
        Uri.parse('${baseUrl}api/reminders/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    });
  }

  static Future<http.Response> deleteDocument(String id) async {
    return authorizedRequest((token) {
      return http.delete(
        Uri.parse('${baseUrl}api/particulars/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });
  }

  static Future<http.Response> updateNotificationPreferences({
    required bool emailNotifications,
    required bool smsNotifications,
    required bool pushNotifications,
    required bool whatsappNotifications,
  }) async {
    return authorizedRequest((token) {
      return http.patch(
        Uri.parse('${baseUrl}api/me/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email_notifications': emailNotifications,
          'sms_notifications': smsNotifications,
          'push_notifications': pushNotifications,
          'whatsapp_notifications': whatsappNotifications,
        }),
      );
    });
  }

  static Future<http.Response> getNotifications() async {
    return authorizedRequest((token) {
      return http.get(
        Uri.parse('${baseUrl}api/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    });
  }

  static Future<http.Response> updateProfile({
    String? phoneNumber,
    String? profilePicturePath,
  }) async {
    return authorizedRequest((token) async {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${baseUrl}api/me/'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add phone number if provided
      if (phoneNumber != null) {
        request.fields['phone_number'] = phoneNumber;
      }

      // Add profile picture if provided
      if (profilePicturePath != null) {
        final file = await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicturePath,
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
      }

      return response;
    });
  }

  static Future<http.Response> deleteProfile() async {
    return authorizedRequest((token) {
      return http.delete(
        Uri.parse('${baseUrl}api/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });
  }
}
