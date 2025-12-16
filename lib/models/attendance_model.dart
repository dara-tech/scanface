enum AttendanceType {
  checkIn,
  checkOut,
}

enum AttendanceStatus {
  present,
  late,
  absent,
  halfDay,
}

class Attendance {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final String? notes;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  // Calculate working hours
  Duration? get workingHours {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return null;
  }

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Store only date
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create from Map
  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      checkInTime: map['check_in_time'] != null
          ? DateTime.parse(map['check_in_time'] as String)
          : null,
      checkOutTime: map['check_out_time'] != null
          ? DateTime.parse(map['check_out_time'] as String)
          : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      latitude: map['latitude'] != null ? map['latitude'] as double : null,
      longitude: map['longitude'] != null ? map['longitude'] as double : null,
    );
  }

  // Copy with method
  Attendance copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    AttendanceStatus? status,
    String? notes,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

