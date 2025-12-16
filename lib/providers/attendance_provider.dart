import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/attendance_api_service.dart';
import '../services/attendance_service.dart'; // Keep for fallback

class AttendanceProvider with ChangeNotifier {
  final AttendanceApiService _apiService = AttendanceApiService();
  final AttendanceService _localService = AttendanceService(); // Fallback
  Attendance? _todayAttendance;
  List<Attendance> _attendanceHistory = [];
  AttendanceStats? _stats;
  bool _isLoading = false;
  final bool _useBackend = true; // Toggle between backend and local

  Attendance? get todayAttendance => _todayAttendance;
  List<Attendance> get attendanceHistory => _attendanceHistory;
  AttendanceStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> loadTodayAttendance(String userId, {BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useBackend) {
        final result = await _apiService.getTodayAttendance(userId: userId);
        if (result != null) {
          _todayAttendance = _convertApiToAttendance(result);
        } else {
          _todayAttendance = null;
        }
      } else {
        _todayAttendance = await _localService.getTodayAttendance(userId);
      }
    } catch (e) {
      print('Error loading today attendance: $e');
      // Fallback to local if backend fails
      if (_useBackend) {
        try {
          _todayAttendance = await _localService.getTodayAttendance(userId);
        } catch (e2) {
          print('Local fallback also failed: $e2');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper to safely use context
  bool get _hasValidContext => true; // Context is optional, so this is fine

  Future<void> checkIn(String userId, {BuildContext? context, double? latitude, double? longitude}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useBackend) {
        final result = await _apiService.checkIn(
          userId: userId,
          latitude: latitude,
          longitude: longitude,
          context: context,
        );
        
        if (result['success']) {
          final attendanceData = result['attendance'];
          _todayAttendance = _convertApiToAttendance(attendanceData);
          await loadTodayAttendance(userId, context: context);
        } else {
          throw Exception(result['error'] ?? 'Check-in failed');
        }
      } else {
        _todayAttendance = await _localService.checkIn(userId);
        await loadTodayAttendance(userId);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkOut(String userId, {BuildContext? context, String? attendanceId, double? latitude, double? longitude}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useBackend) {
        final result = await _apiService.checkOut(
          attendanceId: attendanceId,
          userId: userId,
          latitude: latitude,
          longitude: longitude,
          context: context,
        );
        
        if (result['success']) {
          final attendanceData = result['attendance'];
          _todayAttendance = _convertApiToAttendance(attendanceData);
          await loadTodayAttendance(userId, context: context);
        } else {
          throw Exception(result['error'] ?? 'Check-out failed');
        }
      } else {
        _todayAttendance = await _localService.checkOut(userId);
        await loadTodayAttendance(userId);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Convert API response to Attendance model
  Attendance _convertApiToAttendance(Map<String, dynamic> data) {
    final userIdData = data['userId'];
    String userId;
    
    if (userIdData is String) {
      userId = userIdData;
    } else if (userIdData is Map) {
      userId = userIdData['_id']?.toString() ?? userIdData['id']?.toString() ?? '';
    } else {
      userId = '';
    }
    
    // Parse location if available
    double? latitude;
    double? longitude;
    if (data['checkInLocation'] != null) {
      latitude = data['checkInLocation']['latitude']?.toDouble();
      longitude = data['checkInLocation']['longitude']?.toDouble();
    }
    
    return Attendance(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      userId: userId,
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      checkInTime: data['checkInTime'] != null ? DateTime.parse(data['checkInTime']) : null,
      checkOutTime: data['checkOutTime'] != null ? DateTime.parse(data['checkOutTime']) : null,
      status: _parseStatus(data['status'] ?? 'present'),
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    );
  }

  AttendanceStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      case 'absent':
        return AttendanceStatus.absent;
      case 'half-day':
      case 'halfday':
        return AttendanceStatus.halfDay;
      default:
        return AttendanceStatus.present;
    }
  }

  Future<void> loadAttendanceHistory(String userId, {DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useBackend) {
        final history = await _apiService.getAttendanceHistory(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );
        _attendanceHistory = history.map((item) => _convertApiToAttendance(item)).toList();
      } else {
        _attendanceHistory = await _localService.getUserAttendanceHistory(
          userId,
          startDate: startDate,
          endDate: endDate,
        );
      }
    } catch (e) {
      print('Error loading attendance history: $e');
      // Fallback to local
      if (_useBackend) {
        try {
          _attendanceHistory = await _localService.getUserAttendanceHistory(
            userId,
            startDate: startDate,
            endDate: endDate,
          );
        } catch (e2) {
          print('Local fallback failed: $e2');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStats(String userId, {DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useBackend) {
        final statsData = await _apiService.getAttendanceStats(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );
        if (statsData != null) {
          final totalDays = statsData['totalDays'] ?? 0;
          final presentDays = statsData['presentDays'] ?? 0;
          final lateDays = statsData['lateDays'] ?? 0;
          final totalWorkingHoursMinutes = statsData['totalWorkingHours'] ?? 0;
          final totalWorkingHours = (totalWorkingHoursMinutes / 60.0).round();
          final averageWorkingHours = totalDays > 0 ? totalWorkingHours / totalDays : 0.0;
          
          _stats = AttendanceStats(
            present: presentDays,
            late: lateDays,
            absent: totalDays - presentDays,
            totalDays: totalDays,
            totalWorkingHours: totalWorkingHours,
            averageWorkingHours: averageWorkingHours,
          );
        }
      } else {
        _stats = await _localService.getAttendanceStats(
          userId,
          startDate: startDate,
          endDate: endDate,
        );
      }
    } catch (e) {
      print('Error loading stats: $e');
      // Fallback to local
      if (_useBackend) {
        try {
          _stats = await _localService.getAttendanceStats(
            userId,
            startDate: startDate,
            endDate: endDate,
          );
        } catch (e2) {
          print('Local fallback failed: $e2');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Attendance>> loadAllAttendanceForAdmin({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, use local service for admin view
      // TODO: Implement admin API endpoint
      final allAttendance = await _localService.getAllAttendance(
        startDate: startDate,
        endDate: endDate,
      );
      return allAttendance;
    } catch (e) {
      print('Error loading all attendance: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _todayAttendance = null;
    _attendanceHistory = [];
    _stats = null;
    notifyListeners();
  }
}

