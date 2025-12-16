const express = require('express');
const router = express.Router();
const attendanceController = require('../controllers/attendance.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

// All routes require authentication
router.use(authenticate);

// Check-in
router.post('/checkin', attendanceController.checkIn);

// Check-out
router.put('/:attendanceId/checkout', attendanceController.checkOut);
router.post('/checkout', attendanceController.checkOut); // Alternative endpoint

// Get attendance history
router.get('/', attendanceController.getAttendanceHistory);

// Get today's attendance
router.get('/today', attendanceController.getTodayAttendance);

// Get attendance statistics
router.get('/stats', attendanceController.getAttendanceStats);

module.exports = router;

