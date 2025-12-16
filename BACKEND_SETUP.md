# Backend Setup Guide - MongoDB + Express.js + WebSocket

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Node.js 18+ installed
- MongoDB installed (or use Docker)
- Git

### Step 1: Create Backend Directory
```bash
# In your project root
mkdir attendance-backend
cd attendance-backend
```

### Step 2: Initialize Project
```bash
npm init -y
```

### Step 3: Install Dependencies
```bash
# Core dependencies
npm install express mongoose socket.io jsonwebtoken bcryptjs
npm install cors dotenv winston express-validator multer

# Development dependencies
npm install -D nodemon jest supertest
```

### Step 4: Create Basic Structure
```bash
mkdir -p src/{config,models,routes,controllers,services,middleware,utils,socket}
touch src/server.js
touch .env
touch .gitignore
```

### Step 5: Basic Server Setup

**src/server.js**
```javascript
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/attendance_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('✅ MongoDB connected');
}).catch(err => {
  console.error('❌ MongoDB connection error:', err);
});

// Socket.io Setup
io.on('connection', (socket) => {
  console.log('🔌 Client connected:', socket.id);
  
  socket.on('disconnect', () => {
    console.log('🔌 Client disconnected:', socket.id);
  });
  
  // Test event
  socket.on('ping', () => {
    socket.emit('pong', { message: 'Server is alive!' });
  });
});

// Health check route
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// API routes will go here
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/users', require('./routes/user.routes'));
app.use('/api/attendance', require('./routes/attendance.routes'));

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📡 WebSocket server ready`);
});
```

### Step 6: Environment Variables

**.env**
```env
NODE_ENV=development
PORT=3000

# MongoDB
MONGODB_URI=mongodb://localhost:27017/attendance_app

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:8080,http://localhost:3000
```

### Step 7: Update package.json
```json
{
  "name": "attendance-backend",
  "version": "1.0.0",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest"
  }
}
```

### Step 8: Run the Server
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

---

## 🗄️ MongoDB Setup

### Option 1: Local MongoDB
```bash
# Install MongoDB (macOS)
brew install mongodb-community

# Start MongoDB
brew services start mongodb-community

# Or run manually
mongod --config /usr/local/etc/mongod.conf
```

### Option 2: Docker (Recommended)
```bash
# Run MongoDB in Docker
docker run -d \
  --name attendance-mongodb \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  mongo:6.0

# Or use docker-compose.yml (see BACKEND_ARCHITECTURE.md)
```

### Option 3: MongoDB Atlas (Cloud)
1. Go to https://www.mongodb.com/cloud/atlas
2. Create free cluster
3. Get connection string
4. Update `MONGODB_URI` in `.env`

---

## 📦 Project Structure

```
attendance-backend/
├── src/
│   ├── config/
│   │   ├── database.js
│   │   └── socket.js
│   ├── models/
│   │   ├── User.js
│   │   ├── Attendance.js
│   │   └── FaceEmbedding.js
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   └── attendance.routes.js
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   └── attendance.controller.js
│   ├── services/
│   │   └── socket.service.js
│   ├── middleware/
│   │   └── auth.middleware.js
│   ├── socket/
│   │   └── socket.handlers.js
│   └── server.js
├── .env
├── .gitignore
├── package.json
└── README.md
```

---

## 🔌 WebSocket Quick Test

### Server Side (src/socket/socket.handlers.js)
```javascript
function setupSocketHandlers(io) {
  io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);
    
    // Authenticate
    socket.on('authenticate', (data) => {
      // Verify JWT token here
      socket.userId = data.userId;
      socket.organizationId = data.organizationId;
      socket.join(`org:${data.organizationId}`);
      socket.emit('authenticated', { success: true });
    });
    
    // Real-time check-in
    socket.on('checkin', async (data) => {
      // Save to database
      // Broadcast to organization room
      io.to(`org:${data.organizationId}`).emit('attendance:new', {
        userId: data.userId,
        checkInTime: new Date(),
        status: 'present'
      });
    });
  });
}

module.exports = setupSocketHandlers;
```

### Flutter Client Test
```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Connect
final socket = IO.io('http://localhost:3000', <String, dynamic>{
  'transports': ['websocket'],
});

socket.onConnect((_) {
  print('Connected');
  socket.emit('ping');
});

socket.on('pong', (data) {
  print('Received: $data');
});
```

---

## ✅ Verification Checklist

- [ ] Server starts without errors
- [ ] MongoDB connection successful
- [ ] Health check endpoint works (`GET /health`)
- [ ] Socket.io connection established
- [ ] Can emit/receive test events
- [ ] Environment variables loaded correctly

---

## 🐛 Common Issues

### MongoDB Connection Failed
```bash
# Check if MongoDB is running
mongosh

# Or check Docker container
docker ps | grep mongo
```

### Port Already in Use
```bash
# Change PORT in .env or kill process
lsof -ti:3000 | xargs kill
```

### Socket.io CORS Error
```javascript
// Update CORS settings in server.js
const io = socketIo(server, {
  cors: {
    origin: "http://localhost:8080", // Your Flutter app URL
    methods: ["GET", "POST"]
  }
});
```

---

## 📚 Next Steps

1. ✅ **Basic server running** (You are here)
2. ⏭️ **Create MongoDB models** (User, Attendance, etc.)
3. ⏭️ **Implement authentication** (JWT)
4. ⏭️ **Create REST API endpoints**
5. ⏭️ **Set up Socket.io real-time events**
6. ⏭️ **Integrate with Flutter app**

See `BACKEND_ARCHITECTURE.md` for detailed implementation guide.

---

**Ready to code?** Start with creating the User model and authentication routes!

