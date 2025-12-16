import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConfig {
  // ============================================
  // SERVER CONFIGURATION
  // ============================================
  
  // Production URL (Render deployment)
  static const String? productionBaseUrl = 'https://scanface-tztq.onrender.com/api';
  static const String? productionSocketUrl = 'https://scanface-tztq.onrender.com';
  
  // Local Development URLs
  static const String localBaseUrl = 'http://192.168.0.116:3000/api'; // Your Mac's IP
  static const String localSocketUrl = 'http://192.168.0.116:3000';
  
  // ============================================
  // SWITCH BETWEEN LOCAL AND PRODUCTION
  // ============================================
  // Set to true to use production (Render), false to use local
  // Or set manualBaseUrl/manualSocketUrl to override completely
  static const bool useProduction = false; // Change to true to use Render server
  
  // Manual override - set this if automatic detection doesn't work
  // Set to null to use automatic detection based on useProduction flag
  // For production: 'https://scanface-tztq.onrender.com/api'
  // For local: 'http://192.168.0.116:3000/api'
  static const String? manualBaseUrl = null; // Set to override all detection
  static const String? manualSocketUrl = null; // Set to override all detection
  
  // Detect platform and use appropriate URL
  static String get baseUrl {
    // Manual override takes priority (highest priority)
    if (manualBaseUrl != null) {
      return manualBaseUrl!;
    }
    
    // Use production URL if useProduction is true
    if (useProduction && productionBaseUrl != null) {
      return productionBaseUrl!;
    }
    
    // Use production URL if in release mode and production URL is set (fallback)
    if (kReleaseMode && productionBaseUrl != null && !useProduction) {
      return productionBaseUrl!;
    }
    
    // Local development URLs
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    
    // For Android (emulator or real device)
    if (Platform.isAndroid) {
      return localBaseUrl; // Uses your Mac's IP for real device
      // For Android Emulator, uncomment this instead:
      // return 'http://10.0.2.2:3000/api';
    }
    
    // For iOS (simulator or real device)
    if (Platform.isIOS) {
      return 'http://localhost:3000/api'; // iOS Simulator
      // For real iOS device, use:
      // return localBaseUrl;
    }
    
    // Default fallback to local
    return localBaseUrl;
  }
  
  static String get socketUrl {
    // Manual override takes priority (highest priority)
    if (manualSocketUrl != null) {
      return manualSocketUrl!;
    }
    
    // Use production URL if useProduction is true
    if (useProduction && productionSocketUrl != null) {
      return productionSocketUrl!;
    }
    
    // Use production URL if in release mode and production URL is set (fallback)
    if (kReleaseMode && productionSocketUrl != null && !useProduction) {
      return productionSocketUrl!;
    }
    
    // Local development URLs
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    
    if (Platform.isAndroid) {
      return localSocketUrl; // Uses your Mac's IP for real device
      // For Android Emulator, uncomment this instead:
      // return 'http://10.0.2.2:3000';
    }
    
    if (Platform.isIOS) {
      return 'http://localhost:3000'; // iOS Simulator
      // For real iOS device, use:
      // return localSocketUrl;
    }
    
    // Default fallback to local
    return localSocketUrl;
  }
  
  // Get server base URL (without /api) for health checks
  static String get serverBaseUrl {
    final apiUrl = baseUrl;
    // Remove /api from the end if present
    if (apiUrl.endsWith('/api')) {
      return apiUrl.substring(0, apiUrl.length - 4);
    }
    return apiUrl.replaceAll('/api', '');
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

