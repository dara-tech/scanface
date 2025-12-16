import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConfig {
  // Production URL (Render or other hosting)
  // Set this to your deployed backend URL, e.g., 'https://your-app-name.onrender.com'
  static const String? productionBaseUrl = null; // e.g., 'https://your-app-name.onrender.com/api'
  static const String? productionSocketUrl = null; // e.g., 'https://your-app-name.onrender.com'
  
  // Manual override - set this if automatic detection doesn't work
  // For real Android device, use your Mac's IP: 'http://192.168.0.116:3000'
  // For production, set to your Render URL: 'https://your-app-name.onrender.com/api'
  static const String? manualBaseUrl = null; // Set to override, e.g., 'http://192.168.0.116:3000/api'
  static const String? manualSocketUrl = null; // Set to override, e.g., 'http://192.168.0.116:3000'
  
  // Detect platform and use appropriate URL
  static String get baseUrl {
    // Manual override takes priority
    if (manualBaseUrl != null) {
      return manualBaseUrl!;
    }
    
    // Use production URL if in release mode and production URL is set
    if (kReleaseMode && productionBaseUrl != null) {
      return productionBaseUrl!;
    }
    
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    
    // For Android (emulator or real device)
    if (Platform.isAndroid) {
      // For Android Emulator, use 10.0.2.2
      // For real Android device, use your Mac's IP (192.168.0.116)
      // TODO: Detect if emulator or real device, or use manual override
      // For now, using Mac IP for real device (TB350XU)
      return 'http://192.168.0.116:3000/api'; // Real Android device
      // return 'http://10.0.2.2:3000/api'; // Android Emulator - uncomment if using emulator
    }
    
    // For iOS (simulator or real device)
    if (Platform.isIOS) {
      // iOS Simulator can use localhost
      // Real iOS device needs Mac's IP
      return 'http://localhost:3000/api'; // iOS Simulator
      // return 'http://192.168.0.116:3000/api'; // Real iOS device - uncomment and use your Mac's IP
    }
    
    // Default fallback
    return 'http://localhost:3000/api';
  }
  
  static String get socketUrl {
    // Manual override takes priority
    if (manualSocketUrl != null) {
      return manualSocketUrl!;
    }
    
    // Use production URL if in release mode and production URL is set
    if (kReleaseMode && productionSocketUrl != null) {
      return productionSocketUrl!;
    }
    
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    
    if (Platform.isAndroid) {
      return 'http://192.168.0.116:3000'; // Real Android device
      // return 'http://10.0.2.2:3000'; // Android Emulator - uncomment if using emulator
    }
    
    if (Platform.isIOS) {
      return 'http://localhost:3000'; // iOS Simulator
      // return 'http://192.168.0.116:3000'; // Real iOS device
    }
    
    return 'http://localhost:3000';
  }
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

