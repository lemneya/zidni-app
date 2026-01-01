import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';

/// Service to manage Eyes scan history using SharedPreferences
/// Gate EYES-1: Save to History functionality
class EyesHistoryService {
  static const String _historyKey = 'eyes_scan_history';
  static const String _auditLogKey = 'eyes_audit_log';
  static const int _maxHistoryItems = 100;
  
  /// Save a scan result to history
  static Future<EyesScanResult> saveToHistory(EyesScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Generate ID if not present
    final id = result.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final savedResult = result.copyWith(id: id);
    
    // Add to beginning of list
    history.insert(0, savedResult);
    
    // Trim to max items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    // Save to SharedPreferences
    final jsonList = history.map((r) => r.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
    
    // Log audit event
    await _logAuditEvent('eyes_scan_saved', {
      'id': id,
      'textLength': result.rawText.length,
      'detectedLanguage': result.detectedLanguage,
      'hasImage': result.imagePath != null,
    });
    
    return savedResult;
  }
  
  /// Get all scan history
  static Future<List<EyesScanResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => EyesScanResult.fromJson(json)).toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }
  
  /// Get history count
  static Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }
  
  /// Get a single history item by ID
  static Future<EyesScanResult?> getHistoryItem(String id) async {
    final history = await getHistory();
    try {
      return history.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Delete a history item by ID
  static Future<void> deleteHistoryItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    history.removeWhere((r) => r.id == id);
    
    final jsonList = history.map((r) => r.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
    
    await _logAuditEvent('eyes_scan_deleted', {'id': id});
  }
  
  /// Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await _logAuditEvent('eyes_history_cleared', {});
  }
  
  /// Log an audit event
  static Future<void> _logAuditEvent(String event, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_auditLogKey);
    
    List<Map<String, dynamic>> logs = [];
    if (logsJson != null && logsJson.isNotEmpty) {
      try {
        logs = List<Map<String, dynamic>>.from(jsonDecode(logsJson));
      } catch (e) {
        logs = [];
      }
    }
    
    logs.insert(0, {
      'event': event,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 500 audit logs
    if (logs.length > 500) {
      logs.removeRange(500, logs.length);
    }
    
    await prefs.setString(_auditLogKey, jsonEncode(logs));
  }
  
  /// Get audit logs (for debugging)
  static Future<List<Map<String, dynamic>>> getAuditLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_auditLogKey);
    
    if (logsJson == null || logsJson.isEmpty) {
      return [];
    }
    
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(logsJson));
    } catch (e) {
      return [];
    }
  }
}
