# Setup Guide

## Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   - Download from [flutter.dev](https://flutter.dev)
   - Verify installation: `flutter doctor`

2. **Android Studio / Xcode**
   - For Android development
   - For iOS development (macOS only)

3. **Camera-enabled device or emulator**

## Installation Steps

### 1. Clone/Download the project

```bash
cd /path/to/attendence
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Platform Configuration

#### Android

1. Open `android/app/src/main/AndroidManifest.xml`
2. Ensure camera permissions are present (should be auto-added by camera package)
3. Minimum SDK: 21 (Android 5.0)

#### iOS

1. Open `ios/Runner/Info.plist`
2. Add camera permission:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to register and recognize faces for attendance</string>
```

### 4. Run the App

```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device-id>
```

## First Launch

1. **Create Admin Account**
   - On first launch, you'll be prompted to create an admin account
   - Enter your name, email, and phone number (optional)

2. **Login**
   - Use your email to login
   - Note: For demo purposes, email is used as password

3. **Add Users** (Admin only)
   - Go to "Users" tab
   - Click "+" to add new users
   - Fill in user details

4. **Register Faces** (Admin only)
   - Go to "Faces" tab
   - Select a user
   - Capture 3 face images from different angles
   - Face embeddings will be stored locally

5. **Check-In** (Users)
   - Users can check in using face recognition
   - System will match face with stored embeddings
   - Attendance is recorded automatically

## Features

### Admin Features
- User management (Add, Edit, Delete, Activate/Deactivate)
- Face registration for users
- View all attendance records
- Generate reports (Coming soon)

### User Features
- Face recognition check-in/check-out
- View attendance history
- View personal statistics
- Profile management

## Troubleshooting

### Camera not working
- Ensure app has camera permissions
- Check if device has a camera
- Restart the app

### Face recognition not accurate
- Ensure good lighting
- Face should be clearly visible
- Try re-registering face with better images
- Capture multiple angles during registration

### Database issues
- App uses local SQLite database
- Data is stored in app's documents directory
- Uninstalling app will delete all data

## Development Notes

- Face recognition uses Google ML Kit for face detection
- Face embeddings are extracted using a simplified algorithm
- For production, consider using trained ML models for better accuracy
- All data is stored locally - no cloud sync yet

## Next Steps

- [ ] Add cloud backend (Firebase/Supabase)
- [ ] Improve face recognition accuracy
- [ ] Add export functionality (CSV, PDF)
- [ ] Add charts and analytics
- [ ] Add geofencing support
- [ ] Add push notifications

