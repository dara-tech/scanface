# 📱 CORS Configuration for Mobile Apps

This guide explains how to configure CORS (Cross-Origin Resource Sharing) for mobile apps like Flutter.

---

## 🔍 Understanding CORS for Mobile Apps

**Important:** Mobile apps (Flutter, React Native) don't have the same CORS restrictions as web browsers. However, we still configure CORS for:
- Security best practices
- WebSocket connections
- Future web app support
- API security

---

## ⚙️ Configuration Options

### Option 1: Allow All Origins (Recommended for Mobile Apps)

This is the easiest and works perfectly for mobile apps.

**In `.env` file:**
```env
CORS_ORIGIN=*
```

**What this does:**
- ✅ Allows all origins (mobile apps, web, Postman, etc.)
- ✅ Works with Flutter apps
- ✅ Works with React Native apps
- ✅ Works with local development
- ⚠️ Less secure (but fine for mobile apps)

**When to use:**
- Mobile-only apps
- Development/testing
- When you don't have specific domains

---

### Option 2: Allow Specific Origins (For Production)

For production with specific domains.

**In `.env` file:**
```env
CORS_ORIGIN=https://your-app.com,https://www.your-app.com,https://api.your-app.com
```

**What this does:**
- ✅ More secure
- ✅ Only allows specified domains
- ✅ Good for web apps
- ⚠️ Mobile apps don't need this (but won't hurt)

**When to use:**
- Production web apps
- When you have specific domains
- When security is critical

---

### Option 3: Allow Multiple Origins (Development + Production)

Allow both local development and production.

**In `.env` file:**
```env
CORS_ORIGIN=http://localhost:3000,http://192.168.0.116:3000,https://your-app.onrender.com,*
```

**What this does:**
- ✅ Allows local development
- ✅ Allows production
- ✅ Allows mobile apps (via `*`)
- ✅ Flexible for all environments

---

## 📝 Step-by-Step Setup

### For Local Development

1. **Open `.env` file** in `attendance-backend/` folder
2. **Add or update:**
   ```env
   CORS_ORIGIN=*
   ```
3. **Save the file**
4. **Restart your server:**
   ```bash
   npm run dev
   ```

### For Render Deployment

1. **Go to Render Dashboard**
2. **Select your service**
3. **Go to "Environment" tab**
4. **Add or update:**
   - Key: `CORS_ORIGIN`
   - Value: `*`
5. **Save changes**
6. **Redeploy** (automatic if auto-deploy is enabled)

---

## 🧪 Testing CORS Configuration

### Test 1: Health Check
```bash
curl https://your-app.onrender.com/health
```

Should return: `{"status":"ok",...}`

### Test 2: API Request
```bash
curl -X POST https://your-app.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'
```

Should work without CORS errors.

### Test 3: From Flutter App
1. Open your Flutter app
2. Try to login or register
3. Should work without CORS errors

---

## 🔧 Current Configuration

Your server is already configured to:
- ✅ Allow requests with no origin (mobile apps)
- ✅ Support `*` for all origins
- ✅ Support comma-separated origins
- ✅ Allow credentials
- ✅ Support all HTTP methods

**Code location:** `attendance-backend/src/server.js`

---

## 📋 Environment Variables

### Local Development (`.env`)
```env
# Allow all origins (perfect for mobile apps)
CORS_ORIGIN=*
```

### Render Production
In Render dashboard → Environment Variables:
```
CORS_ORIGIN=*
```

---

## ⚠️ Common Issues

### Issue: "CORS policy blocked"
**Solution:** 
- Set `CORS_ORIGIN=*` in `.env`
- Restart server
- For Render: Update environment variable and redeploy

### Issue: WebSocket connection fails
**Solution:**
- Ensure Socket.io CORS is also configured (already done)
- Check `CORS_ORIGIN` includes `*` or your origin
- Verify WebSocket URL uses HTTPS in production

### Issue: Works locally but not on Render
**Solution:**
- Check Render environment variables
- Ensure `CORS_ORIGIN=*` is set in Render dashboard
- Redeploy after changing environment variables

---

## 🎯 Best Practices

### For Mobile Apps (Flutter/React Native)
```env
CORS_ORIGIN=*
```
✅ **Recommended** - Mobile apps don't have browser CORS restrictions

### For Web Apps
```env
CORS_ORIGIN=https://your-domain.com,https://www.your-domain.com
```
✅ **Recommended** - More secure, specific domains only

### For Development
```env
CORS_ORIGIN=http://localhost:3000,http://192.168.0.116:3000,*
```
✅ **Recommended** - Allows local development + mobile apps

---

## 📚 Additional Resources

- **CORS Documentation:** https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
- **Express CORS:** https://expressjs.com/en/resources/middleware/cors.html
- **Socket.io CORS:** https://socket.io/docs/v4/handling-cors/

---

## ✅ Quick Checklist

- [ ] `.env` file has `CORS_ORIGIN=*` (for mobile apps)
- [ ] Server restarted after changing `.env`
- [ ] Render environment variable set (if deployed)
- [ ] Tested API requests work
- [ ] Flutter app can connect
- [ ] WebSocket connections work

---

**Summary:** For mobile apps, use `CORS_ORIGIN=*` - it's simple and works perfectly! 🚀

