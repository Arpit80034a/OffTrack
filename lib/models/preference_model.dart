class PreferenceModel {
  
  // Unique identifier for the preference (optional)
  final String? preferenceId;
  
  // ID of the user to whom these preferences belong
  final String userId;
  
  // User's preferred work start time
  final String workStartTime;
  
  // User's preferred work end time
  final String workEndTime;
  
  // Break duration in minutes between tasks
  final int breakDuration;
  
  // Focus level preference (e.g. low, medium, high)
  final String focusLevel;

  PreferenceModel({
    this.preferenceId,
    this.userId = '',
    this.workStartTime = '09:00',
    this.workEndTime = '17:00',
    this.breakDuration = 15,
    this.focusLevel = 'medium',
  });

  // Factory constructor to create PreferenceModel from JSON data
  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    return PreferenceModel(
      preferenceId: json['preference_id'],
      userId: json['user_id'] ?? '',
      workStartTime: json['work_start_time'] ?? '09:00',
      workEndTime: json['work_end_time'] ?? '17:00',
      breakDuration: json['break_duration'] ?? 15,
      focusLevel: json['focus_level'] ?? 'medium',
    );
  }

  // Convert PreferenceModel object to JSON 
  Map<String, dynamic> toJson() => {
    'work_start_time': workStartTime,
    'work_end_time': workEndTime,
    'break_duration': breakDuration,
    'focus_level': focusLevel,
  };
}
