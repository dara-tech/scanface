import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'socket_service.dart';
import '../providers/auth_provider.dart';
import '../models/attendance_model.dart';

class AttendanceApiService {
  final ApiService _apiService = ApiService();
  
  // Check-in using API
  Future<Map<String, dynamic>> checkIn({
    String? userId,
    double? latitude,
    double? longitude,
    String? address,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiService.checkIn(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      if (response.statusCode == 201) {
        // Also emit via WebSocket for real-time updates
        if (context != null) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final socketService = authProvider.socketService;
          if (socketService.isConnected) {
            socketService.emitCheckIn(
              latitude: latitude,
              longitude: longitude,
              address: address,
            );
          }
        }

        return {
          'success': true,
          'attendance': response.data['attendance'],
          'message': response.data['message'] ?? 'Checked in successfully',
        };
      } else {
        throw Exception(response.data['error'] ?? 'Check-in failed');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Check-out using API
  Future<Map<String, dynamic>> checkOut({
    String? attendanceId,
    String? userId,
    double? latitude,
    double? longitude,
    String? address,
    BuildContext? context,
  }) async {
    try {
      final response = await _apiService.checkOut(
        attendanceId: attendanceId,
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      if (response.statusCode == 200) {
        // Also emit via WebSocket for real-time updates
        if (context != null) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final socketService = authProvider.socketService;
          if (socketService.isConnected) {
            socketService.emitCheckOut(
              attendanceId: attendanceId,
              latitude: latitude,
              longitude: longitude,
              address: address,
            );
          }
        }

        return {
          'success': true,
          'attendance': response.data['attendance'],
          'message': response.data['message'] ?? 'Checked out successfully',
        };
      } else {
        throw Exception(response.data['error'] ?? 'Check-out failed');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get today's attendance
  Future<Map<String, dynamic>?> getTodayAttendance({String? userId}) async {
    try {
      final response = await _apiService.getTodayAttendance(userId: userId);
      if (response.statusCode == 200) {
        return response.data['attendance'];
      }
      return null;
    } catch (e) {
      print('Error getting today attendance: $e');
      return null;
    }
  }

  // Get attendance history
  Future<List<Map<String, dynamic>>> getAttendanceHistory({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.getAttendanceHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final List<dynamic> attendanceList = response.data['attendance'] ?? [];
        return attendanceList.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting attendance history: $e');
      return [];
    }
  }

  // Get attendance statistics
  Future<Map<String, dynamic>?> getAttendanceStats({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiService.getAttendanceStats(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.statusCode == 200) {
        return response.data['stats'];
      }
      return null;
    } catch (e) {
      print('Error getting attendance stats: $e');
      return null;
    }
  }
}

