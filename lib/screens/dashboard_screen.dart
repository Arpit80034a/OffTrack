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

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // ==================== STATE ====================

  List<TaskModel> _tasks = [];
  List<HabitModel> _habits = [];
  List<ScheduleItemModel> _scheduleItems = [];

  bool _isLoading = true;

  late AnimationController _animController;

  // ==================== LIFECYCLE ====================

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _initAnimation() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  // ==================== DATA ====================

  Future<void> _loadData() async {
    _setLoading(true);

    try {
      final results = await _fetchDashboardData();
      _applyFetchedData(results);
      _animController.forward();
    } catch (e) {
      // silent
    } finally {
      _setLoading(false);
    }
  }

  Future<List<dynamic>> _fetchDashboardData() {
    return Future.wait([
      ApiService.getTasks(),
      ApiService.getHabits(),
      ApiService.getSchedule(),
    ]);
  }

  void _applyFetchedData(List<dynamic> results) {
    final taskData = results[0];
    final habitData = results[1];
    final scheduleData = results[2];

    setState(() {
      _tasks = _mapTasks(taskData);
      _habits = _mapHabits(habitData);
      _scheduleItems = _mapSchedule(scheduleData);
    });
  }

  List<TaskModel> _mapTasks(dynamic data) {
    return (data['tasks'] as List?)
            ?.map((e) => TaskModel.fromJson(e))
            .toList() ??
        [];
  }

  List<HabitModel> _mapHabits(dynamic data) {
    return (data['habits'] as List?)
            ?.map((e) => HabitModel.fromJson(e))
            .toList() ??
        [];
  }

  List<ScheduleItemModel> _mapSchedule(dynamic data) {
    return (data['items'] as List?)
            ?.map((e) => ScheduleItemModel.fromJson(e))
            .toList() ??
        [];
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  // ==================== ACTIONS ====================

  Future<void> _generateSchedule() async {
    _showSnack('Generating AI schedule...');

    try {
      await ApiService.generateSchedule();
      await _loadData();
      _showSnack('Schedule generated!', success: true);
    } catch (e) {
      _showSnack('Failed to generate schedule', isError: true);
    }
  }

  void _showSnack(String message, {bool success = false, bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? AppTheme.success : isError ? AppTheme.error : null,
      ),
    );
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;

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
                  _buildHeader(user),
                  const SizedBox(height: 28),
                  _buildStatsRow(),
                  const SizedBox(height: 28),
                  _buildActionsRow(),
                  const SizedBox(height: 28),
                  _buildScheduleSection(),
                  const SizedBox(height: 24),
                  _buildTasksSection(),
                  const SizedBox(height: 24),
                  _buildHabitsSection(),
                  const SizedBox(height: 20),
                  _buildNavigationGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== UI SECTIONS ====================

  Widget _buildHeader(user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.name ?? 'User'} 👋',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              "Let's manage your day",
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child: _buildAvatar(user),
        ),
      ],
    );
  }

  Widget _buildAvatar(user) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          (user?.name ?? 'U').substring(0, 1).toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Tasks', '${_tasks.length}',
            Icons.task_alt_rounded, AppTheme.primary),
        const SizedBox(width: 12),
        _buildStatCard('Habits', '${_habits.length}',
            Icons.repeat_rounded, AppTheme.accent),
        const SizedBox(width: 12),
        _buildStatCard('Scheduled', '${_scheduleItems.length}',
            Icons.calendar_today_rounded, AppTheme.success),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        _buildActionButton('Add Task', Icons.add_task_rounded,
            AppTheme.primary, () {
          Navigator.pushNamed(context, '/tasks');
        }),
        const SizedBox(width: 10),
        _buildActionButton('Generate', Icons.auto_awesome_rounded,
            AppTheme.accent, _generateSchedule),
        const SizedBox(width: 10),
        _buildActionButton('Add Habit',
            Icons.psychology_rounded, AppTheme.success, () {
          Navigator.pushNamed(context, '/habits');
        }),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Today\'s Schedule',
            Icons.schedule_rounded, onSeeAll: () {
          Navigator.pushNamed(context, '/schedule');
        }),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
              child:
                  CircularProgressIndicator(color: AppTheme.primary))
        else if (_scheduleItems.isEmpty)
          _buildEmptyCard(
              'No schedule yet.\nTap "Generate" to create one!')
        else
          ..._scheduleItems
              .take(3)
              .map((item) => _buildScheduleCard(item)),
      ],
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Upcoming Tasks',
            Icons.task_alt_rounded, onSeeAll: () {
          Navigator.pushNamed(context, '/tasks');
        }),
        const SizedBox(height: 12),
        if (_tasks.isEmpty)
          _buildEmptyCard(
              'No tasks yet.\nAdd your first task!')
        else
          ..._tasks.take(3).map((t) => _buildTaskCard(t)),
      ],
    );
  }

  Widget _buildHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Habits', Icons.repeat_rounded,
            onSeeAll: () {
          Navigator.pushNamed(context, '/habits');
        }),
        const SizedBox(height: 12),
        if (_habits.isEmpty)
          _buildEmptyCard(
              'No habits yet.\nStart building good habits!')
        else
          ..._habits.take(3).map((h) => _buildHabitCard(h)),
      ],
    );
  }

  Widget _buildNavigationGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Access',
            Icons.grid_view_rounded),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildNavItem(
                'Calendar', Icons.calendar_month_rounded, '/calendar'),
            _buildNavItem('Alerts',
                Icons.notifications_rounded, '/notifications'),
            _buildNavItem(
                'Help', Icons.help_outline_rounded, '/help'),
          ],
        ),
      ],
    );
  }

  // ==================== REUSABLE UI ====================

  Widget _buildStatCard(String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon,
      Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon,
      {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon,
                color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
          ],
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See All',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  // existing cards unchanged ↓

  Widget _buildScheduleCard(ScheduleItemModel item) { /* SAME AS YOURS */ return Container(); }
  Widget _buildTaskCard(TaskModel task) { /* SAME AS YOURS */ return Container(); }
  Widget _buildHabitCard(HabitModel habit) { /* SAME AS YOURS */ return Container(); }
  Widget _buildEmptyCard(String message) { /* SAME AS YOURS */ return Container(); }
  Widget _buildNavItem(String label, IconData icon, String route) { /* SAME AS YOURS */ return Container(); }
}
