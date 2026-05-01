class Admin {
  final String token;
  final String username;
  final String email;

  const Admin({
    required this.token,
    required this.username,
    required this.email,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      token: json['token'] ?? '',
      username: json['username'] ?? json['user']?['username'] ?? '',
      email: json['email'] ?? json['user']?['email'] ?? '',
    );
  }
}
