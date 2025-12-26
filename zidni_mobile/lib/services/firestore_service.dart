import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/deal_folder.dart';
import '../models/gul_capture.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<DealFolder>> getDealFolders() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('deal_folders')
        .where('ownerUid', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DealFolder.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Get folders for follow-up queue (Hot/Warm priority, not done)
  Stream<List<DealFolder>> getFollowupQueue({bool showDone = false, List<String>? priorities}) {
    if (_uid == null) return Stream.value([]);
    
    Query<Map<String, dynamic>> query = _db
        .collection('deal_folders')
        .where('ownerUid', isEqualTo: _uid);
    
    // Filter by priority if specified
    if (priorities != null && priorities.isNotEmpty) {
      query = query.where('priority', whereIn: priorities);
    }
    
    // Filter by followupDone status
    if (!showDone) {
      query = query.where('followupDone', isEqualTo: false);
    }
    
    // Order by lastCaptureAt (most recent action first), with null-safe client-side sort
    return query
        .snapshots()
        .map((snapshot) {
          final folders = snapshot.docs
              .map((doc) => DealFolder.fromFirestore(doc.id, doc.data()))
              .toList();
          // Sort: folders with lastCaptureAt first (desc), then by createdAt (desc)
          folders.sort((a, b) {
            final aTime = a.lastCaptureAt ?? a.createdAt;
            final bTime = b.lastCaptureAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });
          return folders;
        });
  }

  Future<DocumentReference> createDealFolder({
    String? supplierName,
    String? boothHall,
    String? category,
    String? priority,
  }) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('deal_folders').add({
      'ownerUid': _uid,
      'createdAt': FieldValue.serverTimestamp(),
      'supplierName': supplierName,
      'boothHall': boothHall,
      'mode': 'personal',
      'workspaceId': null,
      'category': category,
      'priority': priority,
      'followupDone': false,
      'lastCaptureAt': null,
    });
  }

  /// Update the followupDone status of a folder
  Future<void> updateFollowupDone(String folderId, bool done) {
    return _db.collection('deal_folders').doc(folderId).update({
      'followupDone': done,
    });
  }

  Stream<List<GulCapture>> getCapturesForFolder(String folderId) {
    return _db
        .collection('deal_folders')
        .doc(folderId)
        .collection('captures')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GulCapture.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Get the latest capture for a folder
  Future<GulCapture?> getLatestCapture(String folderId) async {
    final snapshot = await _db
        .collection('deal_folders')
        .doc(folderId)
        .collection('captures')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return GulCapture.fromFirestore(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Future<void> saveCaptureToFolder(String folderId, String transcript) async {
    final batch = _db.batch();
    
    // Add the capture
    final captureRef = _db
        .collection('deal_folders')
        .doc(folderId)
        .collection('captures')
        .doc();
    
    batch.set(captureRef, {
      'transcript': transcript,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Update lastCaptureAt on the folder
    final folderRef = _db.collection('deal_folders').doc(folderId);
    batch.update(folderRef, {
      'lastCaptureAt': FieldValue.serverTimestamp(),
    });
    
    await batch.commit();
  }
}
