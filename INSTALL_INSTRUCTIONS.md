# 📱 Install App on Device

## Current Status
- ✅ App icon created (Face ID icon)
- ✅ APK built successfully
- ⏳ Device connection needed

## Installation Methods

### Method 1: Connect Device and Install (Recommended)

1. **Connect your Android device via USB**
   - Use a USB cable to connect your device to your Mac
   - Make sure USB debugging is enabled on your device

2. **Enable USB Debugging** (if not already enabled):
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

3. **Verify connection:**
   ```bash
   adb devices
   ```
   Should show your device ID

4. **Install the app:**
   ```bash
   flutter run -d <device-id>
   ```
   Or:
   ```bash
   flutter install -d <device-id>
   ```

---

### Method 2: Install APK Directly

If you have the APK file, you can install it directly:

1. **Find the APK:**
   ```bash
   ls -lh build/app/outputs/flutter-apk/app-debug.apk
   ```

2. **Transfer to device:**
   - Copy the APK to your device via USB, email, or cloud storage
   - Or use ADB:
     ```bash
     adb install build/app/outputs/flutter-apk/app-debug.apk
     ```

3. **Install on device:**
   - Open the APK file on your device
   - Allow installation from unknown sources if prompted
   - Tap "Install"

---

### Method 3: Build and Install in One Command

Once your device is connected:

```bash
cd /Users/cheolsovandara/Documents/D/Developments/2026/attendence
flutter run -d <device-id>
```

This will:
- Build the app
- Install it on your device
- Launch it automatically

---

## Troubleshooting

### Device Not Detected

1. **Check USB connection:**
   - Try a different USB cable
   - Try a different USB port
   - Make sure cable supports data transfer (not just charging)

2. **Restart ADB:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

3. **Check device authorization:**
   - When you connect, your device should show "Allow USB debugging?" dialog
   - Check "Always allow from this computer"
   - Tap "Allow"

4. **Verify USB debugging:**
   - Settings → Developer Options → USB Debugging (should be ON)

### Build Errors

If you get build errors:

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

### Installation Errors

If installation fails:

```bash
# Uninstall existing app first
adb uninstall com.example.attendance_app

# Then install
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## Quick Commands

```bash
# Check connected devices
flutter devices
adb devices

# Build APK
flutter build apk --debug

# Install APK via ADB
adb install build/app/outputs/flutter-apk/app-debug.apk

# Run app on device
flutter run -d <device-id>

# Install and run
flutter install -d <device-id>
```

---

## APK Location

Your APK is located at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

You can:
- Copy this file to your device
- Share it via email/cloud
- Install via ADB when device is connected

---

**Next Steps:**
1. Connect your Android device via USB
2. Enable USB debugging
3. Run: `flutter run -d <device-id>`

Or install the APK directly from: `build/app/outputs/flutter-apk/app-debug.apk`

