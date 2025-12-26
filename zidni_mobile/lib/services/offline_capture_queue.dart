import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Maximum transcript length to store in SharedPreferences (5000 chars)
const int kMaxTranscriptLength = 5000;

/// Truncation suffix added when transcript is cut
const String kTruncationSuffix = '…[truncated offline]';

/// Status of a pending capture in the queue
enum PendingCaptureStatus {
  queued,
  syncing,
  failed,
}

/// Represents a capture that failed to upload and is queued for retry.
class PendingCapture {
  final String folderId;
  final String folderName;
  final String transcript;
  final DateTime createdAt;
  final bool truncated;
  PendingCaptureStatus status;

  PendingCapture({
    required this.folderId,
    required this.folderName,
    required this.transcript,
    required this.createdAt,
    this.truncated = false,
    this.status = PendingCaptureStatus.queued,
  });

  /// Create a PendingCapture with automatic transcript truncation if needed
  factory PendingCapture.withSizeCap({
    required String folderId,
    required String folderName,
    required String transcript,
    required DateTime createdAt,
  }) {
    if (transcript.length <= kMaxTranscriptLength) {
      return PendingCapture(
        folderId: folderId,
        folderName: folderName,
        transcript: transcript,
        createdAt: createdAt,
        truncated: false,
      );
    }
    // Truncate transcript and add suffix
    final truncatedTranscript = transcript.substring(0, kMaxTranscriptLength - kTruncationSuffix.length) + kTruncationSuffix;
    return PendingCapture(
      folderId: folderId,
      folderName: folderName,
      transcript: truncatedTranscript,
      createdAt: createdAt,
      truncated: true,
    );
  }

  /// Get a preview of the transcript (first 50 chars)
  String get transcriptPreview {
    if (transcript.length <= 50) return transcript;
    return '${transcript.substring(0, 50)}...';
  }

  Map<String, dynamic> toJson() => {
    'folderId': folderId,
    'folderName': folderName,
    'transcript': transcript,
    'createdAt': createdAt.toIso8601String(),
    'truncated': truncated,
  };

  factory PendingCapture.fromJson(Map<String, dynamic> json) => PendingCapture(
    folderId: json['folderId'],
    folderName: json['folderName'],
    transcript: json['transcript'],
    createdAt: DateTime.parse(json['createdAt']),
    truncated: json['truncated'] ?? false,
  );
}

/// Service to manage offline capture queue using SharedPreferences.
/// Stores captures that failed to upload for later retry.
class OfflineCaptureQueue {
  static const String _queueKey = 'offline_capture_queue';
  
  /// In-flight guard to prevent duplicate sync attempts
  static bool _isSyncing = false;
  
  /// Check if sync is currently in progress
  static bool get isSyncing => _isSyncing;

  /// Add a capture to the offline queue with automatic size cap
  static Future<void> addToQueue(PendingCapture capture) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();
    queue.add(capture);
    await _saveQueue(prefs, queue);
  }

  /// Add a capture with automatic transcript truncation
  static Future<void> addToQueueWithSizeCap({
    required String folderId,
    required String folderName,
    required String transcript,
  }) async {
    final capture = PendingCapture.withSizeCap(
      folderId: folderId,
      folderName: folderName,
      transcript: transcript,
      createdAt: DateTime.now(),
    );
    await addToQueue(capture);
  }

  /// Get all pending captures from the queue
  static Future<List<PendingCapture>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_queueKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PendingCapture.fromJson(json)).toList();
    } catch (e) {
      // If parsing fails, return empty queue
      return [];
    }
  }

  /// Get the count of pending captures
  static Future<int> getPendingCount() async {
    final queue = await getQueue();
    return queue.length;
  }

  /// Remove a capture from the queue (after successful upload)
  static Future<void> removeFromQueue(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();
    if (index >= 0 && index < queue.length) {
      queue.removeAt(index);
      await _saveQueue(prefs, queue);
    }
  }

  /// Clear all pending captures from the queue
  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  /// Save the queue to SharedPreferences
  static Future<void> _saveQueue(SharedPreferences prefs, List<PendingCapture> queue) async {
    final jsonList = queue.map((c) => c.toJson()).toList();
    await prefs.setString(_queueKey, jsonEncode(jsonList));
  }

  /// Start sync operation (returns false if already syncing)
  static bool startSync() {
    if (_isSyncing) return false;
    _isSyncing = true;
    return true;
  }

  /// End sync operation
  static void endSync() {
    _isSyncing = false;
  }
}
