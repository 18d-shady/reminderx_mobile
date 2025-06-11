import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String? profileImageUrl;
  final String userName;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onAddTap;

  const TopBar({
    super.key,
    this.profileImageUrl,
    required this.userName,
    this.notificationCount = 0,
    required this.onNotificationTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Profile Section
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'InriaSans',
                        ),
                  ),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontFamily: 'InriaSans',
                        ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Action Buttons
          Row(
            children: [
              // Notification Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    IconButton(
                      onPressed: onNotificationTap,
                      icon: const Icon(Icons.notifications_outlined),
                      color: Colors.black,
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            notificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'InriaSans',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Add Button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onAddTap,
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 