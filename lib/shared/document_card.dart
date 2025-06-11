import 'package:flutter/material.dart';

class DocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String number;
  final IconData icon;
  final VoidCallback? onTap;

  const DocumentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.number,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Text content with full height
            Expanded(
              child: SizedBox(
                height: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title at the top
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InriaSans',
                      ),
                    ),
                    const Spacer(),
                    // Number in the middle
                    Text(
                      number,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontFamily: 'InriaSans',
                      ),
                    ),
                    const Spacer(),
                    // Subtitle at the bottom
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontFamily: 'InriaSans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right side - Icon at the top
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }
}
