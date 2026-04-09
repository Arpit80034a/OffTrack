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
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _taskReminders = true;
  bool _scheduleAlerts = true;
  bool _habitReminders = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getNotifications();
      setState(() {
        _notifications = (data['notifications'] as List?)
            ?.map((e) => NotificationModel.fromJson(e))
            .toList() ?? [];
      });
    } catch (e) {
      // Handle
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
              // Settings
              const Text('Notification Settings',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                decoration: AppTheme.glassDecoration,
                child: Column(
                  children: [
                    _buildToggle('Task Reminders', 'Get notified before task deadlines',
                        Icons.task_alt_rounded, _taskReminders, (v) => setState(() => _taskReminders = v)),
                    Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), height: 1),
                    _buildToggle('Schedule Alerts', 'Daily schedule notifications',
                        Icons.schedule_rounded, _scheduleAlerts, (v) => setState(() => _scheduleAlerts = v)),
                    Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), height: 1),
                    _buildToggle('Habit Reminders', 'Remind to complete daily habits',
                        Icons.psychology_rounded, _habitReminders, (v) => setState(() => _habitReminders = v)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // History
              const Text('Recent Notifications',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ))
              else if (_notifications.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: AppTheme.glassDecoration,
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      const Text('No notifications yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    ],
                  ),
                )
              else
                ..._notifications.map((n) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: n.delivered
                              ? const Color(0xFFE8ECF4)
                              : AppTheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: n.delivered
                                  ? AppTheme.surfaceLight
                                  : AppTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              n.delivered ? Icons.notifications_outlined : Icons.notifications_active_rounded,
                              color: n.delivered ? AppTheme.textSecondary : AppTheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.message,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(n.triggerTime,
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                              ],
                            ),
                          ),
                          if (!n.delivered)
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
