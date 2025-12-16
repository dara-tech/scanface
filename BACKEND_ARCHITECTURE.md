# Backend Architecture Plan - MongoDB + Express.js + WebSocket

## 🏗️ Architecture Overview

### Technology Stack
- **Backend Framework**: Express.js (Node.js)
- **Database**: MongoDB with Mongoose ODM
- **Real-time**: Socket.io (WebSocket)
- **Authentication**: JWT (JSON Web Tokens)
- **API**: RESTful API + WebSocket events
- **File Storage**: MongoDB GridFS or AWS S3/MinIO

### Architecture Diagram
```
┌─────────────────┐
│  Flutter App    │
│  (Mobile/Web)   │
└────────┬────────┘
         │
         │ HTTP/REST + WebSocket
         │
┌────────▼─────────────────────────┐
│      Express.js Server           │
│  ┌────────────────────────────┐  │
│  │  REST API Routes           │  │
│  │  - /api/auth               │  │
│  │  - /api/users              │  │
│  │  - /api/attendance         │  │
│  │  - /api/reports            │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │  Socket.io Server          │  │
│  │  - Real-time updates       │  │
│  │  - Live attendance feed    │  │
│  │  - Notification events     │  │
│  └────────────────────────────┘  │
└────────┬─────────────────────────┘
         │
         │ MongoDB Driver
         │
┌────────▼────────┐
│    MongoDB      │
│  - Users        │
│  - Attendance   │
│  - Face Data    │
│  - Organizations│
└─────────────────┘
```

---

## 📁 Backend Project Structure

```
attendance-backend/
├── src/
│   ├── config/
│   │   ├── database.js          # MongoDB connection
│   │   ├── socket.js            # Socket.io setup
│   │   └── environment.js       # Environment variables
│   │
│   ├── models/
│   │   ├── User.js              # User schema
│   │   ├── Attendance.js        # Attendance schema
│   │   ├── FaceEmbedding.js    # Face data schema
│   │   ├── Organization.js      # Multi-tenant schema
│   │   └── AuditLog.js          # Audit trail schema
│   │
│   ├── routes/
│   │   ├── auth.routes.js       # Authentication routes
│   │   ├── user.routes.js       # User management
│   │   ├── attendance.routes.js # Attendance CRUD
│   │   ├── report.routes.js     # Report generation
│   │   └── face.routes.js       # Face registration
│   │
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── user.controller.js
│   │   ├── attendance.controller.js
│   │   ├── report.controller.js
│   │   └── face.controller.js
│   │
│   ├── services/
│   │   ├── auth.service.js       # JWT, password hashing
│   │   ├── socket.service.js     # Socket.io events
│   │   ├── sync.service.js       # Data synchronization
│   │   ├── export.service.js     # CSV/PDF export
│   │   └── notification.service.js
│   │
│   ├── middleware/
│   │   ├── auth.middleware.js    # JWT verification
│   │   ├── role.middleware.js    # Role-based access
│   │   ├── validation.middleware.js
│   │   └── error.middleware.js
│   │
│   ├── utils/
│   │   ├── logger.js             # Winston logger
│   │   ├── encryption.js         # Data encryption
│   │   └── helpers.js
│   │
│   ├── socket/
│   │   ├── socket.handlers.js    # Socket event handlers
│   │   └── socket.middleware.js  # Socket auth
│   │
│   └── server.js                 # Express app entry
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .env.example
├── .gitignore
├── package.json
├── docker-compose.yml            # MongoDB container
└── README.md
```

---

## 🗄️ MongoDB Schema Design

### 1. User Collection
```javascript
{
  _id: ObjectId,
  email: String (unique, indexed),
  password: String (hashed),
  name: String,
  phoneNumber: String,
  role: String, // 'admin', 'employee', 'student'
  department: String,
  organizationId: ObjectId (ref: Organization),
  isActive: Boolean,
  profileImageUrl: String,
  faceEmbeddings: [ObjectId] (ref: FaceEmbedding),
  createdAt: Date,
  updatedAt: Date,
  lastLoginAt: Date
}
```

