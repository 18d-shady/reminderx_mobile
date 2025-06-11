import 'dart:convert';
import 'package:reminderx_mobile/features/documents/services/document_api_service.dart';

Future<void> loadDocuments() async {
  final response = await DocumentApiService.getDocuments();

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    // Use the data (e.g., update state)
    print("Documents: $data");
  } else {
    // Show error message
    print("Failed to load documents. Status: ${response.statusCode}");
  }
}
