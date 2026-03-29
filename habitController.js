const { v4: uuidv4 } = require('uuid');
const { db } = require('../config/firebase');

const createHabit = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { name, frequency } = req.body;

    const habitId = uuidv4();
    const habitData = {
      habit_id: habitId,
      user_id: userId,
      name,
      frequency: frequency || 'daily',
      streak: 0,
      last_completed_date: null,
      created_at: new Date().toISOString(),
    };

    await db.collection('habits').doc(habitId).set(habitData);

    res.status(201).json({ message: 'Habit created successfully', habit: habitData });
  } catch (error) {
    console.error('Create habit error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const getHabits = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const snapshot = await db.collection('habits')
      .where('user_id', '==', userId)
      .get();

    const habits = [];
    snapshot.forEach(doc => habits.push(doc.data()));

    res.json({ habits });
  } catch (error) {
    console.error('Get habits error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const updateHabit = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const habitId = req.params.id;

    const habitRef = db.collection('habits').doc(habitId);
    const habitDoc = await habitRef.get();

    if (!habitDoc.exists || habitDoc.data().user_id !== userId) {
      return res.status(404).json({ error: 'Habit not found.' });
    }

    const currentData = habitDoc.data();
    const today = new Date().toISOString().split('T')[0];

    let updates = { ...req.body };
    delete updates.habit_id;
    delete updates.user_id;

    // Handle completion marking
    if (req.body.mark_complete) {
      const lastCompleted = currentData.last_completed_date;
      const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

      updates.last_completed_date = today;
      if (lastCompleted === yesterday) {
        updates.streak = (currentData.streak || 0) + 1;
      } else if (lastCompleted !== today) {
        updates.streak = 1;
      }
      delete updates.mark_complete;
    }

    await habitRef.update(updates);

    res.json({ message: 'Habit updated successfully', habit: { ...currentData, ...updates } });
  } catch (error) {
    console.error('Update habit error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const deleteHabit = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const habitId = req.params.id;

    const habitRef = db.collection('habits').doc(habitId);
    const habitDoc = await habitRef.get();

    if (!habitDoc.exists || habitDoc.data().user_id !== userId) {
      return res.status(404).json({ error: 'Habit not found.' });
    }

    await habitRef.delete();

    res.json({ message: 'Habit deleted successfully' });
  } catch (error) {
    console.error('Delete habit error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { createHabit, getHabits, updateHabit, deleteHabit };