### 2. Attendance Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User, indexed),
  organizationId: ObjectId (ref: Organization, indexed),
  date: Date (indexed),
  checkInTime: Date,
  checkOutTime: Date,
  status: String, // 'present', 'absent', 'late', 'early'
  checkInLocation: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  checkOutLocation: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  workingHours: Number, // in minutes
  isLate: Boolean,
  notes: String,
  createdAt: Date,
  updatedAt: Date
}
```

### 3. FaceEmbedding Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User, indexed),
  organizationId: ObjectId (ref: Organization),
  embedding: [Number], // Face embedding vector
  imageUrl: String, // Stored in GridFS or S3
  imageMetadata: {
    width: Number,
    height: Number,
    format: String
  },
  isActive: Boolean,
  createdAt: Date
}
```

### 4. Organization Collection (Multi-tenant)
```javascript
{
  _id: ObjectId,
  name: String,
  domain: String (unique),
  settings: {
    workingHours: {
      start: String, // "09:00"
      end: String,   // "18:00"
    },
    lateThreshold: Number, // minutes
    timezone: String
  },
  subscription: {
    plan: String, // 'free', 'pro', 'enterprise'
    maxUsers: Number,
    expiresAt: Date
  },
  createdAt: Date,
  updatedAt: Date
}
```

### 5. AuditLog Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User),
  organizationId: ObjectId (ref: Organization),
  action: String, // 'login', 'checkin', 'user_created', etc.
  resource: String, // 'attendance', 'user', etc.
  resourceId: ObjectId,
  metadata: Object,
  ipAddress: String,
  userAgent: String,
  createdAt: Date
}
```

### 6. SyncQueue Collection (Offline Support)
```javascript
{
  _id: ObjectId,
  deviceId: String,
  userId: ObjectId (ref: User),
  action: String, // 'create', 'update', 'delete'
  resource: String,
  data: Object,
  status: String, // 'pending', 'synced', 'failed'
  retryCount: Number,
  error: String,
  createdAt: Date,
  syncedAt: Date
}
```

---

## 🔌 WebSocket Events (Socket.io)

### Client → Server Events

#### Authentication
```javascript
socket.emit('authenticate', { token: jwtToken });
```

#### Check-in/Check-out
```javascript
socket.emit('checkin', {
  userId: string,
  location: { lat, lng },
  timestamp: Date
});

socket.emit('checkout', {
  userId: string,
  attendanceId: string,
  location: { lat, lng },
  timestamp: Date
});
```

#### Subscribe to Updates
```javascript
socket.emit('subscribe', {
  type: 'attendance', // 'attendance', 'users', 'reports'
  organizationId: string
});
```

### Server → Client Events

#### Real-time Attendance Updates
```javascript
socket.on('attendance:new', (data) => {
  // New check-in event
  // { userId, userName, checkInTime, status }
});

socket.on('attendance:update', (data) => {
  // Check-out or status update
  // { attendanceId, checkOutTime, workingHours }
});
```

#### User Status Updates
```javascript
socket.on('user:status', (data) => {
  // User active/inactive status
  // { userId, isActive }
});
```

#### Notification Events
```javascript
socket.on('notification', (data) => {
  // Push notifications
  // { type, title, message, userId }
});
```

#### Sync Status
```javascript
socket.on('sync:status', (data) => {
  // Sync progress updates
  // { status, progress, message }
});
```

---

## 🔐 API Endpoints

### Authentication
```
POST   /api/auth/register        # Register new user
POST   /api/auth/login           # Login
POST   /api/auth/logout          # Logout
POST   /api/auth/refresh         # Refresh token
POST   /api/auth/forgot-password # Password reset
```

### Users
```
GET    /api/users                # List users (admin)
GET    /api/users/:id            # Get user details
POST   /api/users                # Create user (admin)
PUT    /api/users/:id            # Update user
DELETE /api/users/:id            # Delete user
POST   /api/users/bulk-import     # Bulk import (CSV)
GET    /api/users/:id/attendance # User attendance history
```

### Attendance
```
GET    /api/attendance           # List attendance (with filters)
GET    /api/attendance/:id       # Get attendance record
POST   /api/attendance/checkin  # Check-in
PUT    /api/attendance/:id/checkout # Check-out
GET    /api/attendance/stats     # Attendance statistics
GET    /api/attendance/today     # Today's attendance
```

### Reports
```
GET    /api/reports/daily        # Daily report
GET    /api/reports/weekly       # Weekly report
GET    /api/reports/monthly      # Monthly report
GET    /api/reports/custom       # Custom date range
GET    /api/reports/export/csv  # Export CSV
GET    /api/reports/export/pdf   # Export PDF
GET    /api/reports/analytics    # Analytics data
```

### Face Recognition
```
POST   /api/face/register        # Register face
GET    /api/face/:userId         # Get user faces
DELETE /api/face/:id              # Delete face
POST   /api/face/verify           # Verify face (check-in)
```

### Sync
```
GET    /api/sync/status          # Get sync status
POST   /api/sync/push            # Push local changes
GET    /api/sync/pull            # Pull server changes
POST   /api/sync/resolve         # Resolve conflicts
```

---

## 🚀 Implementation Steps

### Step 1: Project Setup
```bash
# Create backend directory
mkdir attendance-backend
cd attendance-backend

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express mongoose socket.io jsonwebtoken bcryptjs
npm install cors dotenv winston express-validator
npm install multer gridfs-stream

