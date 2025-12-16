# Testing on Real iOS Device - Step by Step Guide

## Prerequisites
- ✅ Xcode installed (you have Xcode 16.2)
- ✅ iPhone/iPad with iOS 12.0 or later
- ✅ USB cable to connect device to Mac
- ✅ Apple Developer Account (free account works for development)

## Step 1: Connect Your Device

1. **Connect your iPhone/iPad to your Mac** using a USB cable
2. **Unlock your device** and keep it unlocked
3. **Trust the computer** - When prompted on your device, tap "Trust" and enter your passcode

## Step 2: Enable Developer Mode (iOS 16+)

If your device is running iOS 16 or later:

1. Go to **Settings** > **Privacy & Security**
2. Scroll down to **Developer Mode**
3. Toggle **Developer Mode** ON
4. **Restart your device** when prompted
5. After restart, confirm you want to enable Developer Mode

## Step 3: Configure Xcode Signing

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select your project**:
   - Click on "Runner" in the left sidebar
   - Select the "Runner" target
   - Go to "Signing & Capabilities" tab

3. **Configure signing**:
   - Check "Automatically manage signing"
   - Select your **Team** (your Apple ID)
   - Xcode will automatically create a provisioning profile

4. **If you don't have a team**:
   - Click "Add Account..."
   - Sign in with your Apple ID
   - Accept the terms if prompted
   - Select your account as the team

## Step 4: Trust Developer Certificate on Device

1. On your iPhone/iPad, go to **Settings** > **General** > **VPN & Device Management** (or **Device Management**)
2. Tap on your **Developer App** certificate
3. Tap **Trust** and confirm

## Step 5: Run the App

### Option A: Using Flutter CLI (Recommended)

1. **Check if device is detected**:
   ```bash
   flutter devices
   ```
   You should see your device listed (e.g., "iPhone 15 Pro Max")

2. **Run the app**:
   ```bash
   flutter run
   ```
   Or specify the device:
   ```bash
   flutter run -d <device-id>
   ```

### Option B: Using Xcode

1. In Xcode, select your device from the device dropdown (top toolbar)
2. Click the **Play** button (▶️) or press `Cmd + R`
3. The app will build and install on your device

## Step 6: Grant Camera Permission

When you first use the camera feature:

1. The app will request camera permission
2. Tap **"Allow"** on the permission dialog
3. If you accidentally denied it:
   - Go to **Settings** > **Privacy & Security** > **Camera**
   - Find "Attendance App" and toggle it ON

## Troubleshooting

### Device Not Detected

1. **Check USB connection** - Try a different cable or USB port
2. **Restart both devices** - Mac and iPhone/iPad
3. **Check Xcode** - Make sure Xcode is fully installed and updated
4. **Run flutter doctor**:
   ```bash
   flutter doctor -v
   ```

### Code Signing Errors

1. **Open Xcode** and check signing:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Select Runner > Signing & Capabilities
3. Make sure "Automatically manage signing" is checked
4. Select your Team
5. If errors persist, try:
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter clean
   flutter pub get
   ```

### Build Errors

1. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   flutter run
   ```

### Camera Not Working

1. **Check permissions**:
   - Settings > Privacy & Security > Camera
   - Make sure "Attendance App" is enabled

2. **Restart the app** after granting permission

3. **Check if camera works in other apps** (like Camera app)

## Quick Commands

```bash
# List all connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode (faster, no debugging)
flutter run --release

# Check for issues
flutter doctor -v

# Clean build
flutter clean && flutter pub get
```

## Notes

- **First build takes longer** - Be patient, it's compiling everything
- **Hot reload works** - Press `r` in terminal to hot reload
- **Hot restart** - Press `R` (capital R) to hot restart
- **Stop the app** - Press `q` in terminal

## Success Indicators

✅ Device appears in `flutter devices`
✅ App installs on device
✅ App launches successfully
✅ Camera permission dialog appears
✅ Camera preview works

---

**Need Help?** Check the Flutter documentation: https://docs.flutter.dev/get-started/install/macos#deploy-to-ios-devices
