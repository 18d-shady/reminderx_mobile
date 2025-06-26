import 'package:flutter/material.dart';
import 'dart:io';

class TopBar extends StatelessWidget {
  final String? profileImageUrl;
  final String userName;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onAddTap;
  final VoidCallback onSyncTap;
  final bool isSyncing;

  const TopBar({
    super.key,
    this.profileImageUrl,
    required this.userName,
    this.notificationCount = 0,
    required this.onNotificationTap,
    required this.onAddTap,
    required this.onSyncTap,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          // Profile Section
          Row(
            children: [
              _buildProfileImage(profileImageUrl),
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
              // Sync Button
              _SyncIconButton(onTap: onSyncTap, isSyncing: isSyncing),
              const SizedBox(width: 8),
              // Notification Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
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
                      icon: const Icon(Icons.notifications_outlined, size: 20),
                      color: Colors.black,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            notificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
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
              const SizedBox(width: 8),
              // Add Button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(100),
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
                  icon: const Icon(Icons.add, size: 20),
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? profileImagePath) {
    if (profileImagePath == null) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.person, color: Colors.grey[600]),
      );
    }

    final file = File(profileImagePath);
    if (file.existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(file),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading profile image: $exception');
        },
      );
    }

    // Fallback to default icon if file doesn't exist
    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      child: Icon(Icons.person, color: Colors.grey[600]),
    );
  }
}

class _SyncIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isSyncing;
  const _SyncIconButton({required this.onTap, required this.isSyncing});

  @override
  State<_SyncIconButton> createState() => _SyncIconButtonState();
}

class _SyncIconButtonState extends State<_SyncIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isSyncing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _SyncIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isSyncing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onTap,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 6.28319, // 2 * pi
            child: child,
          );
        },
        child: const Icon(Icons.sync, size: 22, color: Colors.black54),
      ),
      splashRadius: 22,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      tooltip: 'Sync',
    );
  }
}