# Dev dependencies
npm install -D nodemon jest supertest
```

### Step 2: Basic Express Server
```javascript
// server.js
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*", // Configure for production
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('MongoDB connected');
}).catch(err => {
  console.error('MongoDB connection error:', err);
});

// Socket.io Connection
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Routes
app.use('/api/auth', require('./src/routes/auth.routes'));
app.use('/api/users', require('./src/routes/user.routes'));
app.use('/api/attendance', require('./src/routes/attendance.routes'));

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Step 3: MongoDB Models
```javascript
// src/models/User.js
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  phoneNumber: String,
  role: {
    type: String,
    enum: ['admin', 'employee', 'student'],
    required: true
  },
  department: String,
  organizationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: true
  },
  isActive: {
    type: Boolean,
    default: true
  },
  profileImageUrl: String,
  lastLoginAt: Date
}, {
  timestamps: true
});

// Indexes
userSchema.index({ email: 1 });
userSchema.index({ organizationId: 1 });
userSchema.index({ role: 1 });

module.exports = mongoose.model('User', userSchema);
```

### Step 4: Socket.io Real-time Handlers
```javascript
// src/socket/socket.handlers.js
const Attendance = require('../models/Attendance');
const User = require('../models/User');

function setupSocketHandlers(io) {
  io.on('connection', (socket) => {
    // Authenticate socket
    socket.on('authenticate', async (data) => {
      // Verify JWT token
      // Store user info in socket
      socket.userId = data.userId;
      socket.organizationId = data.organizationId;
      
      // Join organization room
      socket.join(`org:${data.organizationId}`);
    });

    // Handle check-in
    socket.on('checkin', async (data) => {
      try {
        const attendance = await Attendance.create({
          userId: data.userId,
          organizationId: data.organizationId,
          date: new Date(),
          checkInTime: new Date(),
          status: 'present',
          checkInLocation: data.location
        });

        const user = await User.findById(data.userId);
        
        // Broadcast to organization room
        io.to(`org:${data.organizationId}`).emit('attendance:new', {
          attendanceId: attendance._id,
          userId: user._id,
          userName: user.name,
          checkInTime: attendance.checkInTime,
          status: attendance.status
        });

        socket.emit('checkin:success', { attendanceId: attendance._id });
      } catch (error) {
        socket.emit('checkin:error', { message: error.message });
      }
    });

    // Handle check-out
    socket.on('checkout', async (data) => {
      try {
        const attendance = await Attendance.findById(data.attendanceId);
        if (!attendance) {
          throw new Error('Attendance record not found');
        }

        attendance.checkOutTime = new Date();
        attendance.checkOutLocation = data.location;
        
        // Calculate working hours
        const hours = (attendance.checkOutTime - attendance.checkInTime) / (1000 * 60);
        attendance.workingHours = hours;
        
        await attendance.save();

        // Broadcast update
        io.to(`org:${attendance.organizationId}`).emit('attendance:update', {
          attendanceId: attendance._id,
          checkOutTime: attendance.checkOutTime,
          workingHours: attendance.workingHours
        });

        socket.emit('checkout:success', { attendanceId: attendance._id });
      } catch (error) {
        socket.emit('checkout:error', { message: error.message });
      }
    });
  });
}

module.exports = setupSocketHandlers;
```

