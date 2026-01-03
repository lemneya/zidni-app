import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase service for Zidni Admin Dashboard
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // These will be replaced with actual values from firebase_options.dart
        apiKey: 'YOUR_API_KEY',
        appId: 'YOUR_APP_ID',
        messagingSenderId: 'YOUR_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_STORAGE_BUCKET',
      ),
    );
  }

  /// Sign in with email and password (admin only)
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if user is admin
      final isAdmin = await checkAdminRole(credential.user?.uid);
      if (!isAdmin) {
        await auth.signOut();
        throw Exception('Access denied. Admin role required.');
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication failed: ${e.message}');
    }
  }

  /// Check if user has admin role
  Future<bool> checkAdminRole(String? uid) async {
    if (uid == null) return false;
    
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      final data = doc.data();
      return data?['role'] == 'admin' || data?['role'] == 'owner';
    } catch (e) {
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // ============ USER MANAGEMENT ============

  /// Get all users with pagination
  Future<List<Map<String, dynamic>>> getUsers({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = firestore.collection('users').limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    }).toList();
  }

  /// Get user count
  Future<int> getUserCount() async {
    final snapshot = await firestore.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  /// Update user role
  Future<void> updateUserRole(String userId, String role) async {
    await firestore.collection('users').doc(userId).update({'role': role});
  }

  /// Suspend/activate user
  Future<void> setUserStatus(String userId, bool isActive) async {
    await firestore.collection('users').doc(userId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ DEAL MANAGEMENT ============

  /// Get all deals with pagination
  Future<List<Map<String, dynamic>>> getDeals({
    int limit = 50,
    String? status,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = firestore.collection('deals').limit(limit);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    }).toList();
  }

  /// Get deal statistics
  Future<Map<String, int>> getDealStats() async {
    final statuses = ['draft', 'active', 'negotiating', 'completed', 'cancelled'];
    final stats = <String, int>{};
    
    for (final status in statuses) {
      final snapshot = await firestore
          .collection('deals')
          .where('status', isEqualTo: status)
          .count()
          .get();
      stats[status] = snapshot.count ?? 0;
    }
    
    return stats;
  }

  /// Get deal count
  Future<int> getDealCount() async {
    final snapshot = await firestore.collection('deals').count().get();
    return snapshot.count ?? 0;
  }

  // ============ ANALYTICS ============

  /// Get daily active users (last 30 days)
  Future<List<Map<String, dynamic>>> getDailyActiveUsers() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final snapshot = await firestore
        .collection('analytics')
        .doc('daily')
        .collection('dau')
        .where('date', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('date')
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get translation usage stats
  Future<Map<String, dynamic>> getTranslationStats() async {
    final doc = await firestore.collection('analytics').doc('translations').get();
    return doc.data() ?? {'totalCalls': 0, 'todayCalls': 0};
  }

  // ============ CONTENT MANAGEMENT ============

  /// Get all phrase packs
  Future<List<Map<String, dynamic>>> getPhrasePacks() async {
    final snapshot = await firestore.collection('phrasePacks').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Create phrase pack
  Future<void> createPhrasePack(Map<String, dynamic> pack) async {
    await firestore.collection('phrasePacks').add({
      ...pack,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update phrase pack
  Future<void> updatePhrasePack(String id, Map<String, dynamic> pack) async {
    await firestore.collection('phrasePacks').doc(id).update({
      ...pack,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete phrase pack
  Future<void> deletePhrasePack(String id) async {
    await firestore.collection('phrasePacks').doc(id).delete();
  }
}
