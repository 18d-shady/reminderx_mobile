import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../exceptions/auth_exceptions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // Global navigator key for handling navigation from anywhere
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Save tokens
  static Future<void> saveTokens(String access, String refresh) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, access);
      await prefs.setString(_refreshTokenKey, refresh);
    } catch (e) {
      throw UnknownException();
    }
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      throw UnknownException();
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      throw UnknownException();
    }
  }

  // Check login status
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Clear tokens (logout)
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (e) {
      throw UnknownException();
    }
  }

  // Refresh access token
  static Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        await forceLogin(); // Use forceLogin instead of just logout
        return false;
      }

      final response = await http
          .post(
            Uri.parse('${baseUrl}api/token/refresh/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw NetworkException();
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access'], refreshToken);
        return true;
      } else if (response.statusCode == 401) {
        await forceLogin(); // Use forceLogin instead of just logout
        throw TokenExpiredException();
      } else if (response.statusCode >= 500) {
        throw ServerException();
      } else {
        await forceLogin(); // Use forceLogin instead of just logout
        throw UnknownException();
      }
    } on SocketException {
      throw NetworkException();
    } on FormatException {
      throw ServerException();
    } catch (e) {
      if (e is AuthException) rethrow;
      await forceLogin(); // Use forceLogin instead of just logout
      throw UnknownException();
    }
  }

  // Force login - clears tokens and navigates to login screen
  static Future<bool> forceLogin() async {
    await logout();

    // Navigate to login screen and remove all previous routes
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login', // Make sure this matches your login route name
      (route) => false,
    );

    return false;
  }

  // Register FCM token with backend
  Future<void> registerFcmTokenWithBackend(String accessToken) async {
    try {
      // Request permissions (iOS only, safe to call on Android)
      await FirebaseMessaging.instance.requestPermission();

      // Get the FCM token
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        final platform =
            Platform.isAndroid
                ? 'android'
                : Platform.isIOS
                ? 'ios'
                : 'unknown';
        final response = await http.post(
          Uri.parse('${baseUrl}api/fcm-token/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'token': token, 'platform': platform}),
        );
        if (response.statusCode == 200) {
          print('FCM token registered successfully');
        } else {
          print('Failed to register FCM token: \\${response.body}');
        }
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}api/token/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw NetworkException();
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access'], data['refresh']);
        await registerFcmTokenWithBackend(data['access']);
        // Listen for FCM token refreshes and re-register
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          final accessToken = await getAccessToken();
          if (accessToken != null) {
            await registerFcmTokenWithBackend(accessToken);
          }
        });
        return true;
      } else if (response.statusCode == 401) {
        throw InvalidCredentialsException();
      } else if (response.statusCode >= 500) {
        throw ServerException();
      } else {
        throw UnknownException();
      }
    } on SocketException {
      throw NetworkException();
    } on FormatException {
      throw ServerException();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownException();
    }
  }

  // Register
  Future<bool> register(
    String username,
    String email,
    String password,
    String otp,
  ) async {
    try {
      final body = {
        'username': username,
        'email': email,
        'password': password,
        'otp': otp,
      };
      final response = await http
          .post(
            Uri.parse('${baseUrl}api/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw NetworkException();
            },
          );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access'], data['refresh']);
        return true;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        if (data['username'] != null) {
          throw AuthException(
            'Username already exists',
            code: 'USERNAME_EXISTS',
          );
        } else if (data['email'] != null) {
          throw AuthException('Email already exists', code: 'EMAIL_EXISTS');
        } else {
          throw AuthException(
            'Invalid registration data',
            code: 'INVALID_DATA',
          );
        }
      } else if (response.statusCode >= 500) {
        throw ServerException();
      } else {
        throw UnknownException();
      }
    } on SocketException {
      throw NetworkException();
    } on FormatException {
      throw ServerException();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownException();
    }
  }

  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}api/password_reset/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw NetworkException();
            },
          );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw AuthException(
          data['detail'] ?? 'Invalid email address',
          code: 'INVALID_EMAIL',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException();
      } else {
        throw UnknownException();
      }
    } on SocketException {
      throw NetworkException();
    } on FormatException {
      throw ServerException();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownException();
    }
  }

  // Confirm password reset (with token and new password)
  Future<bool> confirmPasswordReset(String token, String newPassword) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}api/password_reset/confirm/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token, 'password': newPassword}),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw NetworkException();
            },
          );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw AuthException(
          data['detail'] ?? 'Invalid token or password, ensure password is not the same as the old one',
          code: 'INVALID_DATA',
        );
      } else if (response.statusCode >= 500) {
        throw ServerException();
      } else {
        throw UnknownException();
      }
    } on SocketException {
      throw NetworkException();
    } on FormatException {
      throw ServerException();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownException();
    }
  }

  // Send verification email (OTP) with username and email
  Future<void> sendVerificationEmail(String username, String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}api/verify-email/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'email': email}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw NetworkException();
            },
          );
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          if (data['error'].toString().contains('Username')) {
            throw AuthException(data['error'], code: 'USERNAME_EXISTS');
          } else if (data['error'].toString().contains('Email')) {
            throw AuthException(data['error'], code: 'EMAIL_EXISTS');
          } else {
            throw AuthException(data['error']);
          }
        } else {
          throw AuthException('Invalid data', code: 'INVALID_DATA');
        }
      } else if (response.statusCode >= 500) {
        throw ServerException();
      } else {
        throw UnknownException();
      }
    } on SocketException {
      throw NetworkException();
    } on FormatException {
      throw ServerException();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownException();
    }
  }
}
