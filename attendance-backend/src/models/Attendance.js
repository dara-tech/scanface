const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  organizationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: false
  },
  date: {
    type: Date,
    required: true,
    index: true
  },
  checkInTime: {
    type: Date,
    required: false
  },
  checkOutTime: {
    type: Date,
    required: false
  },
  status: {
    type: String,
    enum: ['present', 'absent', 'late', 'early', 'half-day'],
    default: 'present'
  },
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
  workingHours: {
    type: Number, // in minutes
    default: 0
  },
  isLate: {
    type: Boolean,
    default: false
  },
  notes: String
}, {
  timestamps: true
});

// Compound index for efficient queries
attendanceSchema.index({ userId: 1, date: -1 });
attendanceSchema.index({ organizationId: 1, date: -1 });
attendanceSchema.index({ date: -1 });

// Virtual for calculating working hours
attendanceSchema.virtual('calculatedWorkingHours').get(function() {
  if (this.checkInTime && this.checkOutTime) {
    const diff = this.checkOutTime - this.checkInTime;
    return Math.round(diff / (1000 * 60)); // Convert to minutes
  }
  return 0;
});

// Method to calculate working hours
attendanceSchema.methods.calculateWorkingHours = function() {
  if (this.checkInTime && this.checkOutTime) {
    const diff = this.checkOutTime - this.checkInTime;
    this.workingHours = Math.round(diff / (1000 * 60));
    return this.workingHours;
  }
  return 0;
};

// Ensure one attendance record per user per day
attendanceSchema.index({ userId: 1, date: 1 }, { unique: true });

module.exports = mongoose.model('Attendance', attendanceSchema);

