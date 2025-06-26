/*
import 'dart:io';
import 'package:flutter/foundation.dart';


String get baseUrl {
  if (kDebugMode) {
    if (Platform.isAndroid) {
      // Check if running on emulator
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        return 'http://10.0.2.2:8000/'; // Android Emulator
      }
      // For physical Android device, use your computer's IP address
      return 'http://192.168.80.96:8000/'; // Your PC's IP on the hotspot network
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/'; // iOS Simulator
    }
  }
  // Production URL
  return 'https://your-production-api.com/';
}
*/
const String baseUrl = 'https://naikas.com/';
// Add other constants here
