
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

  Future<DocumentReference> createDealFolder(String title, {String? supplierName, String? booth}) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('deal_folders').add({
      'ownerUid': _uid,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'supplierName': supplierName,
      'booth': booth,
      'mode': 'personal',
      'workspaceId': null,
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

  Future<void> saveCaptureToFolder(String folderId, String transcript) {
    return _db
        .collection('deal_folders')
        .doc(folderId)
        .collection('captures')
        .add({
      'transcript': transcript,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
