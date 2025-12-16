const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    index: true
  },
  password: {
    type: String,
    required: true,
    select: false // Don't return password by default
  },
  name: {
    type: String,
    required: true
  },
  phoneNumber: String,
  role: {
    type: String,
    enum: ['admin', 'employee', 'student'],
    required: true,
    default: 'employee'
  },
  department: String,
  organizationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: false // Will be required when multi-tenant is implemented
  },
  isActive: {
    type: Boolean,
    default: true
  },
  profileImageUrl: String,
  lastLoginAt: Date,
  faceEmbeddings: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'FaceEmbedding'
  }]
}, {
  timestamps: true
});

// Indexes for performance
userSchema.index({ email: 1 });
userSchema.index({ organizationId: 1 });
userSchema.index({ role: 1 });
userSchema.index({ isActive: 1 });

// Hash password before saving
userSchema.pre('save', async function() {
  // Only hash password if it's been modified (or is new)
  if (!this.isModified('password')) {
    return;
  }
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
  } catch (error) {
    throw error;
  }
});

// Method to compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Method to get public user data (without password)
userSchema.methods.toPublicJSON = function() {
  const userObject = this.toObject();
  delete userObject.password;
  return userObject;
};

module.exports = mongoose.model('User', userSchema);

