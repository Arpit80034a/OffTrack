const express = require('express');
const auth = require('../middleware/auth');
const { generateSchedule, getSchedule } = require('../controllers/scheduleController');

const router = express.Router();

router.post('/generate', auth, generateSchedule);
router.get('/', auth, getSchedule);

module.exports = router;
