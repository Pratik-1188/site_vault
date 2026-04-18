class Firm {
  final String id;

  final String name;
  final String? description;

  final DateTime createdAt;
  final DateTime updatedAt;

  Firm({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Firm.fromJson(Map<String, dynamic> json) {
    return Firm(
      id: json['id'] as String,

      name: json['name'] as String,
      description: json['description'] as String?,

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
