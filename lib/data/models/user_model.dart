class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'receptionist'
  final String? token;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });
  
  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'receptionist',
      token: json['token'],
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
    };
  }
  
  // Check if user is admin
  bool get isAdmin => role == 'admin';
  
  // Copy with
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
