/// Usage Record Model
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Tracks usage counts for metering and analytics

/// Types of usage to track
enum UsageType {
  /// Eyes OCR scans
  eyesScans,
  
  /// Eyes searches (Find It)
  eyesSearches,
  
  /// Deals created
  dealsCreated,
  
  /// Follow-up kit copies
  followupCopies,
  
  /// Export attempts (PDF, etc.)
  exportsAttempted,
  
  /// Cloud boost attempts
  cloudBoostAttempted,
  
  /// GUL translations
  gulTranslations,

  /// WhatsApp sends (Gate COMM-1)
  whatsappSends,
}

extension UsageTypeExtension on UsageType {
  /// Get storage key for this usage type
  String get storageKey {
    switch (this) {
      case UsageType.eyesScans:
        return 'eyes_scans';
      case UsageType.eyesSearches:
        return 'eyes_searches';
      case UsageType.dealsCreated:
        return 'deals_created';
      case UsageType.followupCopies:
        return 'followup_copies';
      case UsageType.exportsAttempted:
        return 'exports_attempted';
      case UsageType.cloudBoostAttempted:
        return 'cloud_boost_attempted';
      case UsageType.gulTranslations:
        return 'gul_translations';
      case UsageType.whatsappSends:
        return 'whatsapp_sends';
    }
  }
  
  /// Get Arabic display name
  String get arabicName {
    switch (this) {
      case UsageType.eyesScans:
        return 'مسح المنتجات';
      case UsageType.eyesSearches:
        return 'عمليات البحث';
      case UsageType.dealsCreated:
        return 'الصفقات';
      case UsageType.followupCopies:
        return 'نسخ المتابعات';
      case UsageType.exportsAttempted:
        return 'محاولات التصدير';
      case UsageType.cloudBoostAttempted:
        return 'التعزيز السحابي';
      case UsageType.gulTranslations:
        return 'الترجمات';
      case UsageType.whatsappSends:
        return 'إرسال واتساب';
    }
  }
  
  /// Get English display name
  String get englishName {
    switch (this) {
      case UsageType.eyesScans:
        return 'Product Scans';
      case UsageType.eyesSearches:
        return 'Searches';
      case UsageType.dealsCreated:
        return 'Deals Created';
      case UsageType.followupCopies:
        return 'Follow-up Copies';
      case UsageType.exportsAttempted:
        return 'Export Attempts';
      case UsageType.cloudBoostAttempted:
        return 'Cloud Boosts';
      case UsageType.gulTranslations:
        return 'Translations';
      case UsageType.whatsappSends:
        return 'WhatsApp Sends';
    }
  }
  
  /// Get usage type from storage key
  static UsageType fromKey(String key) {
    for (final type in UsageType.values) {
      if (type.storageKey == key) {
        return type;
      }
    }
    return UsageType.eyesScans; // Default fallback
  }
}

/// A single usage record entry
class UsageRecord {
  /// Type of usage
  final UsageType type;
  
  /// Date of the usage (day granularity)
  final DateTime date;
  
  /// Count for this date
  final int count;
  
  UsageRecord({
    required this.type,
    required this.date,
    required this.count,
  });
  
  /// Get date key for storage (YYYY-MM-DD format)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Create from JSON
  factory UsageRecord.fromJson(Map<String, dynamic> json) {
    return UsageRecord(
      type: UsageTypeExtension.fromKey(json['type'] ?? ''),
      date: DateTime.parse(json['date']),
      count: json['count'] ?? 0,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'type': type.storageKey,
    'date': date.toIso8601String(),
    'count': count,
  };
  
  /// Copy with incremented count
  UsageRecord increment([int by = 1]) {
    return UsageRecord(
      type: type,
      date: date,
      count: count + by,
    );
  }
}

/// Aggregated usage summary
class UsageSummary {
  /// Total count for today
  final int todayCount;
  
  /// Total count for this week (last 7 days)
  final int weekCount;
  
  /// Total count for this month (last 30 days)
  final int monthCount;
  
  /// Total count all time
  final int totalCount;
  
  /// First usage date
  final DateTime? firstUsageDate;
  
  /// Last usage date
  final DateTime? lastUsageDate;
  
  UsageSummary({
    required this.todayCount,
    required this.weekCount,
    required this.monthCount,
    required this.totalCount,
    this.firstUsageDate,
    this.lastUsageDate,
  });
  
  /// Create empty summary
  factory UsageSummary.empty() {
    return UsageSummary(
      todayCount: 0,
      weekCount: 0,
      monthCount: 0,
      totalCount: 0,
    );
  }
}
