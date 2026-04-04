const express = require('express');
const auth = require('../middleware/auth');
const { getPreferences, updatePreferences } = require('../controllers/preferencesController');

const router = express.Router();

router.get('/', auth, getPreferences);
router.put('/', auth, updatePreferences);

module.exports = router;
