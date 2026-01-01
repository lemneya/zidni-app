import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';

/// Service to manage search attempt history using SharedPreferences
/// Gate EYES-2: Save search attempts to history
class SearchHistoryService {
  static const String _historyKey = 'eyes_search_history';
  static const String _auditLogKey = 'eyes_search_audit_log';
  static const int _maxHistoryItems = 100;
  
  /// Save a search attempt to history
  static Future<void> saveSearchAttempt(SearchQuery query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Add to beginning of list
    history.insert(0, query);
    
    // Trim to max items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    // Save to SharedPreferences
    final jsonList = history.map((q) => q.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
    
    // Log audit event
    await _logAuditEvent('eyes_search_saved', {
      'platform': query.platform,
      'baseQuery': query.baseQuery,
      'contextChips': query.contextChips,
      'scanResultId': query.scanResultId,
    });
  }
  
  /// Get all search history
  static Future<List<SearchQuery>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => SearchQuery.fromJson(json)).toList();
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
  
  /// Get searches for a specific scan result
  static Future<List<SearchQuery>> getSearchesForScan(String scanResultId) async {
    final history = await getHistory();
    return history.where((q) => q.scanResultId == scanResultId).toList();
  }
  
  /// Clear all search history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await _logAuditEvent('eyes_search_history_cleared', {});
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
