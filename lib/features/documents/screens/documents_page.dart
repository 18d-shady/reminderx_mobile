import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../shared/document_list.dart';

class DocumentsPage extends StatelessWidget {
  final Isar isar;

  const DocumentsPage({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        // Document List
        Expanded(child: DocumentList(isar: isar, showTabs: true)),
      ],
    );
  }
}
