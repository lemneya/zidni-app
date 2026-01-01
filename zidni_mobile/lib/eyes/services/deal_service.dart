import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/eyes/models/deal_record.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';

/// Service to manage Deal Records using SharedPreferences
/// Gate EYES-3: Create Deal + Follow-up Kit from Eyes
class DealService {
  static const String _dealsKey = 'eyes_deals';
  static const String _auditLogKey = 'eyes_deals_audit_log';
  static const int _maxDeals = 200;

  /// Create a new deal from scan result and search query
  static Future<DealRecord> createDeal({
    required EyesScanResult scanResult,
    required SearchQuery query,
    String? selectedPlatform,
  }) async {
    final deal = DealRecord.fromScanAndQuery(
      scanResult: scanResult,
      query: query,
      selectedPlatform: selectedPlatform,
    );

    await _saveDeal(deal);
    await _logAuditEvent('deal_created_from_eyes', {
      'dealId': deal.id,
      'productName': deal.productName,
      'platform': selectedPlatform,
      'scanResultId': scanResult.id,
    });

    return deal;
  }

  /// Save a deal to storage
  static Future<void> _saveDeal(DealRecord deal) async {
    final prefs = await SharedPreferences.getInstance();
    final deals = await getDeals();

    // Add to beginning of list
    deals.insert(0, deal);

    // Trim to max items
    if (deals.length > _maxDeals) {
      deals.removeRange(_maxDeals, deals.length);
    }

    // Save to SharedPreferences
    final jsonList = deals.map((d) => d.toJson()).toList();
    await prefs.setString(_dealsKey, jsonEncode(jsonList));
  }

  /// Get all deals
  static Future<List<DealRecord>> getDeals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_dealsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => DealRecord.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a deal by ID
  static Future<DealRecord?> getDealById(String id) async {
    final deals = await getDeals();
    return deals.where((d) => d.id == id).firstOrNull;
  }

  /// Get deals count
  static Future<int> getDealsCount() async {
    final deals = await getDeals();
    return deals.length;
  }

  /// Update a deal's status
  static Future<DealRecord?> updateDealStatus(String dealId, DealStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final deals = await getDeals();

    final index = deals.indexWhere((d) => d.id == dealId);
    if (index == -1) return null;

    final updatedDeal = deals[index].copyWith(status: status);
    deals[index] = updatedDeal;

    final jsonList = deals.map((d) => d.toJson()).toList();
    await prefs.setString(_dealsKey, jsonEncode(jsonList));

    await _logAuditEvent('deal_status_updated', {
      'dealId': dealId,
      'newStatus': status.name,
    });

    return updatedDeal;
  }

  /// Delete a deal
  static Future<bool> deleteDeal(String dealId) async {
    final prefs = await SharedPreferences.getInstance();
    final deals = await getDeals();

    final initialLength = deals.length;
    deals.removeWhere((d) => d.id == dealId);

    if (deals.length == initialLength) return false;

    final jsonList = deals.map((d) => d.toJson()).toList();
    await prefs.setString(_dealsKey, jsonEncode(jsonList));

    await _logAuditEvent('deal_deleted', {'dealId': dealId});

    return true;
  }

  /// Clear all deals
  static Future<void> clearDeals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dealsKey);
    await _logAuditEvent('deals_cleared', {});
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
