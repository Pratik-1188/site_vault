import 'package:site_vault/feature/site/model/site_status.dart';

class Site {
  final String id;
  final String firmId;

  final String name;
  final String? description;

  final DateTime? startedOn;
  final DateTime? completedOn;

  final SiteStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;

  Site({
    required this.id,
    required this.firmId,
    required this.name,
    this.description,
    this.startedOn,
    this.completedOn,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] as String,
      firmId: json['firm_id'] as String,

      name: json['name'] as String,
      description: json['description'] as String?,

      startedOn: json['started_on'] != null
          ? DateTime.parse(json['started_on'])
          : null,

      completedOn: json['completed_on'] != null
          ? DateTime.parse(json['completed_on'])
          : null,

      status: SiteStatus.fromString(json['status'] as String),

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
