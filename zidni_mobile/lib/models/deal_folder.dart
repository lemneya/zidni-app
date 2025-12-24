
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

  DealFolder({
    required this.id,
    required this.ownerUid,
    required this.title,
    required this.createdAt,
    this.supplierName,
    this.booth,
    required this.mode,
    this.workspaceId,
  });

  factory DealFolder.fromFirestore(String id, Map<String, dynamic> data) {
    return DealFolder(
      id: id,
      ownerUid: data['ownerUid'],
      title: data['title'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      supplierName: data['supplierName'],
      booth: data['booth'],
      mode: data['mode'] ?? 'personal',
      workspaceId: data['workspaceId'],
    );
  }
}
