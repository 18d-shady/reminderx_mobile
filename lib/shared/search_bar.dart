import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../features/documents/models/particular_model.dart';
import '../features/documents/screens/document_view_page.dart';

class DocumentSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Isar isar;

  const DocumentSearchBar({
    super.key,
    required this.controller,
    required this.isar,
  });

  void _handleSearchTap(BuildContext context) {
    showSearch(context: context, delegate: DocumentSearchDelegate(isar: isar));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () => _handleSearchTap(context),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            enabled: false, // Disable direct input, handle tap instead
            decoration: InputDecoration(
              hintText: 'Search documents...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'InriaSans',
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(fontFamily: 'InriaSans'),
          ),
        ),
      ),
    );
  }
}

class DocumentSearchDelegate extends SearchDelegate<Particular?> {
  final Isar isar;

  DocumentSearchDelegate({required this.isar});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Particular>>(
      stream: isar.particulars
          .where()
          .filter()
          .titleMatches('*$query*', caseSensitive: false)
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!;

        if (documents.isEmpty) {
          return const Center(
            child: Text(
              'No documents found',
              style: TextStyle(fontFamily: 'InriaSans'),
            ),
          );
        }

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            return ListTile(
              title: Text(
                document.title,
                style: const TextStyle(fontFamily: 'InriaSans'),
              ),
              subtitle: Text(
                'Category: ${document.category}',
                style: const TextStyle(fontFamily: 'InriaSans'),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            DocumentViewPage(isar: isar, particular: document),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
