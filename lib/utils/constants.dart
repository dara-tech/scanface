class AppConstants {
  // Database
  static const String databaseName = 'attendance_app.db';
  static const int databaseVersion = 1;

  // Face Recognition
  static const double faceRecognitionThreshold = 0.85; // Cosine similarity threshold
  static const int minFaceWidth = 100;
  static const int minFaceHeight = 100;

  // Attendance
  static const int defaultWorkingHours = 8;
  static const int lateThresholdMinutes = 15; // Minutes after scheduled time
  static const String defaultCheckInTime = '09:00';
  static const String defaultCheckOutTime = '18:00';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';
  static const String roleStudent = 'student';

  // App Settings
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefCurrentUserId = 'current_user_id';
  static const String prefCurrentUserRole = 'current_user_role';
  static const String prefFaceRecognitionEnabled = 'face_recognition_enabled';
  static const String prefNotificationEnabled = 'notification_enabled';

  // Storage Paths
  static const String faceImagesFolder = 'face_images';
  static const String profileImagesFolder = 'profile_images';
}

