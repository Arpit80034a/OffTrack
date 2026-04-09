const { v4: uuidv4 } = require('uuid');
const { db } = require('../config/firebase');
const axios = require('axios');

const generateSchedule = async (req, res) => {
  try {
    const userId = req.user.user_id;

    // Fetch user tasks
    const tasksSnapshot = await db.collection('tasks')
      .where('user_id', '==', userId)
      .where('status', '==', 'pending')
      .get();

    const tasks = [];
    tasksSnapshot.forEach(doc => tasks.push(doc.data()));

    // Fetch user preferences
    const prefsSnapshot = await db.collection('preferences')
      .where('user_id', '==', userId)
      .get();

    let preferences = {
      work_start_time: '09:00',
      work_end_time: '17:00',
      break_duration: 15,
      focus_level: 'medium',
    };
    if (!prefsSnapshot.empty) {
      preferences = prefsSnapshot.docs[0].data();
    }

    // Call AI engine
    let scheduledItems = [];
    try {
      const aiResponse = await axios.post(
        `${process.env.AI_ENGINE_URL || 'http://localhost:5001'}/generate-schedule`,
        { tasks, preferences },
        { timeout: 5000 }
      );
      scheduledItems = aiResponse.data.schedule || [];
    } catch (aiError) {
      console.log('AI engine unavailable, using basic scheduling');
      // Fallback: simple priority-based scheduling
      const sorted = tasks.sort((a, b) => {
        const priorityMap = { high: 3, medium: 2, low: 1 };
        return (priorityMap[b.priority] || 2) - (priorityMap[a.priority] || 2);
      });

      let currentTime = preferences.work_start_time || '09:00';
      const [startH, startM] = currentTime.split(':').map(Number);
      let minutes = startH * 60 + startM;

      sorted.forEach(task => {
        const duration = task.estimated_duration || 60;
        const startTime = `${String(Math.floor(minutes / 60)).padStart(2, '0')}:${String(minutes % 60).padStart(2, '0')}`;
        minutes += duration;
        const endTime = `${String(Math.floor(minutes / 60)).padStart(2, '0')}:${String(minutes % 60).padStart(2, '0')}`;
        minutes += preferences.break_duration || 15;

        scheduledItems.push({
          task_id: task.task_id,
          title: task.title,
          start_time: startTime,
          end_time: endTime,
          priority: task.priority,
        });
      });
    }

    // Save schedule to Firestore
    const scheduleId = uuidv4();
    const scheduleDate = new Date().toISOString().split('T')[0];

    await db.collection('schedules').doc(scheduleId).set({
      schedule_id: scheduleId,
      user_id: userId,
      schedule_date: scheduleDate,
      created_at: new Date().toISOString(),
    });

    // Save schedule items
    const batch = db.batch();
    scheduledItems.forEach(item => {
      const itemId = uuidv4();
      const itemRef = db.collection('schedule_items').doc(itemId);
      batch.set(itemRef, {
        item_id: itemId,
        schedule_id: scheduleId,
        task_id: item.task_id,
        title: item.title,
        start_time: item.start_time,
        end_time: item.end_time,
        priority: item.priority || 'medium',
      });
    });
    await batch.commit();

    res.json({
      message: 'Schedule generated successfully',
      schedule: {
        schedule_id: scheduleId,
        schedule_date: scheduleDate,
        items: scheduledItems,
      },
    });
  } catch (error) {
    console.error('Generate schedule error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const getSchedule = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const date = req.query.date || new Date().toISOString().split('T')[0];

    const schedulesSnapshot = await db.collection('schedules')
      .where('user_id', '==', userId)
      .where('schedule_date', '==', date)
      .orderBy('created_at', 'desc')
      .limit(1)
      .get();

    if (schedulesSnapshot.empty) {
      return res.json({ schedule: null, items: [] });
    }

    const schedule = schedulesSnapshot.docs[0].data();

    const itemsSnapshot = await db.collection('schedule_items')
      .where('schedule_id', '==', schedule.schedule_id)
      .get();

    const items = [];
    itemsSnapshot.forEach(doc => items.push(doc.data()));
    items.sort((a, b) => a.start_time.localeCompare(b.start_time));

    res.json({ schedule, items });
  } catch (error) {
    console.error('Get schedule error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { generateSchedule, getSchedule };
