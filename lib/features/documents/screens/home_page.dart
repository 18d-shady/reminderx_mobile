import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:isar/isar.dart';
import '../../../shared/document_card.dart';
import '../../../shared/document_list.dart';
import '../models/particular_model.dart';

class HomePage extends StatefulWidget {
  final Isar isar;

  const HomePage({super.key, required this.isar});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: StreamBuilder<List<Particular>>(
          stream: widget.isar.particulars.where().watch(fireImmediately: true),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Error in HomePage: ${snapshot.error}');
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final particulars = snapshot.data ?? [];
            print(
              'Number of particulars: ${particulars.length}',
            ); // Debug print

            final now = DateTime.now();
            final thirtyDaysFromNow = now.add(const Duration(days: 30));
            final sevenDaysFromNow = now.add(const Duration(days: 7));

            // Count documents expiring within 30 days
            final expiringSoon =
                particulars.where((p) {
                  final expiryDate = p.expiryDate;
                  return expiryDate.isAfter(now) &&
                      expiryDate.isBefore(thirtyDaysFromNow);
                }).length;

            // Count documents expiring within 7 days
            final expiringInSevenDays =
                particulars.where((p) {
                  final expiryDate = p.expiryDate;
                  return expiryDate.isAfter(now) &&
                      expiryDate.isBefore(sevenDaysFromNow);
                }).length;

            // Count documents that are up to date (expiry > 30 days)
            final upToDate =
                particulars.where((p) {
                  final expiryDate = p.expiryDate;
                  return expiryDate.isAfter(thirtyDaysFromNow);
                }).length;

            final documentStats = [
              {
                'title': 'Total Documents',
                'subtitle':
                    particulars.isEmpty
                        ? 'No documents yet'
                        : '$expiringInSevenDays require immediate action',
                'number': '${particulars.length}',
                'icon': Icons.description_outlined,
              },
              {
                'title': 'Expiring Soon',
                'subtitle':
                    particulars.isEmpty
                        ? 'No documents expiring soon'
                        : '$expiringInSevenDays require immediate action',
                'number': '$expiringSoon',
                'icon': Icons.warning_amber_outlined,
              },
              {
                'title': 'Up to Date',
                'subtitle':
                    particulars.isEmpty
                        ? 'No up-to-date documents'
                        : 'No action required',
                'number': '$upToDate',
                'icon': Icons.check_circle_outline,
              },
            ];

            return SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  200, // Adjust for top bar and bottom nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 200,
                    child:
                        particulars.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No documents yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Click the add button to add documents',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : FlutterCarousel(
                              options: CarouselOptions(
                                height: 200,
                                viewportFraction: 1.0,
                                enableInfiniteScroll: false,
                                autoPlay: true,
                                showIndicator: true,
                                slideIndicator: CircularSlideIndicator(),
                              ),
                              items:
                                  documentStats.map((stat) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: DocumentCard(
                                        title: stat['title'] as String,
                                        subtitle: stat['subtitle'] as String,
                                        number: stat['number'] as String,
                                        icon: stat['icon'] as IconData,
                                        onTap: () {
                                          // Handle card tap
                                        },
                                      ),
                                    );
                                  }).toList(),
                            ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: DocumentList(isar: widget.isar, showTabs: true),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
