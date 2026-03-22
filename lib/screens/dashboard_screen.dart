import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
import '../models/habit_model.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  List<TaskModel> _tasks = [];
  List<HabitModel> _habits = [];
  List<ScheduleItemModel> _scheduleItems = [];
  bool _isLoading = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getTasks(),
        ApiService.getHabits(),
        ApiService.getSchedule(),
      ]);

      final taskData = results[0];
      final habitData = results[1];
      final scheduleData = results[2];

      setState(() {
        _tasks = (taskData['tasks'] as List?)?.map((e) => TaskModel.fromJson(e)).toList() ?? [];
        _habits = (habitData['habits'] as List?)?.map((e) => HabitModel.fromJson(e)).toList() ?? [];
        _scheduleItems = (scheduleData['items'] as List?)?.map((e) => ScheduleItemModel.fromJson(e)).toList() ?? [];
      });
      _animController.forward();
    } catch (e) {
      // Silently handle - data may not be available yet
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, ${user?.name ?? 'User'} 👋',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          const SizedBox(height: 4),
                          const Text("Let's manage your day",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Quick Stats Cards
                  Row(
                    children: [
                      _buildStatCard('Tasks', '${_tasks.length}', Icons.task_alt_rounded, AppTheme.primary),
                      const SizedBox(width: 12),
                      _buildStatCard('Habits', '${_habits.length}', Icons.repeat_rounded, AppTheme.accent),
                      const SizedBox(width: 12),
                      _buildStatCard('Scheduled', '${_scheduleItems.length}', Icons.calendar_today_rounded, AppTheme.success),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      _buildActionButton('Add Task', Icons.add_task_rounded, AppTheme.primary, () {
                        Navigator.pushNamed(context, '/tasks');
                      }),
                      const SizedBox(width: 10),
                      _buildActionButton('Generate', Icons.auto_awesome_rounded, AppTheme.accent, () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generating AI schedule...')),
                        );
                        try {
                          await ApiService.generateSchedule();
                          _loadData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Schedule generated!'), backgroundColor: AppTheme.success),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to generate schedule'), backgroundColor: AppTheme.error),
                            );
                          }
                        }
                      }),
                      const SizedBox(width: 10),
                      _buildActionButton('Add Habit', Icons.psychology_rounded, AppTheme.success, () {
                        Navigator.pushNamed(context, '/habits');
                      }),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Today's Schedule
                  _buildSectionHeader('Today\'s Schedule', Icons.schedule_rounded, onSeeAll: () {
                    Navigator.pushNamed(context, '/schedule');
                  }),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  else if (_scheduleItems.isEmpty)
                    _buildEmptyCard('No schedule yet.\nTap "Generate" to create one!')
                  else
                    ..._scheduleItems.take(3).map((item) => _buildScheduleCard(item)),
                  const SizedBox(height: 24),

                  // Upcoming Tasks
                  _buildSectionHeader('Upcoming Tasks', Icons.task_alt_rounded, onSeeAll: () {
                    Navigator.pushNamed(context, '/tasks');
                  }),
                  const SizedBox(height: 12),
                  if (_tasks.isEmpty)
                    _buildEmptyCard('No tasks yet.\nAdd your first task!')
                  else
                    ..._tasks.take(3).map((task) => _buildTaskCard(task)),
                  const SizedBox(height: 24),

                  // Habit Summary
                  _buildSectionHeader('Habits', Icons.repeat_rounded, onSeeAll: () {
                    Navigator.pushNamed(context, '/habits');
                  }),
                  const SizedBox(height: 12),
                  if (_habits.isEmpty)
                    _buildEmptyCard('No habits yet.\nStart building good habits!')
                  else
                    ..._habits.take(3).map((habit) => _buildHabitCard(habit)),
                  const SizedBox(height: 20),

                  // Navigation Grid
                  _buildSectionHeader('Quick Access', Icons.grid_view_rounded),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildNavItem('Calendar', Icons.calendar_month_rounded, '/calendar'),
                      _buildNavItem('Alerts', Icons.notifications_rounded, '/notifications'),
                      _buildNavItem('Help', Icons.help_outline_rounded, '/help'),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ],
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See All', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildScheduleCard(ScheduleItemModel item) {
    final color = AppTheme.getPriorityColor(item.priority);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${item.startTime} - ${item.endTime}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(item.priority.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final color = AppTheme.getPriorityColor(task.priority);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration,
      child: Row(
        children: [
          Icon(AppTheme.getPriorityIcon(task.priority), color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                if (task.deadline.isNotEmpty)
                  Text('Due: ${task.deadline.split("T").first}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: task.status == 'completed' ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(task.status.toUpperCase(),
                style: TextStyle(
                  color: task.status == 'completed' ? AppTheme.success : AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(HabitModel habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: habit.isCompletedToday
                  ? AppTheme.success.withValues(alpha: 0.15)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              habit.isCompletedToday ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: habit.isCompletedToday ? AppTheme.success : AppTheme.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                Text('${habit.frequency} • 🔥 ${habit.streak} day streak',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: AppTheme.glassDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
