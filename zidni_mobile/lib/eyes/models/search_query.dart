/// Model for a search query built from OCR results
/// Gate EYES-2: Find Where To Buy
class SearchQuery {
  final String baseQuery;
  final String? brand;
  final String? model;
  final String? sku;
  final List<String> keywords;
  final List<String> contextChips;
  final String platform;
  final DateTime createdAt;
  final String? scanResultId;

  SearchQuery({
    required this.baseQuery,
    this.brand,
    this.model,
    this.sku,
    this.keywords = const [],
    this.contextChips = const [],
    required this.platform,
    required this.createdAt,
    this.scanResultId,
  });

  /// Build the full search query string with context chips
  String get fullQuery {
    final parts = <String>[baseQuery];
    for (final chip in contextChips) {
      parts.add(chip);
    }
    return parts.join(' ');
  }

  /// Create from JSON (for SharedPreferences storage)
  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      baseQuery: json['baseQuery'] ?? '',
      brand: json['brand'],
      model: json['model'],
      sku: json['sku'],
      keywords: List<String>.from(json['keywords'] ?? []),
      contextChips: List<String>.from(json['contextChips'] ?? []),
      platform: json['platform'] ?? 'unknown',
      createdAt: DateTime.parse(json['createdAt']),
      scanResultId: json['scanResultId'],
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'baseQuery': baseQuery,
    'brand': brand,
    'model': model,
    'sku': sku,
    'keywords': keywords,
    'contextChips': contextChips,
    'platform': platform,
    'createdAt': createdAt.toIso8601String(),
    'scanResultId': scanResultId,
  };

  /// Copy with new values
  SearchQuery copyWith({
    String? baseQuery,
    String? brand,
    String? model,
    String? sku,
    List<String>? keywords,
    List<String>? contextChips,
    String? platform,
    DateTime? createdAt,
    String? scanResultId,
  }) {
    return SearchQuery(
      baseQuery: baseQuery ?? this.baseQuery,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      sku: sku ?? this.sku,
      keywords: keywords ?? this.keywords,
      contextChips: contextChips ?? this.contextChips,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      scanResultId: scanResultId ?? this.scanResultId,
    );
  }
}

/// Available search platforms
enum SearchPlatform {
  alibaba,
  alibaba1688,
  madeInChina,
  google,
  baidu,
}

extension SearchPlatformExtension on SearchPlatform {
  String get name {
    switch (this) {
      case SearchPlatform.alibaba:
        return 'Alibaba';
      case SearchPlatform.alibaba1688:
        return '1688';
      case SearchPlatform.madeInChina:
        return 'Made-in-China';
      case SearchPlatform.google:
        return 'Google';
      case SearchPlatform.baidu:
        return 'Baidu';
    }
  }

  String get arabicName {
    switch (this) {
      case SearchPlatform.alibaba:
        return 'علي بابا';
      case SearchPlatform.alibaba1688:
        return '1688';
      case SearchPlatform.madeInChina:
        return 'صنع في الصين';
      case SearchPlatform.google:
        return 'جوجل';
      case SearchPlatform.baidu:
        return 'بايدو';
    }
  }

  String get icon {
    switch (this) {
      case SearchPlatform.alibaba:
        return '🛒';
      case SearchPlatform.alibaba1688:
        return '🏭';
      case SearchPlatform.madeInChina:
        return '🇨🇳';
      case SearchPlatform.google:
        return '🔍';
      case SearchPlatform.baidu:
        return '🔎';
    }
  }

  String buildSearchUrl(String query) {
    final encodedQuery = Uri.encodeComponent(query);
    switch (this) {
      case SearchPlatform.alibaba:
        return 'https://www.alibaba.com/trade/search?SearchText=$encodedQuery';
      case SearchPlatform.alibaba1688:
        return 'https://s.1688.com/selloffer/offer_search.htm?keywords=$encodedQuery';
      case SearchPlatform.madeInChina:
        return 'https://www.made-in-china.com/products-search/hot-china-products/$encodedQuery.html';
      case SearchPlatform.google:
        return 'https://www.google.com/search?q=$encodedQuery';
      case SearchPlatform.baidu:
        return 'https://www.baidu.com/s?wd=$encodedQuery';
    }
  }
}

/// Context chips for modifying search queries
class ContextChip {
  final String id;
  final String label;
  final String arabicLabel;
  final String queryModifier;
  final ContextChipCategory category;

  const ContextChip({
    required this.id,
    required this.label,
    required this.arabicLabel,
    required this.queryModifier,
    required this.category,
  });
}

enum ContextChipCategory {
  location,
  businessType,
  terms,
}

/// Predefined context chips
class ContextChips {
  static const List<ContextChip> all = [
    // Location chips
    ContextChip(
      id: 'guangzhou',
      label: 'Guangzhou',
      arabicLabel: 'قوانغتشو',
      queryModifier: '广州',
      category: ContextChipCategory.location,
    ),
    ContextChip(
      id: 'foshan',
      label: 'Foshan',
      arabicLabel: 'فوشان',
      queryModifier: '佛山',
      category: ContextChipCategory.location,
    ),
    ContextChip(
      id: 'yiwu',
      label: 'Yiwu',
      arabicLabel: 'ييوو',
      queryModifier: '义乌',
      category: ContextChipCategory.location,
    ),
    // Business type chips
    ContextChip(
      id: 'factory',
      label: 'Factory',
      arabicLabel: 'مصنع',
      queryModifier: '工厂',
      category: ContextChipCategory.businessType,
    ),
    ContextChip(
      id: 'wholesaler',
      label: 'Wholesaler',
      arabicLabel: 'تاجر جملة',
      queryModifier: '批发',
      category: ContextChipCategory.businessType,
    ),
    // Terms chips
    ContextChip(
      id: 'moq',
      label: 'MOQ',
      arabicLabel: 'الحد الأدنى',
      queryModifier: 'MOQ',
      category: ContextChipCategory.terms,
    ),
    ContextChip(
      id: 'price',
      label: 'Price',
      arabicLabel: 'السعر',
      queryModifier: '价格',
      category: ContextChipCategory.terms,
    ),
  ];

  static List<ContextChip> byCategory(ContextChipCategory category) {
    return all.where((chip) => chip.category == category).toList();
  }
}
