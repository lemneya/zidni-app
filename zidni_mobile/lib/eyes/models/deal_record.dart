import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';

/// Model for a Deal Record created from Eyes scan
/// Gate EYES-3: Create Deal + Follow-up Kit from Eyes
class DealRecord {
  final String id;
  final String? productName;
  final String ocrRawText;
  final Map<String, String> extractedFields;
  final String searchQuery;
  final String? selectedPlatform;
  final List<String> contextChips;
  final DateTime createdAt;
  final String? imagePath;
  final String? scanResultId;
  final DealStatus status;

  DealRecord({
    required this.id,
    this.productName,
    required this.ocrRawText,
    this.extractedFields = const {},
    required this.searchQuery,
    this.selectedPlatform,
    this.contextChips = const [],
    required this.createdAt,
    this.imagePath,
    this.scanResultId,
    this.status = DealStatus.created,
  });

  /// Create from EyesScanResult and SearchQuery
  factory DealRecord.fromScanAndQuery({
    required EyesScanResult scanResult,
    required SearchQuery query,
    String? selectedPlatform,
  }) {
    return DealRecord(
      id: 'deal_${DateTime.now().millisecondsSinceEpoch}',
      productName: scanResult.productNameGuess,
      ocrRawText: scanResult.rawText,
      extractedFields: scanResult.extractedFields,
      searchQuery: query.fullQuery,
      selectedPlatform: selectedPlatform,
      contextChips: query.contextChips,
      createdAt: DateTime.now(),
      imagePath: scanResult.imagePath,
      scanResultId: scanResult.id,
    );
  }

  /// Create from JSON (for SharedPreferences storage)
  factory DealRecord.fromJson(Map<String, dynamic> json) {
    return DealRecord(
      id: json['id'] ?? '',
      productName: json['productName'],
      ocrRawText: json['ocrRawText'] ?? '',
      extractedFields: Map<String, String>.from(json['extractedFields'] ?? {}),
      searchQuery: json['searchQuery'] ?? '',
      selectedPlatform: json['selectedPlatform'],
      contextChips: List<String>.from(json['contextChips'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      imagePath: json['imagePath'],
      scanResultId: json['scanResultId'],
      status: DealStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DealStatus.created,
      ),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'productName': productName,
    'ocrRawText': ocrRawText,
    'extractedFields': extractedFields,
    'searchQuery': searchQuery,
    'selectedPlatform': selectedPlatform,
    'contextChips': contextChips,
    'createdAt': createdAt.toIso8601String(),
    'imagePath': imagePath,
    'scanResultId': scanResultId,
    'status': status.name,
  };

  /// Get display name for the deal
  String get displayName {
    if (productName != null && productName!.isNotEmpty) {
      return productName!;
    }
    if (searchQuery.isNotEmpty) {
      return searchQuery.length > 30 
          ? '${searchQuery.substring(0, 30)}...' 
          : searchQuery;
    }
    return 'صفقة ${id.substring(5, 10)}';
  }

  /// Copy with new values
  DealRecord copyWith({
    String? id,
    String? productName,
    String? ocrRawText,
    Map<String, String>? extractedFields,
    String? searchQuery,
    String? selectedPlatform,
    List<String>? contextChips,
    DateTime? createdAt,
    String? imagePath,
    String? scanResultId,
    DealStatus? status,
  }) {
    return DealRecord(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      extractedFields: extractedFields ?? this.extractedFields,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPlatform: selectedPlatform ?? this.selectedPlatform,
      contextChips: contextChips ?? this.contextChips,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      scanResultId: scanResultId ?? this.scanResultId,
      status: status ?? this.status,
    );
  }
}

/// Status of a deal (minimal for MVP)
enum DealStatus {
  created,
  followedUp,
  completed,
}

extension DealStatusExtension on DealStatus {
  String get arabicName {
    switch (this) {
      case DealStatus.created:
        return 'جديدة';
      case DealStatus.followedUp:
        return 'تم المتابعة';
      case DealStatus.completed:
        return 'مكتملة';
    }
  }

  String get englishName {
    switch (this) {
      case DealStatus.created:
        return 'New';
      case DealStatus.followedUp:
        return 'Followed Up';
      case DealStatus.completed:
        return 'Completed';
    }
  }
}
