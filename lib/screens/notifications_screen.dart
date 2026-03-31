import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ==================== STATE ====================

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  bool _taskReminders = true;
  bool _scheduleAlerts = true;
  bool _habitReminders = true;

  // ==================== LIFECYCLE ====================

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _loadNotifications();
  }

  // ==================== DATA ====================

  Future<void> _loadNotifications() async {
    _setLoading(true);

    try {
      final data = await ApiService.getNotifications();
      _applyNotifications(data);
    } catch (e) {
      // silent
    } finally {
      _setLoading(false);
    }
  }

  void _applyNotifications(Map<String, dynamic> data) {
    setState(() {
      _notifications = _mapNotifications(data);
    });
  }

  List<NotificationModel> _mapNotifications(Map<String, dynamic> data) {
    return (data['notifications'] as List?)
            ?.map((e) => NotificationModel.fromJson(e))
            .toList() ??
        [];
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  // ==================== TOGGLE HANDLERS ====================

  void _updateTaskReminders(bool value) {
    setState(() => _taskReminders = value);
  }

  void _updateScheduleAlerts(bool value) {
    setState(() => _scheduleAlerts = value);
  }

  void _updateHabitReminders(bool value) {
    setState(() => _habitReminders = value);
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsSection(),
              const SizedBox(height: 24),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SECTIONS ====================

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Settings',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppTheme.glassDecoration,
          child: Column(
            children: [
              _buildToggle(
                'Task Reminders',
                'Get notified before task deadlines',
                Icons.task_alt_rounded,
                _taskReminders,
                _updateTaskReminders,
              ),
              _buildDivider(),
              _buildToggle(
                'Schedule Alerts',
                'Daily schedule notifications',
                Icons.schedule_rounded,
                _scheduleAlerts,
                _updateScheduleAlerts,
              ),
              _buildDivider(),
              _buildToggle(
                'Habit Reminders',
                'Remind to complete daily habits',
                Icons.psychology_rounded,
                _habitReminders,
                _updateHabitReminders,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Notifications',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildHistoryContent(),
      ],
    );
  }

  Widget _buildHistoryContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _notifications.map((n) => _buildNotificationCard(n)).toList(),
    );
  }

  // ==================== UI COMPONENTS ====================

  Widget _buildNotificationCard(NotificationModel n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: n.delivered
              ? Colors.white.withValues(alpha: 0.05)
              : AppTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _buildNotificationIcon(n),
          const SizedBox(width: 14),
          Expanded(child: _buildNotificationText(n)),
          if (!n.delivered) _buildUnreadDot(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel n) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: n.delivered
            ? AppTheme.surfaceLight
            : AppTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        n.delivered
            ? Icons.notifications_outlined
            : Icons.notifications_active_rounded,
        color: n.delivered
            ? AppTheme.textSecondary
            : AppTheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildNotificationText(NotificationModel n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          n.message,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          n.triggerTime,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: AppTheme.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'No notifications yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.05),
      height: 1,
    );
  }

  // ==================== REUSABLE ====================

  Widget _buildToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            activeTrackColor:
                AppTheme.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
