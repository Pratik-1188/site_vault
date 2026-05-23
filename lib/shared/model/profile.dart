/// A shared data model representing application user profiles (profiles table)
/// in KK Group Site Vault, referenced across expenses, documents, and audits.
class Profile {
  final String id;
  final String displayName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.displayName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
