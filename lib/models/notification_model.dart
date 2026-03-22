class NotificationModel {
  final String notificationId;
  final String userId;
  final String message;
  final String triggerTime;
  final bool delivered;

  NotificationModel({
    required this.notificationId,
    this.userId = '',
    required this.message,
    required this.triggerTime,
    this.delivered = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] ?? '',
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      triggerTime: json['trigger_time'] ?? '',
      delivered: json['delivered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'trigger_time': triggerTime,
  };
}
