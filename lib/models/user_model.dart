class UserModel {
  final String userId;
  final String name;
  final String email;
  final String timezone;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.timezone = 'UTC',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      timezone: json['timezone'] ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'email': email,
    'timezone': timezone,
  };
}
