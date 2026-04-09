import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getTasks();
      setState(() {
        _tasks = (data['tasks'] as List?)
                ?.map((e) => TaskModel.fromJson(e))
                .toList() ??
            [];
      });
    } catch (e) {
      // silent
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    await ApiService.deleteTask(taskId);
    _loadTasks();
  }

  void _showTaskDialog({TaskModel? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    final durationController = TextEditingController(text: '${task?.estimatedDuration ?? 60}');
    String priority = task?.priority ?? 'medium';
    DateTime deadline = task != null && task.deadline.isNotEmpty
        ? DateTime.tryParse(task.deadline) ?? DateTime.now().add(const Duration(days: 1))
        : DateTime.now().add(const Duration(days: 1));

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
          child: SingleChildScrollView(
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
                Text(task != null ? 'Edit Task' : 'New Task',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title, color: AppTheme.textSecondary)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description, color: AppTheme.textSecondary)),
                ),
                const SizedBox(height: 14),

                // Priority selector
                const Text('Priority', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: ['low', 'medium', 'high'].map((p) {
                    final color = AppTheme.getPriorityColor(p);
                    final selected = priority == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => priority = p),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? color.withValues(alpha: 0.2) : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              p.toUpperCase(),
                              style: TextStyle(color: selected ? color : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    prefixIcon: Icon(Icons.timer, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 14),

                // Deadline picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setModalState(() => deadline = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8ECF4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
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
                        if (titleController.text.isEmpty) return;
                        Navigator.pop(context);
                        final taskData = {
                          'title': titleController.text,
                          'description': descController.text,
                          'priority': priority,
                          'deadline': deadline.toIso8601String(),
                          'estimated_duration': int.tryParse(durationController.text) ?? 60,
                        };
                        if (task != null) {
                          await ApiService.updateTask(task.taskId, taskData);
                        } else {
                          await ApiService.createTask(taskData);
                        }
                        _loadTasks();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(task != null ? 'Update Task' : 'Create Task',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text('No tasks yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Tap + to create your first task', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTasks,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        final color = AppTheme.getPriorityColor(task.priority);
                        return Dismissible(
                          key: Key(task.taskId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_rounded, color: AppTheme.error),
                          ),
                          onDismissed: (_) => _deleteTask(task.taskId),
                          child: GestureDetector(
                            onTap: () => _showTaskDialog(task: task),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE8ECF4)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(AppTheme.getPriorityIcon(task.priority), color: color, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(task.title, style: const TextStyle(
                                            color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.timer_outlined, size: 13, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                                            const SizedBox(width: 4),
                                            Text('${task.estimatedDuration}min',
                                                style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7), fontSize: 12)),
                                            const SizedBox(width: 12),
                                            if (task.deadline.isNotEmpty) ...[
                                              Icon(Icons.event_outlined, size: 13, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                                              const SizedBox(width: 4),
                                              Text(task.deadline.split('T').first,
                                                  style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7), fontSize: 12)),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(task.priority.toUpperCase(),
                                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
