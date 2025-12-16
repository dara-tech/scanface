# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
```

### Step 3: First Time Setup
1. **Create Admin Account**
   - Enter your name, email, and phone (optional)
   - This is only needed on first launch

2. **Login**
   - Use your email as both email and password (for demo)
   - You'll be redirected to the admin dashboard

### Step 4: Add Users
1. Go to **Users** tab
2. Click **+** button
3. Fill in user details:
   - Name
   - Email
   - Role (Employee/Student)
   - Department (optional)

### Step 5: Register Faces
1. Go to **Faces** tab
2. Select a user
3. Capture **3 face images** from different angles
   - Position face in the frame
   - Tap "Capture Face" button
   - Repeat 3 times

### Step 6: Test Check-In
1. Logout as admin
2. Login as the user you just created
3. Tap **"Check In"** button
4. Position your face in the camera frame
5. Tap the camera button to capture
6. Face will be recognized and attendance recorded!

## 📱 App Flow

```
First Launch → Admin Setup → Login → Admin Dashboard
                                              ↓
                                    Add Users → Register Faces
                                              ↓
                                        User Login → Check-In
```

## ⚠️ Important Notes

1. **Camera Permissions**: The app will request camera permissions automatically
2. **Face Recognition**: Works best with good lighting and clear face visibility
3. **Demo Mode**: For demo, email is used as password - change this in production!
4. **Local Storage**: All data is stored locally on the device

## 🛠 Development Commands

```bash
# Run on specific device
flutter devices
flutter run -d <device-id>

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios

# Analyze code
flutter analyze

# Format code
flutter format .
```

## 🐛 Troubleshooting

**Camera not working?**
- Check app permissions in device settings
- Ensure you're testing on a real device (camera doesn't work well in emulators)

**Face not recognized?**
- Ensure face is clearly visible
- Good lighting is essential
- Try re-registering the face with better images

**App crashes on launch?**
- Run `flutter clean`
- Run `flutter pub get`
- Restart the app

## 📚 What's Included

✅ User authentication
✅ Face recognition check-in/check-out
✅ Admin dashboard
✅ User management
✅ Face registration
✅ Attendance tracking
✅ Attendance history
✅ Local database (SQLite)

## 🔮 Coming Soon

- Export reports (CSV, PDF)
- Charts and analytics
- Cloud sync
- Geofencing
- Push notifications

---

**Ready to go?** Run `flutter pub get` and `flutter run` to get started!

