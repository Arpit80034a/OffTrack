const { v4: uuidv4 } = require('uuid');
const { db } = require('../config/firebase');

const getPreferences = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const snapshot = await db.collection('preferences')
      .where('user_id', '==', userId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      // Return defaults
      return res.json({
        preferences: {
          user_id: userId,
          work_start_time: '09:00',
          work_end_time: '17:00',
          break_duration: 15,
          focus_level: 'medium',
        },
      });
    }

    res.json({ preferences: snapshot.docs[0].data() });
  } catch (error) {
    console.error('Get preferences error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const updatePreferences = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { work_start_time, work_end_time, break_duration, focus_level } = req.body;

    const snapshot = await db.collection('preferences')
      .where('user_id', '==', userId)
      .limit(1)
      .get();

    const prefData = {
      user_id: userId,
      work_start_time: work_start_time || '09:00',
      work_end_time: work_end_time || '17:00',
      break_duration: break_duration || 15,
      focus_level: focus_level || 'medium',
      updated_at: new Date().toISOString(),
    };

    if (snapshot.empty) {
      const prefId = uuidv4();
      prefData.preference_id = prefId;
      await db.collection('preferences').doc(prefId).set(prefData);
    } else {
      const docId = snapshot.docs[0].id;
      await db.collection('preferences').doc(docId).update(prefData);
      prefData.preference_id = snapshot.docs[0].data().preference_id;
    }

    res.json({ message: 'Preferences updated successfully', preferences: prefData });
  } catch (error) {
    console.error('Update preferences error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { getPreferences, updatePreferences };
