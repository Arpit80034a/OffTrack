import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CalendarSyncScreen extends StatefulWidget {
  const CalendarSyncScreen({super.key});

  @override
  State<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends State<CalendarSyncScreen> {
  bool _syncEnabled = false;
  bool _isSyncing = false;
  int _syncedItems = 0;
  String _lastSynced = 'Never';

  Future<void> _toggleSync() async {
    if (_syncEnabled) {
      setState(() {
        _syncEnabled = false;
        _syncedItems = 0;
        _lastSynced = 'Never';
      });
      return;
    }

    setState(() => _isSyncing = true);
    try {
      final result = await ApiService.syncCalendar({
        'calendar_id': 'primary',
      });
      setState(() {
        _syncEnabled = true;
        _syncedItems = result['synced_items'] ?? 0;
        _lastSynced = 'Just now';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calendar synced!'), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync failed. Please try again.'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Sync')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Sync Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.1),
                      AppTheme.accent.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 15),
                        ],
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text('Google Calendar',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    const Text(
                      'Sync your AI-generated schedule\nwith Google Calendar',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _syncEnabled ? 'Enabled' : 'Disabled',
                          style: TextStyle(
                            color: _syncEnabled ? AppTheme.success : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: _syncEnabled,
                          onChanged: _isSyncing ? null : (_) => _toggleSync(),
                          activeThumbColor: AppTheme.success,
                          activeTrackColor: AppTheme.success.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Status info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassDecoration,
                child: Column(
                  children: [
                    _buildInfoRow(Icons.sync_rounded, 'Status',
                        _isSyncing ? 'Syncing...' : _syncEnabled ? 'Connected' : 'Not connected'),
                    const Divider(color: AppTheme.surfaceLight, height: 24),
                    _buildInfoRow(Icons.event_available_rounded, 'Synced Items', '$_syncedItems items'),
                    const Divider(color: AppTheme.surfaceLight, height: 24),
                    _buildInfoRow(Icons.access_time_rounded, 'Last Synced', _lastSynced),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Info note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outlined, color: AppTheme.accent.withValues(alpha: 0.7), size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Google Calendar API credentials are required for full sync. Configure in Settings.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
