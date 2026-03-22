import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';

class HabitTrackingScreen extends StatefulWidget {
  const HabitTrackingScreen({super.key});

  @override
  State<HabitTrackingScreen> createState() => _HabitTrackingScreenState();
}

class _HabitTrackingScreenState extends State<HabitTrackingScreen> {
  List<HabitModel> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getHabits();
      setState(() {
        _habits = (data['habits'] as List?)?.map((e) => HabitModel.fromJson(e)).toList() ?? [];
      });
    } catch (e) {
      // Handle
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markComplete(HabitModel habit) async {
    try {
      await ApiService.updateHabit(habit.habitId, {'mark_complete': true});
      _loadHabits();
    } catch (e) {
      // Handle
    }
  }

  void _showAddHabitDialog() {
    final nameController = TextEditingController();
    String frequency = 'daily';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('New Habit',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  prefixIcon: Icon(Icons.psychology_rounded, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Frequency', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: ['daily', 'weekly', 'monthly'].map((f) {
                  final selected = frequency == f;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => frequency = f),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            f.toUpperCase(),
                            style: TextStyle(
                              color: selected ? AppTheme.primary : AppTheme.textSecondary,
                              fontSize: 12, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty) return;
                      Navigator.pop(context);
                      await ApiService.createHabit({
                        'name': nameController.text,
                        'frequency': frequency,
                      });
                      _loadHabits();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Create Habit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedToday = _habits.where((h) => h.isCompletedToday).length;
    final total = _habits.length;
    final bestStreak = _habits.fold<int>(0, (max, h) => h.streak > max ? h.streak : max);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : Column(
                children: [
                  // Stats
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildStatCard('Completed', '$completedToday/$total', AppTheme.success),
                        const SizedBox(width: 12),
                        _buildStatCard('Best Streak', '🔥 $bestStreak', AppTheme.warning),
                        const SizedBox(width: 12),
                        _buildStatCard('Total', '$total', AppTheme.primary),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _habits.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.psychology_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                const SizedBox(height: 16),
                                const Text('No habits yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                                const SizedBox(height: 8),
                                const Text('Tap + to add a habit', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadHabits,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _habits.length,
                              itemBuilder: (context, index) {
                                final habit = _habits[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: habit.isCompletedToday
                                          ? AppTheme.success.withValues(alpha: 0.3)
                                          : Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => habit.isCompletedToday ? null : _markComplete(habit),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: habit.isCompletedToday
                                                ? AppTheme.success.withValues(alpha: 0.15)
                                                : AppTheme.surfaceLight,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: habit.isCompletedToday ? AppTheme.success : Colors.white.withValues(alpha: 0.1),
                                            ),
                                          ),
                                          child: Icon(
                                            habit.isCompletedToday ? Icons.check_circle_rounded : Icons.circle_outlined,
                                            color: habit.isCompletedToday ? AppTheme.success : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(habit.name,
                                                style: TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
                                                )),
                                            const SizedBox(height: 4),
                                            Text('${habit.frequency} • 🔥 ${habit.streak} day streak',
                                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
