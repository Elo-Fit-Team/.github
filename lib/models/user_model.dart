class UserModel {
  final int id;
  final String username;
  final String displayName;
  final String email;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'email': email,
  };
}
