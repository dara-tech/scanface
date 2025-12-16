# 📱 Real Android Device Setup Guide

## ✅ Current Configuration

- **Device**: TB350XU (Real Android device)
- **Mac IP**: 192.168.0.107
- **Backend Port**: 3000

## 🔧 Step-by-Step Setup

### 1. Verify Mac IP Address

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Current IP**: `192.168.0.107` ✅

**Important**: If your Mac's IP changes, update `api_config.dart`

### 2. Check Both Devices on Same WiFi

**Mac:**
- WiFi name: Check in System Settings → Network

**Android Device:**
- Settings → WiFi → Check connected network name
- **Must match Mac's WiFi network!**

### 3. Disable Mac Firewall (Temporarily for Testing)

**System Settings → Network → Firewall:**
1. Turn OFF firewall temporarily
2. Test connection
3. If it works, turn firewall back ON and add exception

**Or add exception:**
```bash
# Allow Node.js through firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/node
```

### 4. Restart Backend Server

**Stop current server** (if running):
```bash
# Press Ctrl+C in backend terminal
```

**Start with network binding:**
```bash
cd attendance-backend
npm run dev
```

**You should see:**
```
🚀 Server running on http://localhost:3000
🌐 Server accessible from network: http://0.0.0.0:3000
💡 For Android device, use your Mac's IP: http://192.168.0.107:3000
```

### 5. Test Connection from Mac

```bash
# Test if server is accessible
curl http://192.168.0.107:3000/health
```

**Expected response:**
```json
{"status":"ok","timestamp":"...","database":"connected"}
```

### 6. Update Flutter App Config (if needed)

Check `lib/config/api_config.dart`:
- Should use: `http://192.168.0.107:3000/api` for Android

### 7. Hot Restart Flutter App

In Flutter terminal:
- Press `R` (capital R) for hot restart
- Or stop and restart: `flutter run`

### 8. Test Login

Try logging in from the Android device.

---

## 🔍 Troubleshooting "No route to host"

### Check 1: Same Network?
- Mac and Android must be on **same WiFi network**
- Check WiFi names match

### Check 2: Firewall?
- Temporarily disable Mac firewall
- Test connection
- If works, firewall is blocking

### Check 3: IP Address Changed?
```bash
# Get current IP
ifconfig | grep "inet " | grep -v 127.0.0.1
```
- Update `api_config.dart` if IP changed

### Check 4: Server Listening?
```bash
# Check if server is listening on all interfaces
lsof -i :3000
# Should show: *:3000 (LISTEN)
```

### Check 5: Test from Android Browser
On your Android device, open browser and go to:
```
http://192.168.0.107:3000/health
```

**If this works**: Network is fine, issue is in Flutter app
**If this fails**: Network/firewall issue

---

## ✅ Quick Checklist

- [ ] Mac and Android on same WiFi
- [ ] Mac firewall allows port 3000 (or disabled)
- [ ] Backend server running and listening on 0.0.0.0
- [ ] Mac IP is 192.168.0.107 (check with ifconfig)
- [ ] Flutter app config uses 192.168.0.107
- [ ] Flutter app hot restarted (not just hot reload)

---

## 🚀 After Setup

Once connected, you should see:
- Login works
- API calls succeed
- WebSocket connects
- Real-time updates work

**If still having issues**, check the console logs for specific error messages.

