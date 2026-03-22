class TaskModel {
  final String taskId;
  final String userId;
  final String title;
  final String description;
  final String priority;
  final String deadline;
  final int estimatedDuration;
  final String status;
  final String createdAt;

  TaskModel({
    required this.taskId,
    this.userId = '',
    required this.title,
    this.description = '',
    this.priority = 'medium',
    required this.deadline,
    this.estimatedDuration = 60,
    this.status = 'pending',
    this.createdAt = '',
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['task_id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      deadline: json['deadline'] ?? '',
      estimatedDuration: json['estimated_duration'] ?? 60,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'priority': priority,
    'deadline': deadline,
    'estimated_duration': estimatedDuration,
    'status': status,
  };
}
