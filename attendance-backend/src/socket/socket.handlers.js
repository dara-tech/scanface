const Attendance = require('../models/Attendance');
const User = require('../models/User');

function setupSocketHandlers(io) {
  // Socket.io authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');
      
      if (!token) {
        return next(new Error('Authentication error: No token provided'));
      }

      // Verify token (you'll need to import jwt)
      const jwt = require('jsonwebtoken');
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Get user
      const user = await User.findById(decoded.userId).select('-password');
      if (!user || !user.isActive) {
        return next(new Error('Authentication error: Invalid user'));
      }

      // Attach user to socket
      socket.userId = user._id.toString();
      socket.user = user;
      socket.organizationId = user.organizationId?.toString();
      
      next();
    } catch (error) {
      next(new Error('Authentication error: Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Client connected: ${socket.id} (User: ${socket.user?.name})`);

    // Join organization room
    if (socket.organizationId) {
      socket.join(`org:${socket.organizationId}`);
    }

    // Handle check-in
    socket.on('checkin', async (data) => {
      try {
        const { location } = data;
        const userId = socket.userId;

        // Check if already checked in today
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        let attendance = await Attendance.findOne({
          userId,
          date: { $gte: today, $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) }
        });

        if (attendance && attendance.checkInTime) {
          socket.emit('checkin:error', { message: 'Already checked in today' });
          return;
        }

        if (!attendance) {
          attendance = new Attendance({
            userId,
            date: today,
            checkInTime: new Date(),
            status: 'present'
          });
        } else {
          attendance.checkInTime = new Date();
        }

        if (location) {
          attendance.checkInLocation = {
            latitude: location.latitude,
            longitude: location.longitude,
            address: location.address
          };
        }

        await attendance.save();
        await attendance.populate('userId', 'name email');

        // Emit success to sender
        socket.emit('checkin:success', { attendance });

        // Broadcast to organization room
        if (socket.organizationId) {
          io.to(`org:${socket.organizationId}`).emit('attendance:new', {
            attendanceId: attendance._id,
            userId: attendance.userId._id,
            userName: attendance.userId.name,
            checkInTime: attendance.checkInTime,
            status: attendance.status
          });
        }
      } catch (error) {
        console.error('Check-in error:', error);
        socket.emit('checkin:error', { message: error.message });
      }
    });

    // Handle check-out
    socket.on('checkout', async (data) => {
      try {
        const { attendanceId, location } = data;
        const userId = socket.userId;

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        let attendance;
        if (attendanceId) {
          attendance = await Attendance.findById(attendanceId);
        } else {
          attendance = await Attendance.findOne({
            userId,
            date: { $gte: today, $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) }
          });
        }

        if (!attendance) {
          socket.emit('checkout:error', { message: 'Attendance record not found' });
          return;
        }

        if (!attendance.checkInTime) {
          socket.emit('checkout:error', { message: 'Must check in before checking out' });
          return;
        }

        if (attendance.checkOutTime) {
          socket.emit('checkout:error', { message: 'Already checked out today' });
          return;
        }

        attendance.checkOutTime = new Date();
        
        if (location) {
          attendance.checkOutLocation = {
            latitude: location.latitude,
            longitude: location.longitude,
            address: location.address
          };
        }

        attendance.calculateWorkingHours();
        await attendance.save();
        await attendance.populate('userId', 'name email');

        // Emit success to sender
        socket.emit('checkout:success', { attendance });

        // Broadcast to organization room
        if (socket.organizationId) {
          io.to(`org:${socket.organizationId}`).emit('attendance:update', {
            attendanceId: attendance._id,
            userId: attendance.userId._id,
            checkOutTime: attendance.checkOutTime,
            workingHours: attendance.workingHours
          });
        }
      } catch (error) {
        console.error('Check-out error:', error);
        socket.emit('checkout:error', { message: error.message });
      }
    });

    // Ping/Pong for connection testing
    socket.on('ping', () => {
      socket.emit('pong', {
        message: 'Server is alive!',
        timestamp: new Date().toISOString(),
        userId: socket.userId
      });
    });

    // Disconnect handler
    socket.on('disconnect', () => {
      console.log(`🔌 Client disconnected: ${socket.id}`);
    });
  });
}

module.exports = setupSocketHandlers;

