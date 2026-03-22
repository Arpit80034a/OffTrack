class PreferenceModel {
  final String? preferenceId;
  final String userId;
  final String workStartTime;
  final String workEndTime;
  final int breakDuration;
  final String focusLevel;

  PreferenceModel({
    this.preferenceId,
    this.userId = '',
    this.workStartTime = '09:00',
    this.workEndTime = '17:00',
    this.breakDuration = 15,
    this.focusLevel = 'medium',
  });

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

  Map<String, dynamic> toJson() => {
    'work_start_time': workStartTime,
    'work_end_time': workEndTime,
    'break_duration': breakDuration,
    'focus_level': focusLevel,
  };
}
