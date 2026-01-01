import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/usage/models/usage_record.dart';

/// Usage Meter Service
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Tracks daily/weekly/monthly usage counters locally

class UsageMeterService {
  static const String _storagePrefix = 'zidni_usage_';
  
  // Cache for performance
  static final Map<String, Map<String, int>> _cache = {};
  
  // ============================================
  // Core tracking methods
  // ============================================
  
  /// Increment usage count for a type
  static Future<int> increment(UsageType type, [int by = 1]) async {
    final today = _getTodayKey();
    final prefs = await SharedPreferences.getInstance();
    final storageKey = '${_storagePrefix}${type.storageKey}';
    
    // Load existing data
    final data = _loadData(prefs, storageKey);
    
    // Increment today's count
    final currentCount = data[today] ?? 0;
    final newCount = currentCount + by;
    data[today] = newCount;
    
    // Save back
    await prefs.setString(storageKey, jsonEncode(data));
    _cache[type.storageKey] = data;
    
    // Log audit event
    _logAuditEvent('usage_incremented', {
      'type': type.storageKey,
      'count': newCount,
      'date': today,
    });
    
    return newCount;
  }
  
  /// Get today's count for a type
  static Future<int> getTodayCount(UsageType type) async {
    final today = _getTodayKey();
    final prefs = await SharedPreferences.getInstance();
    final storageKey = '${_storagePrefix}${type.storageKey}';
    
    final data = _loadData(prefs, storageKey);
    return data[today] ?? 0;
  }
  
  /// Get count for last N days
  static Future<int> getCountForDays(UsageType type, int days) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = '${_storagePrefix}${type.storageKey}';
    
    final data = _loadData(prefs, storageKey);
    
    int total = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _getDateKey(date);
      total += data[key] ?? 0;
    }
    
    return total;
  }
  
  /// Get this week's count (last 7 days)
  static Future<int> getWeekCount(UsageType type) async {
    return getCountForDays(type, 7);
  }
  
  /// Get this month's count (last 30 days)
  static Future<int> getMonthCount(UsageType type) async {
    return getCountForDays(type, 30);
  }
  
  /// Get total count all time
  static Future<int> getTotalCount(UsageType type) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = '${_storagePrefix}${type.storageKey}';
    
    final data = _loadData(prefs, storageKey);
    
    int total = 0;
    for (final count in data.values) {
      total += count;
    }
    
    return total;
  }
  
  /// Get full usage summary for a type
  static Future<UsageSummary> getSummary(UsageType type) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = '${_storagePrefix}${type.storageKey}';
    
    final data = _loadData(prefs, storageKey);
    final today = _getTodayKey();
    final now = DateTime.now();
    
    int todayCount = data[today] ?? 0;
    int weekCount = 0;
    int monthCount = 0;
    int totalCount = 0;
    DateTime? firstDate;
    DateTime? lastDate;
    
    for (final entry in data.entries) {
      final date = _parseDate(entry.key);
      if (date == null) continue;
      
      final count = entry.value;
      totalCount += count;
      
      // Track first and last dates
      if (count > 0) {
        if (firstDate == null || date.isBefore(firstDate)) {
          firstDate = date;
        }
        if (lastDate == null || date.isAfter(lastDate)) {
          lastDate = date;
        }
      }
      
      // Check if within week
      if (now.difference(date).inDays < 7) {
        weekCount += count;
      }
      
      // Check if within month
      if (now.difference(date).inDays < 30) {
        monthCount += count;
      }
    }
    
    return UsageSummary(
      todayCount: todayCount,
      weekCount: weekCount,
      monthCount: monthCount,
      totalCount: totalCount,
      firstUsageDate: firstDate,
      lastUsageDate: lastDate,
    );
  }
  
  /// Get summaries for all usage types
  static Future<Map<UsageType, UsageSummary>> getAllSummaries() async {
    final summaries = <UsageType, UsageSummary>{};
    
    for (final type in UsageType.values) {
      summaries[type] = await getSummary(type);
    }
    
    return summaries;
  }
  
  // ============================================
  // Convenience methods for specific types
  // ============================================
  
  /// Track an Eyes scan
  static Future<int> trackEyesScan() => increment(UsageType.eyesScans);
  
  /// Track an Eyes search
  static Future<int> trackEyesSearch() => increment(UsageType.eyesSearches);
  
  /// Track a deal creation
  static Future<int> trackDealCreated() => increment(UsageType.dealsCreated);
  
  /// Track a follow-up copy
  static Future<int> trackFollowupCopy() => increment(UsageType.followupCopies);
  
  /// Track an export attempt
  static Future<int> trackExportAttempt() => increment(UsageType.exportsAttempted);
  
  /// Track a cloud boost attempt
  static Future<int> trackCloudBoostAttempt() => increment(UsageType.cloudBoostAttempted);
  
  /// Track a GUL translation
  static Future<int> trackGulTranslation() => increment(UsageType.gulTranslations);
  
  // ============================================
  // Helper methods
  // ============================================
  
  static String _getTodayKey() {
    return _getDateKey(DateTime.now());
  }
  
  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  static DateTime? _parseDate(String key) {
    try {
      final parts = key.split('-');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }
  
  static Map<String, int> _loadData(SharedPreferences prefs, String key) {
    final json = prefs.getString(key);
    if (json == null) return {};
    
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (e) {
      return {};
    }
  }
  
  static void _logAuditEvent(String event, Map<String, dynamic> data) {
    // TODO: Integrate with analytics in future
    print('[UsageMeterService] $event: $data');
  }
  
  // ============================================
  // Testing helpers
  // ============================================
  
  /// Clear all usage data (for testing)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (final type in UsageType.values) {
      final key = '${_storagePrefix}${type.storageKey}';
      await prefs.remove(key);
    }
    
    _cache.clear();
  }
  
  /// Set count for a specific date (for testing)
  static Future<void> setCountForDate(
    UsageType type, 
    DateTime date, 
    int count,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = '${_storagePrefix}${type.storageKey}';
    
    final data = _loadData(prefs, storageKey);
    data[_getDateKey(date)] = count;
    
    await prefs.setString(storageKey, jsonEncode(data));
    _cache[type.storageKey] = data;
  }
}
