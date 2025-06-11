import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/documents/screens/main_screen.dart';
import 'features/auth/services/auth_service.dart'; // Simulated auth check
import 'features/auth/screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoggedIn() async {
    // Replace with real storage/auth logic
    await Future.delayed(const Duration(seconds: 1));
    return await AuthService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReminderX',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        // Add other named screens like '/home', '/settings' as you create them
      },
      home: FutureBuilder<bool>(
        future: checkLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data == true
              ? const MainScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
