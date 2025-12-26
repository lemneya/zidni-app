
import 'package:cloud_firestore/cloud_firestore.dart';

class GulCapture {
  final String? id;
  final String transcript;
  final DateTime createdAt;

  GulCapture({
    this.id,
    required this.transcript,
    required this.createdAt,
  });

  factory GulCapture.fromFirestore(String id, Map<String, dynamic> data) {
    return GulCapture(
      id: id,
      transcript: data['transcript'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
