# Attendance App with Face Recognition

A cross-platform attendance management system built with Flutter that uses face recognition technology for secure and efficient attendance tracking.

## Features

- 👤 Face recognition-based check-in/check-out
- 📊 Real-time attendance dashboard
- 👥 User management system
- 📈 Attendance reports and analytics
- 📱 Works on iOS, Android, Web, and Desktop
- 💾 Offline support with local database

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Camera-enabled device or emulator

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Platform Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Camera permissions are automatically requested

#### iOS
- Minimum iOS: 12.0
- Add camera permissions to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to register and recognize faces for attendance</string>
```

## Project Structure

```
lib/
├── main.dart
├── models/
├── services/
├── providers/
├── screens/
├── widgets/
└── utils/
```

## Dependencies

- **Face Recognition**: Google ML Kit
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Camera**: camera package
- **Charts**: fl_chart

## License

This project is for educational purposes.

