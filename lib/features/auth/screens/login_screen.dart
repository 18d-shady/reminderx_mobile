import 'package:flutter/material.dart';
import 'package:reminderx_mobile/features/auth/services/auth_service.dart';
import 'package:reminderx_mobile/features/documents/screens/main_screen.dart';
import 'package:reminderx_mobile/features/auth/exceptions/auth_exceptions.dart';
import 'package:reminderx_mobile/features/documents/services/sync_service.dart';
import 'package:reminderx_mobile/features/auth/screens/reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  bool _obscurePassword = true;


  void _login() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter both username and password';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final success = await AuthService().login(
        usernameController.text.trim(),
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
    } on InvalidCredentialsException {
      setState(() {
        errorMessage = 'Invalid username or password.';
      });
    } on ServerException {
      setState(() {
        errorMessage = 'Server error. Please try again later.';
      });
    } on UnknownException {
      setState(() {
        errorMessage = 'Invalid username or password!';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() async {
    final enteredEmail = usernameController.text.trim();
    if (enteredEmail.isEmpty) {
      setState(() {
        errorMessage =
            'Please enter your email in the field above to reset your password.';
      });
      return;
    }
    // If email is already entered, use it directly
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final success = await AuthService().requestPasswordReset(enteredEmail);
      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: enteredEmail),
          ),
        );
      }
    } on NetworkException {
      setState(() {
        errorMessage = 'Network error. Please try again.';
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
          Image.asset(
            'assets/images/login_background.png', // Make sure this exists
            fit: BoxFit.cover,
          ),
          // Overlay
          Container(color: Colors.black.withOpacity(0.7)),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/naikas_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Text(
                        'NAIKAS',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "InknutAntiqua",
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  // Welcome Message
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Welcome Back, Buddy',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "InknutAntiqua",
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log in to access your account now!',
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
                      labelText: 'Username or Email',
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
                    obscureText: _obscurePassword,
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: "InriaSans",
                        ),
                      ),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
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
                      onPressed: isLoading ? null : _login,
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                              : const Text(
                                'Log In',
                                style: TextStyle(fontFamily: "InriaSans"),
                              ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: const Text(
                        "Don't have an account? Sign up",
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
