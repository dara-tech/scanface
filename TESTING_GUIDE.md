# 🧪 Testing Guide

## Quick Test Commands

### 1. Test Backend Health
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-12-12T...",
  "database": "connected"
}
```

### 2. Test User Registration
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@test.com",
    "password": "password123",
    "role": "employee"
  }'
```

### 3. Test Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "password123"
  }'
```

Save the token from the response!

### 4. Test Check-In (with token)
```bash
TOKEN="paste_your_token_here"

curl -X POST http://localhost:3000/api/attendance/checkin \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### 5. Run Full Test Suite
```bash
cd attendance-backend
./test-api.sh
```

---

## 📱 Flutter App Testing

### 1. Update API Config
Make sure `lib/config/api_config.dart` has the correct URL:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**For Real Device:**
```dart
// Use your Mac's IP (find with: ifconfig | grep "inet ")
static const String baseUrl = 'http://192.168.1.XXX:3000/api';
```

### 2. Test in Flutter App

1. **Start Backend:**
   ```bash
   cd attendance-backend
   npm run dev
   ```

2. **Run Flutter App:**
   ```bash
   flutter run
   ```

3. **Test Flow:**
   - Register a new user
   - Login
   - Check-in
   - Check real-time updates
   - Check-out

---

## 🔌 WebSocket Testing

### Using Browser Console
```javascript
const socket = io('http://localhost:3000', {
  auth: { token: 'your_jwt_token_here' }
});

socket.on('connect', () => {
  console.log('Connected!');
  socket.emit('ping');
});

socket.on('pong', (data) => {
  console.log('Pong:', data);
});

socket.on('attendance:new', (data) => {
  console.log('New attendance:', data);
});

// Test check-in
socket.emit('checkin', {
  location: {
    latitude: 37.7749,
    longitude: -122.4194
  }
});
```

### Using Node.js
```javascript
const io = require('socket.io-client');

const socket = io('http://localhost:3000', {
  auth: { token: 'your_jwt_token_here' }
});

socket.on('connect', () => {
  console.log('Connected');
  socket.emit('checkin', {});
});

socket.on('checkin:success', (data) => {
  console.log('Check-in success:', data);
});
```

---

## ✅ Test Checklist

### Backend Tests
- [ ] Health check returns OK
- [ ] User registration works
- [ ] User login returns JWT token
- [ ] Check-in creates attendance record
- [ ] Check-out updates attendance
- [ ] Get today's attendance works
- [ ] Get attendance history works
- [ ] Get statistics works

### Flutter Tests
- [ ] Can register user
- [ ] Can login
- [ ] Token is saved
- [ ] WebSocket connects
- [ ] Check-in works
- [ ] Real-time updates received
- [ ] Check-out works

### Integration Tests
- [ ] Flutter → Backend API works
- [ ] Flutter → WebSocket works
- [ ] Real-time updates sync
- [ ] Error handling works

---

## 🐛 Troubleshooting

### Backend Not Responding
```bash
# Check if server is running
curl http://localhost:3000/health

# Check if MongoDB is connected
# Look for "database": "connected" in health response
```

### MongoDB Not Connected
```bash
# Start MongoDB
brew services start mongodb-community

# Or with Docker
docker run -d --name attendance-mongodb -p 27017:27017 mongo:6.0
```

### CORS Errors
- Check `CORS_ORIGIN` in `.env`
- Make sure Flutter app URL is included

### Authentication Errors
- Check JWT token is valid
- Verify token hasn't expired
- Check token format: `Bearer <token>`

---

## 📊 Expected Results

### Successful Registration
```json
{
  "message": "User registered successfully",
  "user": {
    "_id": "...",
    "name": "Test User",
    "email": "test@test.com",
    "role": "employee"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Successful Check-In
```json
{
  "message": "Checked in successfully",
  "attendance": {
    "_id": "...",
    "userId": {...},
    "date": "2025-12-12T00:00:00.000Z",
    "checkInTime": "2025-12-12T09:00:00.000Z",
    "status": "present"
  }
}
```

---

**Ready to test!** Run `./test-api.sh` in the backend directory for automated testing.