---

## 📦 Required Packages

### Core Dependencies
```json
{
  "express": "^4.18.2",
  "mongoose": "^7.0.0",
  "socket.io": "^4.6.0",
  "jsonwebtoken": "^9.0.0",
  "bcryptjs": "^2.4.3",
  "cors": "^2.8.5",
  "dotenv": "^16.0.3",
  "winston": "^3.8.2",
  "express-validator": "^6.14.3",
  "multer": "^1.4.5-lts.1",
  "gridfs-stream": "^1.1.1",
  "moment": "^2.29.4",
  "csv-writer": "^1.6.0",
  "pdfkit": "^0.13.0"
}
```

### Development Dependencies
```json
{
  "nodemon": "^2.0.20",
  "jest": "^29.4.0",
  "supertest": "^6.3.3",
  "eslint": "^8.35.0"
}
```

---

## 🔧 Environment Variables

```env
# .env
NODE_ENV=development
PORT=3000

# MongoDB
MONGODB_URI=mongodb://localhost:27017/attendance_app
MONGODB_URI_PROD=mongodb+srv://user:pass@cluster.mongodb.net/attendance_app

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8080

# File Storage
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760

# Socket.io
SOCKET_CORS_ORIGIN=*
```

---

## 🐳 Docker Setup

```yaml
# docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:6.0
    container_name: attendance-mongodb
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    volumes:
      - mongodb_data:/data/db
    networks:
      - attendance-network

  backend:
    build: .
    container_name: attendance-backend
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      MONGODB_URI: mongodb://mongodb:27017/attendance_app
    depends_on:
      - mongodb
    networks:
      - attendance-network

volumes:
  mongodb_data:

networks:
  attendance-network:
    driver: bridge
```

---

## 🔄 Flutter Integration

### Socket.io Client Setup
```dart
// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;
  
  void connect(String serverUrl, String token) {
    socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setExtraHeaders({'Authorization': 'Bearer $token'})
      .build());
    
    socket!.onConnect((_) {
      print('Socket connected');
      socket!.emit('authenticate', {'token': token});
    });
    
    socket!.onDisconnect((_) => print('Socket disconnected'));
    
    // Listen for real-time updates
    socket!.on('attendance:new', (data) {
      // Handle new attendance event
    });
  }
  
  void disconnect() {
    socket?.disconnect();
  }
}
```

### API Service
```dart
// lib/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://your-backend-url/api',
    headers: {'Content-Type': 'application/json'},
  ));
  
  Future<Response> checkIn(String userId, Map<String, dynamic> data) async {
    return await _dio.post('/attendance/checkin', data: {
      'userId': userId,
      ...data,
    });
  }
}
```

---

## 📊 Performance Considerations

### Database Indexing
```javascript
// Create indexes for performance
db.attendance.createIndex({ userId: 1, date: -1 });
db.attendance.createIndex({ organizationId: 1, date: -1 });
db.users.createIndex({ email: 1 });
db.users.createIndex({ organizationId: 1, role: 1 });
```

### Caching Strategy
- Use Redis for session storage
- Cache frequently accessed data
- Cache report results

### Scaling
- Horizontal scaling with PM2 cluster mode
- Load balancing with Nginx
- MongoDB replica sets
- Socket.io Redis adapter for multi-server

---

## 🔒 Security Best Practices

1. **JWT Token Management**
   - Short expiration times
   - Refresh token rotation
   - Token blacklisting

2. **Input Validation**
   - Use express-validator
   - Sanitize all inputs
   - Validate file uploads

3. **Rate Limiting**
   - Limit API requests
   - Prevent brute force attacks

4. **HTTPS**
   - Always use HTTPS in production
   - Secure WebSocket (WSS)

5. **Data Encryption**
   - Encrypt sensitive data at rest
   - Use TLS for data in transit

---

## 📝 Next Steps

1. **Set up backend project structure**
2. **Configure MongoDB connection**
3. **Implement authentication (JWT)**
4. **Create REST API endpoints**
5. **Set up Socket.io real-time events**
6. **Integrate with Flutter app**
7. **Add error handling and logging**
8. **Write tests**
9. **Deploy to production**

---

**Last Updated**: December 2025
**Status**: Planning Phase

