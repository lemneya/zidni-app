import 'package:cloud_firestore/cloud_firestore.dart';

class DealFolder {
  final String id;
  final String ownerUid;
  final DateTime createdAt;
  final String? supplierName;
  final String? boothHall;
  final String mode;
  final String? workspaceId;
  final String? category;
  final String? priority;
  final bool followupDone;
  final DateTime? lastCaptureAt;

  DealFolder({
    required this.id,
    required this.ownerUid,
    required this.createdAt,
    this.supplierName,
    this.boothHall,
    required this.mode,
    this.workspaceId,
    this.category,
    this.priority,
    this.followupDone = false,
    this.lastCaptureAt,
  });

  /// Display name: supplierName > category > fallback
  String get displayName {
    if (supplierName != null && supplierName!.isNotEmpty) {
      return supplierName!;
    }
    if (category != null && category!.isNotEmpty) {
      return category!;
    }
    return 'بدون تصنيف';
  }

  factory DealFolder.fromFirestore(String id, Map<String, dynamic> data) {
    return DealFolder(
      id: id,
      ownerUid: data['ownerUid'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      supplierName: data['supplierName'],
      boothHall: data['boothHall'] ?? data['booth'],  // backward-compat read fallback
      mode: data['mode'] ?? 'personal',
      workspaceId: data['workspaceId'],
      category: data['category'],
      priority: data['priority'],
      followupDone: data['followupDone'] ?? false,
      lastCaptureAt: (data['lastCaptureAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerUid': ownerUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'supplierName': supplierName,
      'boothHall': boothHall,
      'mode': mode,
      'workspaceId': workspaceId,
      'category': category,
      'priority': priority,
      'followupDone': followupDone,
      'lastCaptureAt': lastCaptureAt != null ? Timestamp.fromDate(lastCaptureAt!) : null,
    };
  }
}
