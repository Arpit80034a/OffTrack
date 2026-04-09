const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { db } = require('../config/firebase');

const register = async (req, res) => {
  try {
    const { name, email, password, timezone } = req.body;

    // Check if the user already exists
    const usersRef = db.collection('users');
    const snapshot = await usersRef.where('email', '==', email).get();
    if (!snapshot.empty) {
      return res.status(400).json({ error: 'User already exists with this email.' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(12);
    const passwordHash = await bcrypt.hash(password, salt);

    // Create user (new)
    const userId = uuidv4();
    const userData = {
      user_id: userId,
      name,
      email,
      password_hash: passwordHash,
      timezone: timezone || 'UTC',
      created_at: new Date().toISOString(),
    };

    await usersRef.doc(userId).set(userData);

    // Create default preferences
    const prefId = uuidv4();
    await db.collection('preferences').doc(prefId).set({
      preference_id: prefId,
      user_id: userId,
      work_start_time: '09:00',
      work_end_time: '17:00',
      break_duration: 15,
      focus_level: 'medium',
    });

    // Generate JWT
    const token = jwt.sign(
      { user_id: userId, email },
      process.env.JWT_SECRET || 'dev_secret_key',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: { user_id: userId, name, email, timezone: userData.timezone },
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const usersRef = db.collection('users');
    const snapshot = await usersRef.where('email', '==', email).get();
    if (snapshot.empty) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();

    // Verify password
    const isMatch = await bcrypt.compare(password, userData.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    // Generate JWT
    const token = jwt.sign(
      { user_id: userData.user_id, email: userData.email },
      process.env.JWT_SECRET || 'dev_secret_key',
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        user_id: userData.user_id,
        name: userData.name,
        email: userData.email,
        timezone: userData.timezone,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { register, login };
