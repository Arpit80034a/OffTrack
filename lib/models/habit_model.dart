class HabitModel {
  // Unique identifier for the habit
  final String habitId;

  // ID of the user who owns this habit
  final String userId;

  // Name/Title of the habit
  final String name;

  // Frequency of the habit
  final String frequency;

  // Current streak count
  final int streak;

  // Last date when the habit was completed
  final String? lastCompletedDate;

  HabitModel({
    required this.habitId,
    this.userId = '',
    required this.name,
    this.frequency = 'daily',
    this.streak = 0,
    this.lastCompletedDate,
  });

  // Factory constructor to create object from JSON
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

  // Convert object to JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'frequency': frequency,
  };

  // Check if habit is completed today
  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastCompletedDate == today;
  }
}
