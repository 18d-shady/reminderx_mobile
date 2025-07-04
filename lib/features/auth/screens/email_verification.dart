import 'package:flutter/material.dart';
import 'package:reminderx_mobile/features/auth/services/auth_service.dart';
import 'package:reminderx_mobile/features/documents/screens/main_screen.dart';
import 'package:reminderx_mobile/features/auth/exceptions/auth_exceptions.dart';
import 'package:reminderx_mobile/features/documents/services/sync_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  const EmailVerificationScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  List<String> otpDigits = List.filled(6, '');
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  String? errorMessage;
  bool isLoading = false;
  int resendCooldown = 30;
  int otpTimer = 600; // 10 minutes

  @override
  void initState() {
    super.initState();
    startResendCooldown();
    startOtpTimer();
  }

  void startResendCooldown() {
    setState(() {
      resendCooldown = 30;
    });
    Future.doWhile(() async {
      if (resendCooldown > 0) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          resendCooldown--;
        });
        return true;
      }
      return false;
    });
  }

  void startOtpTimer() {
    setState(() {
      otpTimer = 600;
    });
    Future.doWhile(() async {
      if (otpTimer > 0) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          otpTimer--;
        });
        return true;
      }
      return false;
    });
  }

  void handleOtpChange(int idx, String value) {
    if (value.length > 1) value = value.substring(value.length - 1);
    if (!RegExp(r'^[0-9]? 0$').hasMatch(value)) return;
    setState(() {
      otpDigits[idx] = value;
    });
    if (value.isNotEmpty && idx < 5) {
      focusNodes[idx + 1].requestFocus();
    }
    if (value.isEmpty && idx > 0) {
      focusNodes[idx - 1].requestFocus();
    }
  }

  void handlePaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '').split('').take(6).toList();
    if (digits.length == 6) {
      setState(() {
        otpDigits = digits;
      });
      focusNodes[5].requestFocus();
    }
  }

  Future<void> handleVerify() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });
    final otp = otpDigits.join();
    try {
      final success = await AuthService().register(
        widget.username,
        widget.email,
        widget.password,
        otp,
      );
      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
        SyncService().fetchAndStoreAll();
      }
    } on AuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid or expired OTP. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleResend() async {
    setState(() {
      errorMessage = null;
    });
    try {
      await AuthService().sendVerificationEmail(widget.username, widget.email);
      startResendCooldown();
      startOtpTimer();
      setState(() {
        errorMessage = 'A new OTP has been sent to your email.';
      });
    } on AuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to resend OTP. Please try again.';
      });
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
            'assets/images/signup_background.png',
            fit: BoxFit.cover,
          ),
          // Overlay
          Container(color: Colors.black.withOpacity(0.7)),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "InknutAntiqua",
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'We sent a code to your email',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (idx) {
                      return Container(
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          focusNode: focusNodes[idx],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 24, letterSpacing: 2),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => handleOtpChange(idx, val),
                          onTap: () => focusNodes[idx].requestFocus(),
                          onSubmitted: (val) {
                            if (idx < 5 && val.isNotEmpty) {
                              focusNodes[idx + 1].requestFocus();
                            }
                          },
                          onEditingComplete: () {},
                          inputFormatters: [],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    otpTimer > 0
                        ? 'OTP expires in ${otpTimer ~/ 60}:${(otpTimer % 60).toString().padLeft(2, '0')}'
                        : 'OTP expired. Please resend.',
                    style: TextStyle(
                      color: otpTimer > 0 ? Colors.black54 : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive OTP? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: resendCooldown > 0 ? null : handleResend,
                        child: Text(
                          resendCooldown > 0 ? 'Resend (${resendCooldown}s)' : 'Resend',
                          style: TextStyle(
                            color: resendCooldown > 0 ? Colors.grey : primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                      onPressed: isLoading || otpDigits.any((d) => d.isEmpty) || otpTimer == 0
                          ? null
                          : handleVerify,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(fontFamily: "InriaSans"),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 