/// User role enumeration matching database roles ('admin', 'staff') exactly.
enum UserRole {
  staff,
  admin;

  /// Parses a string to UserRole enum
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
      default:
        return UserRole.staff;
    }
  }

  /// Converts enum back to database string format
  String toDbString() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.staff:
        return 'staff';
    }
  }

  /// Human-friendly display label
  String toDisplayLabel() {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Staff';
    }
  }
}
