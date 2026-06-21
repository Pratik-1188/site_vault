/// Site status enumeration matching database values exactly.
enum SiteStatus {
  active,
  completed,
  deleted;

  /// Parses a string to SiteStatus enum
  static SiteStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return SiteStatus.completed;
      case 'deleted':
        return SiteStatus.deleted;
      case 'active':
      default:
        return SiteStatus.active;
    }
  }

  /// Converts enum back to database string format
  String toDbString() {
    switch (this) {
      case SiteStatus.active:
        return 'active';
      case SiteStatus.completed:
        return 'completed';
      case SiteStatus.deleted:
        return 'deleted';
    }
  }

  /// Human-friendly display label
  String toDisplayLabel() {
    switch (this) {
      case SiteStatus.active:
        return 'Active';
      case SiteStatus.completed:
        return 'Completed';
      case SiteStatus.deleted:
        return 'Deleted';
    }
  }
}
