import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:isar/isar.dart';
import '../../../shared/document_card.dart';
import '../../../shared/document_list.dart';
import '../models/particular_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

            // Count expired documents
            final expiredDocuments =
                particulars.where((p) => p.expiryDate.isBefore(now)).length;

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
                        : expiredDocuments > 0
                        ? '$expiredDocuments documents expired'
                        : '$expiringInSevenDays require immediate action',
                'number': '${particulars.length}',
                'iconPath': 'assets/images/total.svg',
              },
              {
                'title': 'Expiring Soon',
                'subtitle':
                    particulars.isEmpty
                        ? 'No documents expiring soon'
                        : '$expiringInSevenDays require immediate action',
                'number': '$expiringSoon',
                'iconPath': 'assets/images/expiring.svg',
              },
              {
                'title': 'Up to Date',
                'subtitle':
                    particulars.isEmpty
                        ? 'No up-to-date documents'
                        : 'No action required',
                'number': '$upToDate',
                'iconPath': 'assets/images/uptodate.svg',
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
                    height: 160,
                    child:
                        particulars.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/no-documents.svg',
                                    width: 48,
                                    height: 48,
                                    colorFilter: ColorFilter.mode(
                                      Colors.grey[400]!,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No documents yet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Click the add button to add documents',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : FlutterCarousel(
                              options: CarouselOptions(
                                height: 160,
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
                                        iconPath: stat['iconPath'] as String,
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
