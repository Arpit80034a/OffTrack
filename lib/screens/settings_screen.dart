import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _workStart = '09:00';
  String _workEnd = '17:00';
  String _focusLevel = 'medium';
  int _breakDuration = 15;
  bool _prefsSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await ApiService.getPreferences();
      final prefs = response['preferences'];
      if (prefs != null && mounted) {
        setState(() {
          _workStart = prefs['work_start_time'] ?? '09:00';
          _workEnd = prefs['work_end_time'] ?? '17:00';
          _breakDuration = prefs['break_duration'] ?? 15;
          _focusLevel = prefs['focus_level'] ?? 'medium';
        });
      }
    } catch (_) {
      // Use defaults
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _prefsSaving = true);
    try {
      await ApiService.updatePreferences({
        'work_start_time': _workStart,
        'work_end_time': _workEnd,
        'break_duration': _breakDuration,
        'focus_level': _focusLevel,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved!'), backgroundColor: AppTheme.success),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save preferences'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _prefsSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withValues(alpha: 0.1), AppTheme.accent.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          (auth.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.user?.name ?? 'User',
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(auth.user?.email ?? '',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Work Preferences
              const Text('Work Preferences',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassDecoration,
                child: Column(
                  children: [
                    _buildTimePicker('Work Start', _workStart, (val) => setState(() => _workStart = val)),
                    Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), height: 24),
                    _buildTimePicker('Work End', _workEnd, (val) => setState(() => _workEnd = val)),
                    Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), height: 24),
                    _buildSliderRow('Break Duration', '$_breakDuration min',
                        _breakDuration.toDouble(), 5, 60, (v) => setState(() => _breakDuration = v.round())),
                    Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), height: 24),
                    _buildFocusLevel(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _prefsSaving ? null : _savePreferences,
                  icon: _prefsSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: Text(_prefsSaving ? 'Saving...' : 'Save Preferences'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // General
              const Text('General',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                decoration: AppTheme.glassDecoration,
                child: Column(
                  children: [
                    _buildMenuItem(Icons.info_outline_rounded, 'About', () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Intelligent Schedule Manager',
                        applicationVersion: '1.0.0',
                        children: [
                          const Text('AI-powered task scheduling and habit tracking app.'),
                        ],
                      );
                    }),
                    Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), height: 1),
                    _buildMenuItem(Icons.description_outlined, 'Terms & Conditions', () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          title: const Text('Terms & Conditions', style: TextStyle(color: AppTheme.textPrimary)),
                          content: const Text(
                            'By using this app, you agree to our terms of service. Your data is stored securely and never shared with third parties without consent.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                        ),
                      );
                    }),
                    Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), height: 1),
                    _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy Policy page coming soon')),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.surface,
                        title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary)),
                        content: const Text('Are you sure you want to logout?',
                            style: TextStyle(color: AppTheme.textSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Logout', style: TextStyle(color: AppTheme.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await auth.logout();
                      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  label: const Text('Logout', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text('Version 1.0.0',
                    style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 12)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, String value, ValueChanged<String> onChanged) {
    return InkWell(
      onTap: () async {
        final parts = value.split(':');
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
        );
        if (picked != null) {
          onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(value, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, String value, double current, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.coffee_rounded, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            const Spacer(),
            Text(value, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.primary,
            inactiveTrackColor: AppTheme.surfaceLight,
            thumbColor: AppTheme.primary,
            overlayColor: AppTheme.primary.withValues(alpha: 0.1),
          ),
          child: Slider(value: current, min: min, max: max, divisions: ((max - min) / 5).round(), onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildFocusLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 14),
            const Text('Focus Level', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: ['low', 'medium', 'high'].map((level) {
            final selected = _focusLevel == level;
            final color = level == 'high' ? AppTheme.success : level == 'medium' ? AppTheme.warning : AppTheme.textSecondary;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _focusLevel = level),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: 0.15) : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
                  ),
                  child: Center(
                    child: Text(level.toUpperCase(),
                        style: TextStyle(color: selected ? color : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 22),
            const SizedBox(width: 14),
            Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
