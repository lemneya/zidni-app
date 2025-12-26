import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a capture that failed to upload and is queued for retry.
class PendingCapture {
  final String folderId;
  final String folderName;
  final String transcript;
  final DateTime createdAt;

  PendingCapture({
    required this.folderId,
    required this.folderName,
    required this.transcript,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'folderId': folderId,
    'folderName': folderName,
    'transcript': transcript,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PendingCapture.fromJson(Map<String, dynamic> json) => PendingCapture(
    folderId: json['folderId'],
    folderName: json['folderName'],
    transcript: json['transcript'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

/// Service to manage offline capture queue using SharedPreferences.
/// Stores captures that failed to upload for later retry.
class OfflineCaptureQueue {
  static const String _queueKey = 'offline_capture_queue';

  /// Add a capture to the offline queue
  static Future<void> addToQueue(PendingCapture capture) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();
    queue.add(capture);
    await _saveQueue(prefs, queue);
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
}
