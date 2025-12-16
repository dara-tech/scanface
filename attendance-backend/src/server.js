const express = require('express');        
const http = require('http');
const https = require('https');
const socketIo = require('socket.io');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
const server = http.createServer(app);

// CORS configuration for mobile apps
// For mobile apps (Flutter, React Native), CORS works differently than web browsers
// Mobile apps don't have browser CORS restrictions, but we still configure it for security
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, curl, etc.)
    if (!origin) {
      return callback(null, true);
    }
    
    // Get allowed origins from environment variable
    const allowedOrigins = process.env.CORS_ORIGIN 
      ? process.env.CORS_ORIGIN.split(',').map(o => o.trim())
      : ['*'];
    
    // Allow all origins if '*' is specified (for mobile apps)
    if (allowedOrigins.includes('*')) {
      return callback(null, true);
    }
    
    // Check if origin is in allowed list
    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
};

// Socket.io setup with CORS
const io = socketIo(server, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || "*",
    methods: ["GET", "POST", "OPTIONS"],
    credentials: true
  }
});

// Middleware - Apply CORS
app.use(cors(corsOptions));
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
app.use('/api/users', require('./routes/user.routes'));

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

// Auto-ping function to keep server alive (for Render free tier)
// Pings the server every 14 minutes to prevent spin-down
function startAutoPing(serverUrl) {
  // Ensure URL ends with /health
  const pingUrl = serverUrl.endsWith('/health') ? serverUrl : `${serverUrl}/health`;
  const pingInterval = 14 * 60 * 1000; // 14 minutes in milliseconds

  console.log(`🔄 Auto-ping enabled: Will ping ${pingUrl} every 14 minutes`);

  // Ping immediately on startup
  pingServer(pingUrl);

  // Then ping every 14 minutes
  setInterval(() => {
    pingServer(pingUrl);
  }, pingInterval);
}

// Function to ping the server
function pingServer(url) {
  try {
    const urlObj = new URL(url);
    const isHttps = urlObj.protocol === 'https:';
    const httpModule = isHttps ? https : http;
    
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname,
      method: 'GET',
      timeout: 10000, // 10 second timeout
    };

    const req = httpModule.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log(`✅ Auto-ping successful: ${url} - ${new Date().toLocaleTimeString()}`);
        } else {
          console.log(`⚠️ Auto-ping returned status ${res.statusCode}: ${url}`);
        }
      });
    });

    req.on('error', (error) => {
      console.log(`❌ Auto-ping error: ${error.message}`);
    });

    req.on('timeout', () => {
      req.destroy();
      console.log(`⏱️ Auto-ping timeout: ${url}`);
    });

    req.end();
  } catch (error) {
    console.log(`❌ Auto-ping failed: ${error.message}`);
  }
}

// Listen on all network interfaces (0.0.0.0) to allow connections from other devices
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`🌐 Server accessible from network: http://0.0.0.0:${PORT}`);
  console.log(`📡 WebSocket server ready`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`💡 For Android device, use your Mac's IP: http://192.168.0.107:${PORT}`);
  
  // Start auto-ping if SERVER_URL or RENDER_URL is set (production)
  let serverUrl = process.env.SERVER_URL || process.env.RENDER_URL;
  
  if (!serverUrl && process.env.NODE_ENV === 'production') {
    // In production, try to auto-detect Render URL
    serverUrl = process.env.RENDER_EXTERNAL_URL || `https://scanface-tztq.onrender.com`;
  }
  
  if (serverUrl) {
    startAutoPing(serverUrl);
  }
});

// Export io for use in other files
module.exports = { app, server, io };

