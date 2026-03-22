class ScheduleItemModel {
  final String itemId;
  final String taskId;
  final String title;
  final String startTime;
  final String endTime;
  final String priority;

  ScheduleItemModel({
    this.itemId = '',
    this.taskId = '',
    required this.title,
    required this.startTime,
    required this.endTime,
    this.priority = 'medium',
  });

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
  final String scheduleId;
  final String scheduleDate;
  final List<ScheduleItemModel> items;

  ScheduleModel({
    required this.scheduleId,
    required this.scheduleDate,
    required this.items,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json, List<dynamic> itemsList) {
    return ScheduleModel(
      scheduleId: json['schedule_id'] ?? '',
      scheduleDate: json['schedule_date'] ?? '',
      items: itemsList.map((e) => ScheduleItemModel.fromJson(e)).toList(),
    );
  }
}
