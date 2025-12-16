# 🔄 Server Switching Guide

This guide explains how to switch between **local development server** and **production server (Render)**.

---

## 📋 Current Configuration

**Production Server (Render):**
- URL: `https://scanface-tztq.onrender.com`
- API: `https://scanface-tztq.onrender.com/api`
- WebSocket: `https://scanface-tztq.onrender.com`

**Local Development Server:**
- URL: `http://192.168.0.116:3000`
- API: `http://192.168.0.116:3000/api`
- WebSocket: `http://192.168.0.116:3000`

---

## 🔧 How to Switch Servers

### Method 1: Use the `useProduction` Flag (Recommended)

Edit `lib/config/api_config.dart`:

**To use Production (Render):**
```dart
static const bool useProduction = true; // Use Render server
```

**To use Local:**
```dart
static const bool useProduction = false; // Use local server
```

**Then restart the app** (hot restart, not just hot reload).

---

### Method 2: Manual Override

Edit `lib/config/api_config.dart`:

**For Production:**
```dart
static const String? manualBaseUrl = 'https://scanface-tztq.onrender.com/api';
static const String? manualSocketUrl = 'https://scanface-tztq.onrender.com';
```

**For Local:**
```dart
static const String? manualBaseUrl = 'http://192.168.0.116:3000/api';
static const String? manualSocketUrl = 'http://192.168.0.116:3000';
```

**Or set to null to use automatic detection:**
```dart
static const String? manualBaseUrl = null; // Use automatic detection
static const String? manualSocketUrl = null;
```

---

## 🎯 Priority Order

The app uses URLs in this priority order:

1. **Manual Override** (highest priority)
   - If `manualBaseUrl` or `manualSocketUrl` is set, it's used

2. **useProduction Flag**
   - If `useProduction = true`, uses Render server
   - If `useProduction = false`, uses local server

3. **Release Mode Detection**
   - If app is in release mode, uses production (if available)

4. **Platform Detection** (lowest priority)
   - Android: Uses local server (your Mac's IP)
   - iOS: Uses localhost or Mac's IP
   - Web: Uses localhost

---

## 📝 Quick Reference

### Switch to Production (Render)
```dart
// In lib/config/api_config.dart
static const bool useProduction = true;
```
Then: **Hot restart** the app

### Switch to Local
```dart
// In lib/config/api_config.dart
static const bool useProduction = false;
```
Then: **Hot restart** the app

---

## ✅ Verify Connection

After switching, check the connection status:

1. **Look at the status indicator** in the app (top right of AppBar)
   - 🟢 Green = Connected
   - 🔴 Red = Disconnected

2. **Check console logs:**
   ```
   🌐 API Service initializing with baseUrl: https://scanface-tztq.onrender.com/api
   ```
   or
   ```
   🌐 API Service initializing with baseUrl: http://192.168.0.116:3000/api
   ```

3. **Test health endpoint:**
   - Production: `curl https://scanface-tztq.onrender.com/health`
   - Local: `curl http://192.168.0.116:3000/health`

---

## 🚀 Recommended Setup

### For Development
```dart
static const bool useProduction = false; // Use local server
static const String? manualBaseUrl = null; // Auto-detect
```

### For Testing Production
```dart
static const bool useProduction = true; // Use Render server
static const String? manualBaseUrl = null; // Auto-detect
```

### For Release Build
The app will automatically use production in release mode if `productionBaseUrl` is set.

---

## 🔍 Current Status

**Current Configuration:**
- `useProduction = false` → Using **Local Server**
- Production URL: `https://scanface-tztq.onrender.com` ✅ (configured)
- Local URL: `http://192.168.0.116:3000` ✅ (configured)

**To switch to Render:** Change `useProduction = true` and restart app.

---

## 💡 Tips

1. **Always restart** the app after changing server configuration (not just hot reload)
2. **Check connection status** indicator to verify which server you're connected to
3. **Local server** requires your Mac to be running the backend
4. **Production server** works from anywhere (as long as Render is running)

---

## 🆘 Troubleshooting

**Can't connect to local server?**
- Make sure backend is running: `cd attendance-backend && npm run dev`
- Check your Mac's IP hasn't changed: `ifconfig | grep "inet "`
- Update `localBaseUrl` if IP changed

**Can't connect to production?**
- Check Render dashboard: https://dashboard.render.com
- Verify Render service is running
- Test health endpoint: `curl https://scanface-tztq.onrender.com/health`

**App shows wrong server?**
- Make sure you did a **hot restart** (not just hot reload)
- Check `useProduction` flag value
- Check if `manualBaseUrl` is overriding

---

**Last Updated:** After configuring Render URL

