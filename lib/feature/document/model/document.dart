import 'package:site_vault/shared/model/profile.dart';

/// Represents a site-wide project document record in the documents table,
/// such as layout sheets, approval PDFs, or safety blueprints.
class SiteDocument {
  final String id;
  final String siteId;
  final String createdBy;
  final String fileName;
  final String? description;
  final String fileUrl;
  final DateTime? softDeletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined profile relation (optional)
  final Profile? createdByProfile;

  SiteDocument({
    required this.id,
    required this.siteId,
    required this.createdBy,
    required this.fileName,
    this.description,
    required this.fileUrl,
    this.softDeletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.createdByProfile,
  });

  factory SiteDocument.fromJson(Map<String, dynamic> json) {
    return SiteDocument(
      id: json['id'] as String,
      siteId: json['site_id'] as String,
      createdBy: json['created_by'] as String,
      fileName: json['file_name'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      softDeletedAt: json['soft_deleted_at'] != null
          ? DateTime.parse(json['soft_deleted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),

      // Parses profiles join automatically if loaded via select
      createdByProfile: json['profiles'] != null
          ? Profile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'site_id': siteId,
      'created_by': createdBy,
      'file_name': fileName,
      'description': description,
      'file_url': fileUrl,
      'soft_deleted_at': softDeletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Returns only the fields needed for a database INSERT.
  /// Excludes server-managed fields (created_at, updated_at)
  /// which are auto-set by database defaults.
  Map<String, dynamic> toInsertJson() {
    final data = <String, dynamic>{
      'site_id': siteId,
      'created_by': createdBy,
      'file_name': fileName,
      'file_url': fileUrl,
    };
    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }
    return data;
  }
}
