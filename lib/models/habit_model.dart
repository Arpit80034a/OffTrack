class HabitModel {
  final String habitId;
  final String userId;
  final String name;
  final String frequency;
  final int streak;
  final String? lastCompletedDate;

  HabitModel({
    required this.habitId,
    this.userId = '',
    required this.name,
    this.frequency = 'daily',
    this.streak = 0,
    this.lastCompletedDate,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      habitId: json['habit_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      frequency: json['frequency'] ?? 'daily',
      streak: json['streak'] ?? 0,
      lastCompletedDate: json['last_completed_date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'frequency': frequency,
  };

  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastCompletedDate == today;
  }
}
