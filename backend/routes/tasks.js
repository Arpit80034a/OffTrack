const express = require('express');
const { body } = require('express-validator');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const { getTasks, createTask, updateTask, deleteTask } = require('../controllers/taskController');

const router = express.Router();

router.get('/', auth, getTasks);

router.post(
  '/',
  auth,
  [
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('deadline').notEmpty().withMessage('Deadline is required'),
  ],
  validate,
  createTask
);

router.put('/:id', auth, updateTask);
router.delete('/:id', auth, deleteTask);

module.exports = router;
