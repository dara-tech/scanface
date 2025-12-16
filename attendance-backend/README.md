# Attendance Backend API

Backend server for Attendance App with MongoDB, Express.js, and WebSocket real-time updates.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ installed
- MongoDB installed (or use Docker)

### Installation

1. Install dependencies:
```bash
npm install
```

2. Copy environment file:
```bash
cp .env.example .env
```

3. Update `.env` with your configuration:
```env
MONGODB_URI=mongodb://localhost:27017/attendance_app
JWT_SECRET=your-secret-key
```

4. Start the server:
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

5. Test the server:
```bash
curl http://localhost:3000/health
```

## 📁 Project Structure

```
attendance-backend/
├── src/
│   ├── config/          # Configuration files
│   ├── models/          # MongoDB models
│   ├── routes/          # API routes
│   ├── controllers/     # Route controllers
│   ├── services/        # Business logic
│   ├── middleware/      # Express middleware
│   ├── utils/           # Utility functions
│   ├── socket/          # Socket.io handlers
│   └── server.js        # Entry point
├── .env                 # Environment variables
├── package.json
└── README.md
```

## 🔌 API Endpoints

### Health Check
- `GET /health` - Server health status

### Authentication (Coming soon)
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout

### WebSocket Events
- `ping` - Test connection
- `authenticate` - Authenticate socket connection
- `checkin` - Real-time check-in
- `checkout` - Real-time check-out

## 🧪 Testing WebSocket

### Using Socket.io Client
```javascript
const io = require('socket.io-client');
const socket = io('http://localhost:3000');

socket.on('connect', () => {
  console.log('Connected');
  socket.emit('ping');
});

socket.on('pong', (data) => {
  console.log('Received:', data);
});
```

## 📦 Dependencies

- **express** - Web framework
- **mongoose** - MongoDB ODM
- **socket.io** - WebSocket server
- **jsonwebtoken** - JWT authentication
- **bcryptjs** - Password hashing
- **cors** - CORS middleware
- **dotenv** - Environment variables

## 🐳 Docker Setup

```bash
# Run MongoDB in Docker
docker run -d \
  --name attendance-mongodb \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  mongo:6.0
```

## 📝 Next Steps

1. ✅ Basic server setup (Done)
2. ⏭️ Create MongoDB models
3. ⏭️ Implement authentication
4. ⏭️ Create API routes
5. ⏭️ Set up Socket.io handlers
6. ⏭️ Add error handling and logging

## 🔗 Related Documentation

- See `BACKEND_ARCHITECTURE.md` for detailed architecture
- See `BACKEND_SETUP.md` for setup guide
- See `INTEGRATION_GUIDE.md` for Flutter integration

