import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../exceptions/auth_exceptions.dart';

class AuthService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

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
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${baseUrl}api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(
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
        throw TokenExpiredException();
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

  // Login
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw NetworkException();
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access'], data['refresh']);
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
  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(
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
          throw AuthException('Username already exists', code: 'USERNAME_EXISTS');
        } else if (data['email'] != null) {
          throw AuthException('Email already exists', code: 'EMAIL_EXISTS');
        } else {
          throw AuthException('Invalid registration data', code: 'INVALID_DATA');
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
