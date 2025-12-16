// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Attendance App';

  @override
  String get faceRecognitionSystem => 'Face Recognition System';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get hello => 'Hello';

  @override
  String helloUser(String userName) {
    return 'Hello, $userName';
  }

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get attendancePulse => 'Attendance pulse';

  @override
  String get todayStatus => 'Today\'s status';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkOut => 'Check Out';

  @override
  String get checkInTime => 'Check-in';

  @override
  String get checkOutTime => 'Check-out';

  @override
  String get workingHours => 'Working hours';

  @override
  String get thisMonth => 'This month';

  @override
  String get present => 'Present';

  @override
  String get late => 'Late';

  @override
  String get absent => 'Absent';

  @override
  String get notCheckedInYet => 'You haven\'t checked in yet.';

  @override
  String get profile => 'Profile';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get role => 'Role';

  @override
  String get department => 'Department';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get attendanceHistory => 'Attendance History';

  @override
  String get noAttendanceRecords => 'No attendance records';

  @override
  String get positionYourFace => 'Position your face in the frame';

  @override
  String get processing => 'Processing...';

  @override
  String get faceDetected => 'Face detected';

  @override
  String get positionFaceBetter => 'Please position your face better';

  @override
  String get multipleFacesDetected => 'Multiple faces detected';

  @override
  String get noFaceDetected => 'No face detected';

  @override
  String get checkInSuccessful => 'Check-in successful!';

  @override
  String get checkOutSuccessful => 'Checked out successfully!';

  @override
  String get user => 'User';

  @override
  String get admin => 'Admin';

  @override
  String get employee => 'Employee';

  @override
  String get student => 'Student';

  @override
  String get status => 'Status';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get duration => 'Duration';

  @override
  String get total => 'Total';

  @override
  String get noUserData => 'No user data';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get loginNote =>
      'Note: For demo, use your email as both email and password';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get todayPresent => 'Today Present';

  @override
  String get todayAbsent => 'Today Absent';

  @override
  String get todayLate => 'Today Late';

  @override
  String get userManagement => 'User Management';

  @override
  String get attendanceReports => 'Attendance Reports';

  @override
  String get faceRegistration => 'Face Registration';

  @override
  String get addUser => 'Add User';

  @override
  String get editUser => 'Edit User';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get export => 'Export';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get fromDate => 'From Date';

  @override
  String get toDate => 'To Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get noData => 'No data';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get help => 'Help';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseEnterConfirmPassword => 'Please confirm your password';

  @override
  String get registrationSuccessful => 'Registration successful!';
}
