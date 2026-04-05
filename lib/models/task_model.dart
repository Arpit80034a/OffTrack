class TaskModel {
  // Unique identifier for the task
  final String taskId;
  
  // ID of the user who created the task
  final String userId;
  
  // Title of the task
  final String title;
  
  // Detailed description of the task
  final String description;
  
  // Priority level of the task
  final String priority;
  
  // Deadline of the task
  final String deadline;
  
  // Estimated duration to complete the task
  final int estimatedDuration;
  
  // Current status of the task
  final String status;
  
  // Timestamp when the task was created
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

  // Factory constructor to create TaskModel from JSON data
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

  // Convert TaskModel object to JSON format
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'priority': priority,
    'deadline': deadline,
    'estimated_duration': estimatedDuration,
    'status': status,
  };
}
