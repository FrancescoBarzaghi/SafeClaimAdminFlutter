class UserCategory {
  final String id;
  final String name;
  final String description;
  final int userCount;
  final String? icon;

  UserCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.userCount,
    this.icon,
  });

  /// Converte da JSON a UserCategory
  factory UserCategory.fromJson(Map<String, dynamic> json) {
    return UserCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      userCount: json['userCount'] as int,
      icon: json['icon'] as String?,
    );
  }

  /// Converte UserCategory a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userCount': userCount,
      'icon': icon,
    };
  }

  @override
  String toString() {
    return 'UserCategory(id: $id, name: $name, userCount: $userCount)';
  }
}
