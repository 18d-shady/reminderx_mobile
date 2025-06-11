import 'package:flutter/material.dart';
import 'package:reminderx_mobile/features/auth/services/auth_service.dart';
import 'package:reminderx_mobile/features/documents/screens/main_screen.dart';
import 'package:reminderx_mobile/features/auth/exceptions/auth_exceptions.dart';
import 'package:reminderx_mobile/features/documents/services/sync_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  void _signup() async {
    // Validate inputs
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (passwordController.text.length < 5) {
      setState(() {
        errorMessage = 'Password must be at least 8 characters long';
      });
      return;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
      setState(() {
        errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final success = await AuthService().register(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        SyncService().fetchAndStoreAll();
      }
    } on NetworkException {
      setState(() {
        errorMessage =
            'Network connection error. Please check your internet connection.';
      });
    } on AuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF8EB0D6);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('assets/images/signup_background.png', fit: BoxFit.cover),
          // Overlay
          Container(color: Colors.black.withOpacity(0.7)),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "REMINDER",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "InknutAntiqua",
                          ),
                        ),
                        TextSpan(
                          text: "X",
                          style: TextStyle(
                            fontSize: 26,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: "InknutAntiqua",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Welcome Message
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Create Your Account',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "InknutAntiqua",
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join us and stay organized!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontFamily: "InriaSans",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Form
                  TextField(
                    controller: usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      labelText: 'Username',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: "InriaSans",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      labelText: 'Email',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: "InriaSans",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: "InriaSans",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      labelText: 'Confirm Password',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontFamily: "InriaSans",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoading ? null : _signup,
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                              : const Text(
                                'Sign Up',
                                style: TextStyle(fontFamily: "InriaSans"),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Already have an account? Log in",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
