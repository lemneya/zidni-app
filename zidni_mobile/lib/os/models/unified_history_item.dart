/// Unified History Item Model
/// Gate OS-1: GUL↔Eyes Bridge + Unified History
///
/// Represents any item in the unified history feed:
/// - GUL translations
/// - Eyes scans
/// - Eyes searches
/// - Deals

/// Type of history item
enum HistoryItemType {
  translation,  // GUL translation capture
  eyesScan,     // Eyes OCR scan
  eyesSearch,   // Eyes search attempt
  deal,         // Deal created from Eyes
}

/// Extension for HistoryItemType display info
extension HistoryItemTypeExtension on HistoryItemType {
  String get arabicName {
    switch (this) {
      case HistoryItemType.translation:
        return 'ترجمة';
      case HistoryItemType.eyesScan:
        return 'مسح';
      case HistoryItemType.eyesSearch:
        return 'بحث';
      case HistoryItemType.deal:
        return 'صفقة';
    }
  }

  String get englishName {
    switch (this) {
      case HistoryItemType.translation:
        return 'Translation';
      case HistoryItemType.eyesScan:
        return 'Scan';
      case HistoryItemType.eyesSearch:
        return 'Search';
      case HistoryItemType.deal:
        return 'Deal';
    }
  }

  String get icon {
    switch (this) {
      case HistoryItemType.translation:
        return '🎙️';
      case HistoryItemType.eyesScan:
        return '📷';
      case HistoryItemType.eyesSearch:
        return '🔍';
      case HistoryItemType.deal:
        return '🤝';
    }
  }

  String get auditEvent {
    switch (this) {
      case HistoryItemType.translation:
        return 'gul_capture_saved';
      case HistoryItemType.eyesScan:
        return 'eyes_scan_saved';
      case HistoryItemType.eyesSearch:
        return 'eyes_search_saved';
      case HistoryItemType.deal:
        return 'deal_created_from_eyes';
    }
  }
}

/// Unified history item that can represent any type of capture
class UnifiedHistoryItem {
  final String id;
  final HistoryItemType type;
  final String title;
  final String? subtitle;
  final String? preview;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const UnifiedHistoryItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.preview,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Create from Eyes scan result
  factory UnifiedHistoryItem.fromEyesScan({
    required String id,
    required String productName,
    required String rawText,
    required DateTime createdAt,
    String? imagePath,
    Map<String, String> extractedFields = const {},
  }) {
    return UnifiedHistoryItem(
      id: id,
      type: HistoryItemType.eyesScan,
      title: productName.isNotEmpty ? productName : 'مسح منتج',
      subtitle: extractedFields['brand'],
      preview: rawText.length > 100 ? '${rawText.substring(0, 100)}...' : rawText,
      createdAt: createdAt,
      metadata: {
        'rawText': rawText,
        'imagePath': imagePath,
        'extractedFields': extractedFields,
      },
    );
  }

  /// Create from Eyes search
  factory UnifiedHistoryItem.fromEyesSearch({
    required String id,
    required String query,
    required String platform,
    required DateTime createdAt,
    List<String> contextChips = const [],
  }) {
    return UnifiedHistoryItem(
      id: id,
      type: HistoryItemType.eyesSearch,
      title: query,
      subtitle: platform,
      preview: contextChips.isNotEmpty ? contextChips.join(' • ') : null,
      createdAt: createdAt,
      metadata: {
        'query': query,
        'platform': platform,
        'contextChips': contextChips,
      },
    );
  }

  /// Create from Deal
  factory UnifiedHistoryItem.fromDeal({
    required String id,
    required String productName,
    required String? platform,
    required DateTime createdAt,
    String? status,
    List<String> contextChips = const [],
  }) {
    return UnifiedHistoryItem(
      id: id,
      type: HistoryItemType.deal,
      title: productName,
      subtitle: platform,
      preview: status,
      createdAt: createdAt,
      metadata: {
        'platform': platform,
        'status': status,
        'contextChips': contextChips,
      },
    );
  }

  /// Create from GUL translation capture
  factory UnifiedHistoryItem.fromTranslation({
    required String id,
    required String transcript,
    required String translation,
    required String fromLang,
    required String toLang,
    required DateTime createdAt,
  }) {
    return UnifiedHistoryItem(
      id: id,
      type: HistoryItemType.translation,
      title: transcript.length > 50 ? '${transcript.substring(0, 50)}...' : transcript,
      subtitle: '$fromLang → $toLang',
      preview: translation.length > 100 ? '${translation.substring(0, 100)}...' : translation,
      createdAt: createdAt,
      metadata: {
        'transcript': transcript,
        'translation': translation,
        'fromLang': fromLang,
        'toLang': toLang,
      },
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'preview': preview,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  /// Deserialize from JSON
  factory UnifiedHistoryItem.fromJson(Map<String, dynamic> json) {
    return UnifiedHistoryItem(
      id: json['id'] as String,
      type: HistoryItemType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => HistoryItemType.eyesScan,
      ),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      preview: json['preview'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Get formatted time string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} يوم';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
