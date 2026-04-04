const { v4: uuidv4 } = require('uuid');
const { db } = require('../config/firebase');

const createNotification = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { message, trigger_time } = req.body;

    const notificationId = uuidv4();
    const notificationData = {
      notification_id: notificationId,
      user_id: userId,
      message,
      trigger_time,
      delivered: false,
      created_at: new Date().toISOString(),
    };

    await db.collection('notifications').doc(notificationId).set(notificationData);

    res.status(201).json({
      message: 'Notification created successfully',
      notification: notificationData,
    });
  } catch (error) {
    console.error('Create notification error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const getNotifications = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const snapshot = await db.collection('notifications')
      .where('user_id', '==', userId)
      .orderBy('trigger_time', 'desc')
      .get();

    const notifications = [];
    snapshot.forEach(doc => notifications.push(doc.data()));

    res.json({ notifications });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const markDelivered = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const notificationId = req.params.id;

    const notifRef = db.collection('notifications').doc(notificationId);
    const notifDoc = await notifRef.get();

    if (!notifDoc.exists || notifDoc.data().user_id !== userId) {
      return res.status(404).json({ error: 'Notification not found.' });
    }

    await notifRef.update({ delivered: true });

    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    console.error('Mark notification error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const deleteNotification = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const notificationId = req.params.id;

    const notifRef = db.collection('notifications').doc(notificationId);
    const notifDoc = await notifRef.get();

    if (!notifDoc.exists || notifDoc.data().user_id !== userId) {
      return res.status(404).json({ error: 'Notification not found.' });
    }

    await notifRef.delete();

    res.json({ message: 'Notification deleted successfully' });
  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { createNotification, getNotifications, markDelivered, deleteNotification };
