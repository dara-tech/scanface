# 🚀 Quick Deployment Commands

Quick reference for common deployment tasks.

## 📦 MongoDB Atlas

### Get Connection String
1. MongoDB Atlas Dashboard → Your Cluster → Connect
2. Choose "Connect your application"
3. Copy connection string
4. Replace `<password>` and add `/attendance_app` at end

### Test Connection
```bash
mongosh "mongodb+srv://user:password@cluster.net/attendance_app"
```

## 🌐 Render

### Test Health Endpoint
```bash
curl https://your-app-name.onrender.com/health
```

### Create Admin Account
```bash
curl -X POST https://your-app-name.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin User",
    "email": "admin@example.com",
    "password": "admin123",
    "role": "admin"
  }'
```

### Test Login
```bash
curl -X POST https://your-app-name.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'
```

## 📱 Flutter App

### Update API Config
Edit `lib/config/api_config.dart`:
```dart
static const String? manualBaseUrl = 'https://your-app-name.onrender.com/api';
static const String? manualSocketUrl = 'https://your-app-name.onrender.com';
```

### Hot Reload
Press `r` in Flutter terminal, or:
```bash
flutter run
```

## 🔧 Generate JWT Secret
```bash
cd attendance-backend
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## 📊 Check Render Logs
1. Go to Render Dashboard
2. Click your service
3. Click "Logs" tab
4. View real-time logs

## 🗄️ Check MongoDB Logs
1. Go to MongoDB Atlas Dashboard
2. Click your cluster
3. Click "Metrics" tab
4. View connection metrics

## 🔄 Restart Render Service
1. Render Dashboard → Your Service
2. Click "Manual Deploy"
3. Select "Clear build cache & deploy"

## 🧹 Clean and Rebuild
```bash
# Backend
cd attendance-backend
rm -rf node_modules
npm install

# Flutter
cd ..
flutter clean
flutter pub get
```

## 📝 Environment Variables Template
```env
NODE_ENV=production
PORT=10000
MONGODB_URI=mongodb+srv://user:pass@cluster.net/attendance_app?retryWrites=true&w=majority
JWT_SECRET=your-32-character-secret-key-here
JWT_EXPIRES_IN=7d
CORS_ORIGIN=*
```

## 🐛 Debug Connection Issues

### Test Backend
```bash
curl -v https://your-app-name.onrender.com/health
```

### Test API Endpoint
```bash
curl -v https://your-app-name.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'
```

### Check MongoDB Connection
```bash
# In MongoDB Atlas Dashboard
# Network Access → Check IP whitelist includes 0.0.0.0/0
# Database Access → Verify user exists
```

## 📚 Documentation Links

- **Full Guide:** `COMPLETE_DEPLOYMENT_GUIDE.md`
- **Quick Start:** `attendance-backend/DEPLOY_QUICK_START.md`
- **Render Guide:** `attendance-backend/RENDER_DEPLOYMENT.md`
- **Checklist:** `DEPLOYMENT_CHECKLIST.md`

