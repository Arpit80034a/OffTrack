const { db } = require('../config/firebase');

const syncCalendar = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { access_token, calendar_id } = req.body;

    // In production, this would use the Google Calendar API
    // to sync schedule items to the user's Google Calendar.
    // For now, we store the sync configuration.

    const syncData = {
      user_id: userId,
      calendar_id: calendar_id || 'primary',
      sync_enabled: true,
      last_synced: new Date().toISOString(),
    };

    await db.collection('calendar_sync').doc(userId).set(syncData, { merge: true });

    // Fetch current schedule items for sync
    const today = new Date().toISOString().split('T')[0];
    const schedulesSnapshot = await db.collection('schedules')
      .where('user_id', '==', userId)
      .where('schedule_date', '==', today)
      .orderBy('created_at', 'desc')
      .limit(1)
      .get();

    let syncedItems = 0;
    if (!schedulesSnapshot.empty) {
      const schedule = schedulesSnapshot.docs[0].data();
      const itemsSnapshot = await db.collection('schedule_items')
        .where('schedule_id', '==', schedule.schedule_id)
        .get();
      syncedItems = itemsSnapshot.size;

      // TODO: In production, create Google Calendar events here
      // using the googleapis package with the provided access_token
    }

    res.json({
      message: 'Calendar sync configured successfully',
      synced_items: syncedItems,
      sync_data: syncData,
    });
  } catch (error) {
    console.error('Calendar sync error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { syncCalendar };
