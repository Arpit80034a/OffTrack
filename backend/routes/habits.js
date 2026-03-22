const express = require('express');
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { createHabit, getHabits, updateHabit, deleteHabit } = require('../controllers/habitController');

const router = express.Router();

router.get('/', auth, getHabits);

router.post(
  '/',
  auth,
  [body('name').trim().notEmpty().withMessage('Habit name is required')],
  validate,
  createHabit
);

router.put('/:id', auth, updateHabit);
router.delete('/:id', auth, deleteHabit);

module.exports = router;
