// models/user_model.dart
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? profileImage; // Nullable for optional profile image

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImage,
  });

  // Factory constructor to create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      profileImage: json['profileImage'] as String?, // Cast to nullable String
    );
  }

  // Method to convert UserModel instance back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'profileImage': profileImage,
    };
  }
}
