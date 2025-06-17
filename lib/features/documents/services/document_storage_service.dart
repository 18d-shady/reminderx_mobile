import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class DocumentStorageService {
  static Future<String> downloadAndSaveDocument(String documentUrl, String docId) async {
    try {
      // Get the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final documentsDir = Directory('${appDir.path}/documents');
      
      // Create documents directory if it doesn't exist
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      // Get original filename from URL
      final originalFileName = path.basename(documentUrl);
      final filePath = '${documentsDir.path}/$originalFileName';

      // Download the file
      final response = await http.get(Uri.parse(documentUrl));
      if (response.statusCode == 200) {
        // Save the file (will overwrite if exists)
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving document: $e');
    }
  }

  static Future<String> downloadAndSaveProfilePicture(String profilePictureUrl) async {
    try {
      // Get the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final profilePicturesDir = Directory('${appDir.path}/profile_pictures');
      
      // Create profile pictures directory if it doesn't exist
      if (!await profilePicturesDir.exists()) {
        await profilePicturesDir.create(recursive: true);
      }

      // Get original filename from URL
      final originalFileName = path.basename(profilePictureUrl);
      final filePath = '${profilePicturesDir.path}/$originalFileName';

      // Download the file
      final response = await http.get(Uri.parse(profilePictureUrl));
      if (response.statusCode == 200) {
        // Save the file (will overwrite if exists)
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download profile picture: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving profile picture: $e');
    }
  }

  static Future<void> deleteLocalDocument(String? filePath) async {
    if (filePath != null) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting local document: $e');
      }
    }
  }

  static Future<void> deleteLocalProfilePicture(String? filePath) async {
    if (filePath != null) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting local profile picture: $e');
      }
    }
  }
} 