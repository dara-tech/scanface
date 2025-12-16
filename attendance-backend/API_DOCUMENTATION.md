# API Documentation

## 🔐 Authentication Endpoints

### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phoneNumber": "+1234567890",
  "role": "employee"  // optional: "admin", "employee", "student"
}
```

**Response:**
```json
{
  "message": "User registered successfully",
  "user": {
    "_id": "...",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "employee"
  },
  "token": "jwt_token_here"
}
```

### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "user": {
    "_id": "...",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "employee"
  },
  "token": "jwt_token_here"
}
```

### Get Current User
```http
GET /api/auth/me
Authorization: Bearer <token>
```

### Logout
```http
POST /api/auth/logout
Authorization: Bearer <token>
```

---

## 📅 Attendance Endpoints

All attendance endpoints require authentication.

### Check-In
```http
POST /api/attendance/checkin
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": "optional_if_authenticated",
  "location": {
    "latitude": 37.7749,
    "longitude": -122.4194,
    "address": "San Francisco, CA"
  }
}
```

**Response:**
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

### Check-Out
```http
PUT /api/attendance/:attendanceId/checkout
POST /api/attendance/checkout
Authorization: Bearer <token>
Content-Type: application/json

{
  "location": {
    "latitude": 37.7749,
    "longitude": -122.4194
  }
}
```

### Get Attendance History
```http
GET /api/attendance?userId=...&startDate=2025-12-01&endDate=2025-12-31&page=1&limit=50
Authorization: Bearer <token>
```

### Get Today's Attendance
```http
GET /api/attendance/today?userId=...
Authorization: Bearer <token>
```

### Get Attendance Statistics
```http
GET /api/attendance/stats?userId=...&startDate=2025-12-01&endDate=2025-12-31
Authorization: Bearer <token>
```

**Response:**
```json
{
  "stats": {
    "totalDays": 20,
    "totalWorkingHours": 16000,
    "presentDays": 18,
    "lateDays": 2
  }
}
```

---

## 🔌 WebSocket Events

### Connection
```javascript
const socket = io('http://localhost:3000', {
  auth: {
    token: 'your_jwt_token'
  }
});
```

### Client → Server Events

#### Check-In
```javascript
socket.emit('checkin', {
  location: {
    latitude: 37.7749,
    longitude: -122.4194,
    address: "San Francisco, CA"
  }
});
```

#### Check-Out
```javascript
socket.emit('checkout', {
  attendanceId: 'optional',
  location: {
    latitude: 37.7749,
    longitude: -122.4194
  }
});
```

#### Ping
```javascript
socket.emit('ping');
```

### Server → Client Events

#### Check-In Success
```javascript
socket.on('checkin:success', (data) => {
  console.log('Checked in:', data.attendance);
});
```

#### Check-Out Success
```javascript
socket.on('checkout:success', (data) => {
  console.log('Checked out:', data.attendance);
});
```

#### Real-time Attendance Updates
```javascript
socket.on('attendance:new', (data) => {
  console.log('New check-in:', data);
});

socket.on('attendance:update', (data) => {
  console.log('Attendance updated:', data);
});
```

#### Pong
```javascript
socket.on('pong', (data) => {
  console.log('Server response:', data);
});
```

#### Errors
```javascript
socket.on('checkin:error', (data) => {
  console.error('Check-in error:', data.message);
});

socket.on('checkout:error', (data) => {
  console.error('Check-out error:', data.message);
});
```

---

## 🧪 Testing Examples

### Using cURL

#### Register
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "role": "employee"
  }'
```

#### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

#### Check-In (with token)
```bash
TOKEN="your_jwt_token_here"

curl -X POST http://localhost:3000/api/attendance/checkin \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "location": {
      "latitude": 37.7749,
      "longitude": -122.4194
    }
  }'
```

### Using Postman

1. Create a new request
2. Set method (POST, GET, etc.)
3. Add URL: `http://localhost:3000/api/...`
4. For protected routes, add header:
   - Key: `Authorization`
   - Value: `Bearer <your_token>`
5. For POST requests, add JSON body

---

## ✅ What's Implemented

- ✅ User registration with validation
- ✅ User login with JWT
- ✅ JWT authentication middleware
- ✅ Role-based authorization
- ✅ Check-in/Check-out (REST API)
- ✅ Check-in/Check-out (WebSocket)
- ✅ Attendance history with pagination
- ✅ Today's attendance
- ✅ Attendance statistics
- ✅ Real-time updates via WebSocket
- ✅ Error handling

---

## 📝 Next Steps

- [ ] User management routes (CRUD)
- [ ] Face embedding routes
- [ ] Reports and analytics endpoints
- [ ] Export functionality (CSV/PDF)
- [ ] Admin dashboard endpoints
- [ ] Multi-tenant support

---

**Base URL**: `http://localhost:3000`
**WebSocket URL**: `http://localhost:3000`

