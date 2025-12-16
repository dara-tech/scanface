# 🔧 Network Troubleshooting - "No route to host"

## ✅ Progress Made

1. ✅ URL is now correct: `http://192.168.0.107:3000/api`
2. ✅ App is using the right IP address
3. ⚠️ New error: "No route to host" (errno = 113)

## 🔍 What "No route to host" Means

This error means the Android device **cannot reach** your Mac at `192.168.0.107:3000`.

## ✅ Solutions

### 1. Check Mac Firewall

**macOS Firewall Settings:**
1. Open **System Settings** → **Network** → **Firewall**
2. Make sure firewall is either:
   - **Off** (for development), OR
   - **On** with port 3000 allowed

**Allow Port 3000:**
```bash
# Check if firewall is blocking
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Allow Node.js through firewall (if needed)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/node
```

### 2. Verify Both Devices on Same Network

**Check Mac IP:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
# Should show: 192.168.0.107
```

**Check Android Device:**
- Settings → About Phone → Status → IP Address
- Should be in same range: `192.168.0.XXX`

### 3. Test Connection from Mac

```bash
# Test if server is accessible
curl http://192.168.0.107:3000/health

# Test from Android device's perspective (if you have adb)
adb shell ping -c 1 192.168.0.107
```

### 4. Restart Backend Server

After updating server.js to listen on `0.0.0.0`:

```bash
cd attendance-backend
# Stop current server (Ctrl+C)
npm run dev
```

You should see:
```
🚀 Server running on http://localhost:3000
🌐 Server accessible from network: http://0.0.0.0:3000
💡 For Android device, use your Mac's IP: http://192.168.0.107:3000
```

### 5. Alternative: Use ngrok (Quick Test)

If firewall is too complicated:

```bash
# Install ngrok
brew install ngrok

# Create tunnel
ngrok http 3000

# Use the ngrok URL in api_config.dart
# Example: https://abc123.ngrok.io
```

---

## 🔍 Quick Checks

1. **Backend running?**
   ```bash
   curl http://localhost:3000/health
   ```

2. **Server listening on all interfaces?**
   ```bash
   lsof -i :3000
   # Should show: *:3000 (LISTEN)
   ```

3. **Same WiFi network?**
   - Mac and Android must be on same WiFi
   - Check WiFi name matches

4. **Firewall blocking?**
   - Temporarily disable Mac firewall to test
   - If it works, re-enable and add exception

---

## ✅ After Fixing

1. Restart backend server
2. Hot restart Flutter app (press `R`)
3. Try login again

You should see successful connection! 🎉

