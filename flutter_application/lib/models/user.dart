class User {
  final String id;
  final String name;
  final String email;
  final String category;
  final bool isOnline;
  final DateTime lastSeen;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.category,
    required this.isOnline,
    required this.lastSeen,
    this.profileImage,
  });

  /// Converte da JSON a User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      category: json['category'] as String,
      isOnline: json['isOnline'] as bool,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      profileImage: json['profileImage'] as String?,
    );
  }

  /// Converte User a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'category': category,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'profileImage': profileImage,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, category: $category, isOnline: $isOnline)';
  }
}
