import 'package:uuid/uuid.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class AttendanceService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final _uuid = const Uuid();

  // Record check-in
  Future<Attendance> checkIn(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if attendance already exists for today
    Attendance? todayAttendance = await _databaseService.getTodayAttendance(userId);

    if (todayAttendance != null && todayAttendance.checkInTime != null) {
      throw Exception('You have already checked in today');
    }

    // Determine status (late or on time)
    final scheduledTime = _parseTime(AppConstants.defaultCheckInTime);
    final isLate = now.isAfter(scheduledTime.add(Duration(
      minutes: AppConstants.lateThresholdMinutes,
    )));

    final status = isLate ? AttendanceStatus.late : AttendanceStatus.present;

    final attendance = Attendance(
      id: _uuid.v4(),
      userId: userId,
      date: today,
      checkInTime: now,
      status: status,
      createdAt: now,
    );

    if (todayAttendance != null) {
      // Update existing attendance record
      final updated = todayAttendance.copyWith(
        checkInTime: now,
        status: status,
      );
      await _databaseService.updateAttendance(updated);
      return updated;
    } else {
      // Create new attendance record
      await _databaseService.insertAttendance(attendance);
      return attendance;
    }
  }

  // Get today's attendance for a user
  Future<Attendance?> getTodayAttendance(String userId) async {
    return await _databaseService.getTodayAttendance(userId);
  }

  // Record check-out
  Future<Attendance> checkOut(String userId) async {
    final now = DateTime.now();
    final todayAttendance = await _databaseService.getTodayAttendance(userId);

    if (todayAttendance == null || todayAttendance.checkInTime == null) {
      throw Exception('Please check in first');
    }

    if (todayAttendance.checkOutTime != null) {
      throw Exception('You have already checked out today');
    }

    final updated = todayAttendance.copyWith(
      checkOutTime: now,
    );

    await _databaseService.updateAttendance(updated);
    return updated;
  }

  // Get user's attendance history
  Future<List<Attendance>> getUserAttendanceHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _databaseService.getAttendanceByUserId(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Get all attendance records (for admin)
  Future<List<Attendance>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _databaseService.getAllAttendance(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Get today's attendance status
  Future<AttendanceStatus> getTodayStatus(String userId) async {
    final attendance = await _databaseService.getTodayAttendance(userId);
    
    if (attendance == null) {
      return AttendanceStatus.absent;
    }

    return attendance.status;
  }

  // Calculate attendance statistics
  Future<AttendanceStats> getAttendanceStats(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final attendanceList = await getUserAttendanceHistory(
      userId,
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate: endDate ?? DateTime.now(),
    );

    int present = 0;
    int late = 0;
    int absent = 0;
    int totalWorkingHours = 0;
    int totalWorkingMinutes = 0;

    for (final attendance in attendanceList) {
      switch (attendance.status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.late:
          late++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        default:
          break;
      }

      if (attendance.workingHours != null) {
        totalWorkingMinutes += attendance.workingHours!.inMinutes;
      }
    }

    totalWorkingHours = totalWorkingMinutes ~/ 60;

    return AttendanceStats(
      present: present,
      late: late,
      absent: absent,
      totalDays: attendanceList.length,
      totalWorkingHours: totalWorkingHours,
      averageWorkingHours: attendanceList.isNotEmpty
          ? (totalWorkingHours / attendanceList.length)
          : 0.0,
    );
  }

  // Parse time string (HH:mm) to DateTime for today
  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

// Attendance statistics
class AttendanceStats {
  final int present;
  final int late;
  final int absent;
  final int totalDays;
  final int totalWorkingHours;
  final double averageWorkingHours;

  AttendanceStats({
    required this.present,
    required this.late,
    required this.absent,
    required this.totalDays,
    required this.totalWorkingHours,
    required this.averageWorkingHours,
  });

  double get presentPercentage =>
      totalDays > 0 ? (present / totalDays) * 100 : 0.0;
  double get latePercentage =>
      totalDays > 0 ? (late / totalDays) * 100 : 0.0;
  double get absentPercentage =>
      totalDays > 0 ? (absent / totalDays) * 100 : 0.0;
}

