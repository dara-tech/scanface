const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

// Register new user
const register = async (userData) => {
  // Check if user already exists
  const existingUser = await User.findOne({ email: userData.email });
  if (existingUser) {
    throw new Error('User with this email already exists');
  }

  // Create new user
  const user = new User(userData);
  await user.save();

  // Generate token
  const token = generateToken(user._id);

  return {
    user: user.toPublicJSON(),
    token
  };
};

// Login user
const login = async (email, password) => {
  // Find user and include password for comparison
  const user = await User.findOne({ email }).select('+password');
  
  if (!user) {
    throw new Error('Invalid email or password');
  }

  if (!user.isActive) {
    throw new Error('User account is inactive');
  }

  // Compare password
  const isPasswordValid = await user.comparePassword(password);
  if (!isPasswordValid) {
    throw new Error('Invalid email or password');
  }

  // Update last login
  user.lastLoginAt = new Date();
  await user.save();

  // Generate token
  const token = generateToken(user._id);

  return {
    user: user.toPublicJSON(),
    token
  };
};

module.exports = {
  generateToken,
  register,
  login
};

