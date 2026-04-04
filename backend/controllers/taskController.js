const { v4: uuidv4 } = require('uuid');
const { db } = require('../config/firebase');

const getTasks = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const tasksRef = db.collection('tasks');
    const snapshot = await tasksRef.where('user_id', '==', userId).orderBy('deadline', 'asc').get();

    const tasks = [];
    snapshot.forEach(doc => tasks.push(doc.data()));

    res.json({ tasks });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const createTask = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { title, description, priority, deadline, estimated_duration } = req.body;

    const taskId = uuidv4();
    const taskData = {
      task_id: taskId,
      user_id: userId,
      title,
      description: description || '',
      priority: priority || 'medium',
      deadline,
      estimated_duration: estimated_duration || 60,
      status: 'pending',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    await db.collection('tasks').doc(taskId).set(taskData);

    res.status(201).json({ message: 'Task created successfully', task: taskData });
  } catch (error) {
    console.error('Create task error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const updateTask = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const taskId = req.params.id;

    const taskRef = db.collection('tasks').doc(taskId);
    const taskDoc = await taskRef.get();

    if (!taskDoc.exists || taskDoc.data().user_id !== userId) {
      return res.status(404).json({ error: 'Task not found.' });
    }

    const updates = { ...req.body, updated_at: new Date().toISOString() };
    delete updates.task_id;
    delete updates.user_id;

    await taskRef.update(updates);

    res.json({ message: 'Task updated successfully', task: { ...taskDoc.data(), ...updates } });
  } catch (error) {
    console.error('Update task error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const deleteTask = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const taskId = req.params.id;

    const taskRef = db.collection('tasks').doc(taskId);
    const taskDoc = await taskRef.get();

    if (!taskDoc.exists || taskDoc.data().user_id !== userId) {
      return res.status(404).json({ error: 'Task not found.' });
    }

    await taskRef.delete();

    res.json({ message: 'Task deleted successfully' });
  } catch (error) {
    console.error('Delete task error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { getTasks, createTask, updateTask, deleteTask };
