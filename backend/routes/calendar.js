const express = require('express');
const auth = require('../middleware/auth');
const { syncCalendar } = require('../controllers/calendarController');

const router = express.Router();

router.post('/sync', auth, syncCalendar);

module.exports = router;
