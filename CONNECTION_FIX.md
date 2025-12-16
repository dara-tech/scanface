# 🔧 Connection Fix - Android Device

## ❌ Problem
```
Connection refused (OS Error: Connection refused, errno = 111), 
address = localhost, port = 48548
```

**Cause**: On Android devices, `localhost` refers to the device itself, not your development machine.

## ✅ Solution

### Option 1: Use Android Emulator URL (Current)
The config now automatically uses `10.0.2.2` for Android, which works for **Android Emulator**.

### Option 2: Use Real Device (Your Case - TB350XU)
Since you're using a **real Android device** (TB350XU), you need to use your **Mac's IP address**.

**Your Mac's IP**: `192.168.0.107`

### Quick Fix

Edit `lib/config/api_config.dart`:

**Change this:**
```dart
return 'http://10.0.2.2:3000/api'; // Android Emulator
```

**To this:**
```dart
return 'http://192.168.0.107:3000/api'; // Real Android device
```

**And change:**
```dart
return 'http://10.0.2.2:3000'; // Android Emulator
```

**To this:**
```dart
return 'http://192.168.0.107:3000'; // Real Android device
```

### Or Use Manual Override

In `api_config.dart`, set:
```dart
static const String? manualBaseUrl = 'http://192.168.0.107:3000/api';
static const String? manualSocketUrl = 'http://192.168.0.107:3000';
```

---

## 🔍 Verify Backend is Accessible

### Test from Mac
```bash
curl http://192.168.0.107:3000/health
```

### Test from Android Device
Make sure both devices are on the same WiFi network!

---

## 📱 Platform-Specific URLs

| Platform | URL |
|----------|-----|
| Android Emulator | `http://10.0.2.2:3000` |
| Real Android Device | `http://YOUR_MAC_IP:3000` |
| iOS Simulator | `http://localhost:3000` |
| Real iOS Device | `http://YOUR_MAC_IP:3000` |

---

## ✅ After Fix

1. **Hot restart** the Flutter app (not just hot reload)
2. Try login again
3. Check console for: `🌐 API Service initialized with baseUrl: http://192.168.0.107:3000/api`

---

**Your Mac's IP**: `192.168.0.107` ✅

