const express = require('express');
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { createNotification, getNotifications, markDelivered, deleteNotification } = require('../controllers/notificationController');

const router = express.Router();

router.get('/', auth, getNotifications);

router.post(
  '/',
  auth,
  [
    body('message').trim().notEmpty().withMessage('Message is required'),
    body('trigger_time').notEmpty().withMessage('Trigger time is required'),
  ],
  validate,
  createNotification
);

router.put('/:id/mark-read', auth, markDelivered);
router.delete('/:id', auth, deleteNotification);

module.exports = router;
