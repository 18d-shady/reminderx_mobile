import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Color(0xFF8EB0D6),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_drive_file),
          label: 'Documents',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

/*
subprojects {
    afterEvaluate {
        plugins.withId("com.android.application") {
            extensions.configure<com.android.build.gradle.AppExtension>("android") {
                compileSdkVersion(34)
                buildToolsVersion = "34.0.0"
            }
        }

        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                compileSdkVersion(34)
                buildToolsVersion = "34.0.0"
            }
        }

        extensions.findByName("android")?.let { ext ->
            (ext as? com.android.build.gradle.BaseExtension)?.apply {
                if (namespace == null) {
                    namespace = "com.bluewhale.reminderx_mobile" // replace as needed
                }
            }
        }
    }
}
*/
