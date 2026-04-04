class NotificationModel {
  // Unique identifier for the notification
  final String notificationId;
  
  // ID of the user who receives this notification
  final String userId;
  
  // Notification message content
  final String message;
  
  // Time at which the notification should be triggered
  final String triggerTime;
  
  // Indicates whether the notification has been delivered 
  final bool delivered;

  NotificationModel({
    required this.notificationId,
    this.userId = '',
    required this.message,
    required this.triggerTime,
    this.delivered = false,
  });

  // Factory constructor to create NotificationModel from JSON data
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] ?? '',
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      triggerTime: json['trigger_time'] ?? '',
      delivered: json['delivered'] ?? false,
    );
  }

  // Convert NotificationModel object to JSON format (for API/database)
  Map<String, dynamic> toJson() => {
    'message': message,
    'trigger_time': triggerTime,
  };
}
