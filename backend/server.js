require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const authRoutes = require('./routes/auth');
const taskRoutes = require('./routes/tasks');
const scheduleRoutes = require('./routes/schedule');
const habitRoutes = require('./routes/habits');
const notificationRoutes = require('./routes/notifications');
const calendarRoutes = require('./routes/calendar');
const preferencesRoutes = require('./routes/preferences');

const app = express();
const PORT = process.env.PORT || 5000;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/', (req, res) => {
  res.json({
    message: 'Intelligent Schedule Manager API',
    version: '1.0.0',
    status: 'running',
  });
});

// API Routes
app.use('/auth', authRoutes);
app.use('/tasks', taskRoutes);
app.use('/schedule', scheduleRoutes);
app.use('/habits', habitRoutes);
app.use('/notifications', notificationRoutes);
app.use('/calendar', calendarRoutes);
app.use('/preferences', preferencesRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 API available at http://localhost:${PORT}`);
});

module.exports = app;
