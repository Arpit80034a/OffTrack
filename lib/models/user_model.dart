class UserModel {
  // Unique identifier for the user
  final String userId;
  
  // Full name of the user
  final String name;
  
  // Email address of the user
  final String email;
  
  //  Timezone of the user
  final String timezone;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.timezone = 'UTC',
  });

  // Factory constructor to create UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      timezone: json['timezone'] ?? 'UTC',
    );
  }

  // Convert UserModel object to JSON format
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'email': email,
    'timezone': timezone,
  };
}
