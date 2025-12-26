import 'package:cloud_firestore/cloud_firestore.dart';

class DealFolder {
  final String id;
  final String ownerUid;
  final String title;
  final DateTime createdAt;
  final String? supplierName;
  final String? booth;
  final String mode;
  final String? workspaceId;
  final String? category;
  final String? priority;
  final bool followupDone;
  final DateTime? lastCaptureAt;

  DealFolder({
    required this.id,
    required this.ownerUid,
    required this.title,
    required this.createdAt,
    this.supplierName,
    this.booth,
    required this.mode,
    this.workspaceId,
    this.category,
    this.priority,
    this.followupDone = false,
    this.lastCaptureAt,
  });

  factory DealFolder.fromFirestore(String id, Map<String, dynamic> data) {
    return DealFolder(
      id: id,
      ownerUid: data['ownerUid'],
      title: data['title'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      supplierName: data['supplierName'],
      booth: data['booth'],
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
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'supplierName': supplierName,
      'booth': booth,
      'mode': mode,
      'workspaceId': workspaceId,
      'category': category,
      'priority': priority,
      'followupDone': followupDone,
      'lastCaptureAt': lastCaptureAt != null ? Timestamp.fromDate(lastCaptureAt!) : null,
    };
  }
}
