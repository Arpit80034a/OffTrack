class ScheduleItemModel {
  // Unique identifier for the schedule item  
  final String itemId;
  
  // ID of the task associated with this schedule item
  final String taskId;
  
  // Title of the task
  final String title;
  
  // Start time of the scheduled task
  final String startTime;
  
  // End time of the scheduled task
  final String endTime;
  
  // Priority level of the task (low, medium, high)
  final String priority;

  ScheduleItemModel({
    this.itemId = '',
    this.taskId = '',
    required this.title,
    required this.startTime,
    required this.endTime,
    this.priority = 'medium',
  });

  // Factory constructor to create ScheduleItemModel from JSON data
  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return ScheduleItemModel(
      itemId: json['item_id'] ?? '',
      taskId: json['task_id'] ?? '',
      title: json['title'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      priority: json['priority'] ?? 'medium',
    );
  }
}

class ScheduleModel {
  // Unique identifier for the schedule
  final String scheduleId;
  
  // Date of the schedule 
  final String scheduleDate;
  
  // List of scheduled items
  final List<ScheduleItemModel> items;

  ScheduleModel({
    required this.scheduleId,
    required this.scheduleDate,
    required this.items,
  });

  // Factory constructor to create ScheduleModel from JSON and list of items
  factory ScheduleModel.fromJson(Map<String, dynamic> json, List<dynamic> itemsList) {
    return ScheduleModel(
      scheduleId: json['schedule_id'] ?? '',
      scheduleDate: json['schedule_date'] ?? '',
      items: itemsList.map((e) => ScheduleItemModel.fromJson(e)).toList(),
    );
  }
}
