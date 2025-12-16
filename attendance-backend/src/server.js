const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
const server = http.createServer(app);

// Socket.io setup with CORS
const io = socketIo(server, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || "*",
    methods: ["GET", "POST"],
    credentials: true
  }
});

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || "*",
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MongoDB Connection
const connectDB = require('./config/database');
connectDB();

// Socket.io Handlers
const setupSocketHandlers = require('./socket/socket.handlers');
setupSocketHandlers(io);

// Health check route
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  });
});

// API routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/attendance', require('./routes/attendance.routes'));
// app.use('/api/users', require('./routes/user.routes')); // Coming soon

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler (must be last)
app.use((err, req, res, next) => {
  console.error('Error:', err);
  if (err.stack) {
    console.error('Error stack:', err.stack);
  }
  
  // Don't send response if headers already sent
  if (res.headersSent) {
    return next(err);
  }
  
  // Determine status code based on error type
  let statusCode = 500;
  if (err.status || err.statusCode) {
    statusCode = err.status || err.statusCode;
  } else if (err.name === 'ValidationError' || err.message?.includes('required')) {
    statusCode = 400;
  } else if (err.message?.includes('already exists') || err.code === 11000) {
    statusCode = 400;
  } else if (err.message?.includes('Invalid') || err.message?.includes('not found')) {
    statusCode = 400;
  }
  
  res.status(statusCode).json({ 
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

const PORT = process.env.PORT || 3000;
// Listen on all network interfaces (0.0.0.0) to allow connections from other devices
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`🌐 Server accessible from network: http://0.0.0.0:${PORT}`);
  console.log(`📡 WebSocket server ready`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`💡 For Android device, use your Mac's IP: http://192.168.0.107:${PORT}`);
});

// Export io for use in other files
module.exports = { app, server, io };

