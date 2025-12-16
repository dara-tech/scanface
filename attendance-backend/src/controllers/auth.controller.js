const authService = require('../services/auth.service');

// Register new user
const register = async (req, res) => {
  const { name, email, password, phoneNumber, role } = req.body;

  // Basic validation
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Name, email, and password are required' });
  }

  if (password.length < 6) {
    return res.status(400).json({ error: 'Password must be at least 6 characters' });
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'Invalid email format' });
  }

  const result = await authService.register({
    name,
    email,
    password,
    phoneNumber,
    role: role || 'employee'
  });

  res.status(201).json({
    message: 'User registered successfully',
    ...result
  });
};

// Login user
const login = async (req, res) => {
  const { email, password } = req.body;

  // Basic validation
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const result = await authService.login(email, password);

  res.json({
    message: 'Login successful',
    ...result
  });
};

// Get current user
const getCurrentUser = async (req, res) => {
  try {
    res.json({
      user: req.user
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Logout (client-side token removal, but we can log it)
const logout = async (req, res) => {
  try {
    // In a more advanced setup, you could blacklist the token
    res.json({ message: 'Logout successful' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  register,
  login,
  getCurrentUser,
  logout
};

