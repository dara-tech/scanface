const Attendance = require('../models/Attendance');
const User = require('../models/User');

// Check-in
const checkIn = async (req, res) => {
  try {
    const { userId } = req.body;
    const checkInUserId = userId || req.userId;

    // Check if already checked in today
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const existingAttendance = await Attendance.findOne({
      userId: checkInUserId,
      date: { $gte: today, $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) }
    });

    if (existingAttendance && existingAttendance.checkInTime) {
      return res.status(400).json({ 
        error: 'Already checked in today',
        attendance: existingAttendance
      });
    }

    // Create or update attendance
    let attendance;
    if (existingAttendance) {
      attendance = existingAttendance;
      attendance.checkInTime = new Date();
    } else {
      attendance = new Attendance({
        userId: checkInUserId,
        date: today,
        checkInTime: new Date(),
        status: 'present'
      });
    }

    // Add location if provided
    if (req.body.location) {
      attendance.checkInLocation = {
        latitude: req.body.location.latitude,
        longitude: req.body.location.longitude,
        address: req.body.location.address
      };
    }

    await attendance.save();

    // Populate user info
    await attendance.populate('userId', 'name email');

    res.status(201).json({
      message: 'Checked in successfully',
      attendance
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Check-out
const checkOut = async (req, res) => {
  try {
    const { attendanceId } = req.params;
    const { userId } = req.body;
    const checkOutUserId = userId || req.userId;

    // Find today's attendance
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let attendance;
    if (attendanceId) {
      attendance = await Attendance.findById(attendanceId);
    } else {
      attendance = await Attendance.findOne({
        userId: checkOutUserId,
        date: { $gte: today, $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) }
      });
    }

    if (!attendance) {
      return res.status(404).json({ error: 'Attendance record not found' });
    }

    if (!attendance.checkInTime) {
      return res.status(400).json({ error: 'Must check in before checking out' });
    }

    if (attendance.checkOutTime) {
      return res.status(400).json({ error: 'Already checked out today' });
    }

    attendance.checkOutTime = new Date();
    
    // Add location if provided
    if (req.body.location) {
      attendance.checkOutLocation = {
        latitude: req.body.location.latitude,
        longitude: req.body.location.longitude,
        address: req.body.location.address
      };
    }

    // Calculate working hours
    attendance.calculateWorkingHours();

    await attendance.save();
    await attendance.populate('userId', 'name email');

    res.json({
      message: 'Checked out successfully',
      attendance
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get attendance history
const getAttendanceHistory = async (req, res) => {
  try {
    const { userId, startDate, endDate, limit = 50, page = 1 } = req.query;
    const queryUserId = userId || req.userId;

    // Build query
    const query = { userId: queryUserId };
    
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }

    // Get total count
    const total = await Attendance.countDocuments(query);

    // Get attendance records
    const attendance = await Attendance.find(query)
      .populate('userId', 'name email')
      .sort({ date: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    res.json({
      attendance,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get today's attendance
const getTodayAttendance = async (req, res) => {
  try {
    const { userId } = req.query;
    const queryUserId = userId || req.userId;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const attendance = await Attendance.findOne({
      userId: queryUserId,
      date: { $gte: today, $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) }
    }).populate('userId', 'name email');

    if (!attendance) {
      return res.json({ attendance: null, message: 'No attendance record for today' });
    }

    res.json({ attendance });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get attendance statistics
const getAttendanceStats = async (req, res) => {
  try {
    const { userId, startDate, endDate } = req.query;
    const queryUserId = userId || req.userId;

    const query = { userId: queryUserId };
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }

    const stats = await Attendance.aggregate([
      { $match: query },
      {
        $group: {
          _id: null,
          totalDays: { $sum: 1 },
          totalWorkingHours: { $sum: '$workingHours' },
          presentDays: {
            $sum: { $cond: [{ $eq: ['$status', 'present'] }, 1, 0] }
          },
          lateDays: {
            $sum: { $cond: [{ $eq: ['$isLate', true] }, 1, 0] }
          }
        }
      }
    ]);

    res.json({
      stats: stats[0] || {
        totalDays: 0,
        totalWorkingHours: 0,
        presentDays: 0,
        lateDays: 0
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  checkIn,
  checkOut,
  getAttendanceHistory,
  getTodayAttendance,
  getAttendanceStats
};

