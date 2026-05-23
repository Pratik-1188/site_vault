import 'package:site_vault/shared/model/profile.dart';

/// Supported payment modes in KK Group matching Supabase PG enum exactly.
enum PaymentMode {
  cash,
  upi,
  card,
  netBanking,
  cheque,
  rtgs,
  neft,
  dd,
  other;

  /// Parses a string to PaymentMode enum
  static PaymentMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return PaymentMode.cash;
      case 'upi':
        return PaymentMode.upi;
      case 'card':
        return PaymentMode.card;
      case 'net_banking':
        return PaymentMode.netBanking;
      case 'cheque':
        return PaymentMode.cheque;
      case 'rtgs':
        return PaymentMode.rtgs;
      case 'neft':
        return PaymentMode.neft;
      case 'dd':
        return PaymentMode.dd;
      case 'other':
      default:
        return PaymentMode.other;
    }
  }

  /// Converts enum back to database string format
  String toDbString() {
    switch (this) {
      case PaymentMode.cash:
        return 'cash';
      case PaymentMode.upi:
        return 'upi';
      case PaymentMode.card:
        return 'card';
      case PaymentMode.netBanking:
        return 'net_banking';
      case PaymentMode.cheque:
        return 'cheque';
      case PaymentMode.rtgs:
        return 'rtgs';
      case PaymentMode.neft:
        return 'neft';
      case PaymentMode.dd:
        return 'dd';
      case PaymentMode.other:
        return 'other';
    }
  }

  /// Human-friendly display label
  String toDisplayLabel() {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.netBanking:
        return 'Net Banking';
      case PaymentMode.cheque:
        return 'Cheque';
      case PaymentMode.rtgs:
        return 'RTGS';
      case PaymentMode.neft:
        return 'NEFT';
      case PaymentMode.dd:
        return 'Demand Draft';
      case PaymentMode.other:
        return 'Other';
    }
  }
}

/// Expense Categories table representation
class ExpenseCategory {
  final String id;
  final String name;
  final bool isActive;
  final DateTime? createdAt;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.isActive,
    this.createdAt,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

/// Vendors table representation
class Vendor {
  final String id;
  final String name;
  final String? contactInfo;
  final bool isActive;
  final DateTime? createdAt;

  Vendor({
    required this.id,
    required this.name,
    this.contactInfo,
    required this.isActive,
    this.createdAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      name: json['name'] as String,
      contactInfo: json['contact_info'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_info': contactInfo,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

/// Core Expense data model matching database constraints and relationships.
class Expense {
  final String id;
  final String firmId;
  final String siteId;
  
  final String createdBy;
  final String paidBy;
  
  final String title;
  final String? description;
  final DateTime expenseDate;
  
  final String? categoryId;
  final String? vendorId;
  
  /// Total amount spent (includes GST)
  final double amount;
  
  final double? gstPercentage;
  final double? gstAmount;
  
  final PaymentMode paymentMode;
  final bool isRefundable;
  
  final DateTime? softDeletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined relations (optional)
  final ExpenseCategory? category;
  final Vendor? vendor;
  final Profile? paidByProfile;
  final Profile? createdByProfile;

  Expense({
    required this.id,
    required this.firmId,
    required this.siteId,
    required this.createdBy,
    required this.paidBy,
    required this.title,
    this.description,
    required this.expenseDate,
    this.categoryId,
    this.vendorId,
    required this.amount,
    this.gstPercentage,
    this.gstAmount,
    required this.paymentMode,
    required this.isRefundable,
    this.softDeletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.vendor,
    this.paidByProfile,
    this.createdByProfile,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      firmId: json['firm_id'] as String,
      siteId: json['site_id'] as String,
      createdBy: json['created_by'] as String,
      paidBy: json['paid_by'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      categoryId: json['category_id'] as String?,
      vendorId: json['vendor_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      gstPercentage: json['gst_percentage'] != null ? (json['gst_percentage'] as num).toDouble() : null,
      gstAmount: json['gst_amount'] != null ? (json['gst_amount'] as num).toDouble() : null,
      paymentMode: PaymentMode.fromString(json['payment_mode'] as String),
      isRefundable: json['is_refundable'] as bool? ?? false,
      softDeletedAt: json['soft_deleted_at'] != null ? DateTime.parse(json['soft_deleted_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      
      // Relations parsed if joined in Supabase select query
      category: json['expense_categories'] != null 
          ? ExpenseCategory.fromJson(json['expense_categories'] as Map<String, dynamic>)
          : null,
      vendor: json['vendors'] != null 
          ? Vendor.fromJson(json['vendors'] as Map<String, dynamic>)
          : null,
      paidByProfile: json['paid_by_profile'] != null 
          ? Profile.fromJson(json['paid_by_profile'] as Map<String, dynamic>)
          : null,
      createdByProfile: json['created_by_profile'] != null 
          ? Profile.fromJson(json['created_by_profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firm_id': firmId,
      'site_id': siteId,
      'created_by': createdBy,
      'paid_by': paidBy,
      'title': title,
      'description': description,
      'expense_date': '${expenseDate.year.toString().padLeft(4, '0')}-${expenseDate.month.toString().padLeft(2, '0')}-${expenseDate.day.toString().padLeft(2, '0')}',
      'category_id': categoryId,
      'vendor_id': vendorId,
      'amount': amount,
      'gst_percentage': gstPercentage,
      'gst_amount': gstAmount,
      'payment_mode': paymentMode.toDbString(),
      'is_refundable': isRefundable,
      'soft_deleted_at': softDeletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
