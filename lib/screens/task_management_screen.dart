import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() =>
      _TaskManagementScreenState();
}

class _TaskManagementScreenState
    extends State<TaskManagementScreen> {
  // ==================== STATE ====================

  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  // ==================== LIFECYCLE ====================

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // ==================== DATA ====================

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

  // ==================== TASK DIALOG ====================

  void _showTaskDialog({TaskModel? task}) {
    final titleController =
        TextEditingController(text: task?.title ?? '');
    final descController =
        TextEditingController(text: task?.description ?? '');
    final durationController = TextEditingController(
        text: '${task?.estimatedDuration ?? 60}');

    String priority = task?.priority ?? 'medium';

    DateTime deadline = _resolveDeadline(task);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) =>
            _buildTaskModal(
          task,
          titleController,
          descController,
          durationController,
          priority,
          deadline,
          setModalState,
        ),
      ),
    );
  }

  DateTime _resolveDeadline(TaskModel? task) {
    if (task != null && task.deadline.isNotEmpty) {
      return DateTime.tryParse(task.deadline) ??
          DateTime.now().add(const Duration(days: 1));
    }
    return DateTime.now().add(const Duration(days: 1));
  }

  Widget _buildTaskModal(
    TaskModel? task,
    TextEditingController titleController,
    TextEditingController descController,
    TextEditingController durationController,
    String priority,
    DateTime deadline,
    StateSetter setModalState,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 20),
            _buildModalTitle(task),
            const SizedBox(height: 20),
            _buildTextField(titleController, 'Title', Icons.title),
            const SizedBox(height: 14),
            _buildTextField(
                descController, 'Description', Icons.description,
                maxLines: 3),
            const SizedBox(height: 14),
            _buildPrioritySelector(
                priority, (p) => setModalState(() => priority = p)),
            const SizedBox(height: 14),
            _buildDurationField(durationController),
            const SizedBox(height: 14),
            _buildDeadlinePicker(deadline,
                (d) => setModalState(() => deadline = d)),
            const SizedBox(height: 24),
            _buildSubmitButton(
              task,
              titleController,
              descController,
              durationController,
              priority,
              deadline,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MODAL COMPONENTS ====================

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color:
              AppTheme.textSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildModalTitle(TaskModel? task) {
    return Text(
      task != null ? 'Edit Task' : 'New Task',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildPrioritySelector(
      String priority, Function(String) onSelect) {
    return Row(
      children: ['low', 'medium', 'high'].map((p) {
        final color = AppTheme.getPriorityColor(p);
        final selected = priority == p;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(p),
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 4),
              padding:
                  const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.2)
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color:
                        selected ? color : Colors.transparent,
                    width: 1.5),
              ),
              child: Center(
                child: Text(
                  p.toUpperCase(),
                  style: TextStyle(
                    color: selected
                        ? color
                        : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationField(
      TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Duration (minutes)',
        prefixIcon:
            Icon(Icons.timer, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildDeadlinePicker(
      DateTime deadline, Function(DateTime) onPick) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: deadline,
          firstDate: DateTime.now(),
          lastDate:
              DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
              style: const TextStyle(
                  color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    TaskModel? task,
    TextEditingController title,
    TextEditingController desc,
    TextEditingController duration,
    String priority,
    DateTime deadline,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: () async {
            if (title.text.isEmpty) return;

            Navigator.pop(context);

            final taskData = {
              'title': title.text,
              'description': desc.text,
              'priority': priority,
              'deadline': deadline.toIso8601String(),
              'estimated_duration':
                  int.tryParse(duration.text) ?? 60,
            };

            if (task != null) {
              await ApiService.updateTask(
                  task.taskId, taskData);
            } else {
              await ApiService.createTask(taskData);
            }

            _loadTasks();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            task != null ? 'Update Task' : 'Create Task',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppTheme.splashGradient),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppTheme.primary));
    }

    if (_tasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return _buildTaskItem(_tasks[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt_rounded,
              size: 64,
              color: AppTheme.textSecondary
                  .withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No tasks yet',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Tap + to create your first task',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    final color =
        AppTheme.getPriorityColor(task.priority);

    return Dismissible(
      key: Key(task.taskId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteTask(task.taskId),
      background: _buildDeleteBackground(),
      child: GestureDetector(
        onTap: () => _showTaskDialog(task: task),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              _buildTaskIcon(color, task),
              const SizedBox(width: 14),
              Expanded(child: _buildTaskDetails(task)),
              _buildPriorityBadge(task, color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          const Icon(Icons.delete_rounded, color: AppTheme.error),
    );
  }

  Widget _buildTaskIcon(Color color, TaskModel task) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        AppTheme.getPriorityIcon(task.priority),
        color: color,
      ),
    );
  }

  Widget _buildTaskDetails(TaskModel task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(task.title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${task.estimatedDuration}min',
            style: TextStyle(
                color: AppTheme.textSecondary
                    .withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildPriorityBadge(TaskModel task, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        task.priority.toUpperCase(),
        style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
