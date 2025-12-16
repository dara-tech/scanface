# ⚠️ IMPORTANT: Full App Restart Required

## 🔄 Why Full Restart?

The API configuration change requires a **full app restart**, not just hot reload.

**Hot reload** doesn't recreate singleton services like `ApiService`, so it still uses the old `localhost` URL.

## ✅ How to Restart

### Option 1: Stop and Restart
```bash
# Press 'q' to quit current app
# Then run:
flutter run
```

### Option 2: Hot Restart (Faster)
```bash
# In the terminal where flutter run is active:
# Press 'R' (capital R) for hot restart
```

### Option 3: In VS Code/Android Studio
- Click the "Restart" button (not "Hot Reload")
- Or use the restart icon in the debug toolbar

---

## ✅ After Restart

You should see in the console:
```
🌐 API Service initializing with baseUrl: http://192.168.0.107:3000/api
```

If you still see `localhost`, the restart didn't work - try stopping completely and starting again.

---

## 🔍 Verify It's Working

After restart, try login again. The connection should work now!

**Current Config**: Using `192.168.0.107:3000` for Android device ✅

