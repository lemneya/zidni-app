import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/os/models/unified_history_item.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';
import 'package:zidni_mobile/eyes/models/deal_record.dart';

/// Unified History Service
/// Gate OS-1: GUL↔Eyes Bridge + Unified History
///
/// Aggregates history from all sources:
/// - Eyes scans (eyes_scan_saved)
/// - Eyes searches (eyes_search_saved)
/// - Deals (deal_created_from_eyes)
/// - GUL translations (gul_capture_saved)

class UnifiedHistoryService {
  static const String _historyKey = 'unified_history';
  static const int _maxItems = 500;

  /// Get all history items, sorted by date (newest first)
  static Future<List<UnifiedHistoryItem>> getAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final items = jsonList
          .map((json) => UnifiedHistoryItem.fromJson(json))
          .toList();
      
      // Sort by date, newest first
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (e) {
      return [];
    }
  }

  /// Get history items filtered by type
  static Future<List<UnifiedHistoryItem>> getHistoryByType(
    HistoryItemType type,
  ) async {
    final all = await getAllHistory();
    return all.where((item) => item.type == type).toList();
  }

  /// Get history items filtered by multiple types
  static Future<List<UnifiedHistoryItem>> getHistoryByTypes(
    List<HistoryItemType> types,
  ) async {
    final all = await getAllHistory();
    return all.where((item) => types.contains(item.type)).toList();
  }

  /// Search history items by query
  static Future<List<UnifiedHistoryItem>> searchHistory(String query) async {
    if (query.isEmpty) {
      return getAllHistory();
    }

    final all = await getAllHistory();
    final normalized = query.toLowerCase();

    return all.where((item) {
      return item.title.toLowerCase().contains(normalized) ||
          (item.subtitle?.toLowerCase().contains(normalized) ?? false) ||
          (item.preview?.toLowerCase().contains(normalized) ?? false);
    }).toList();
  }

  /// Add an item to history
  static Future<void> addItem(UnifiedHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAllHistory();

    // Add new item at the beginning
    items.insert(0, item);

    // Trim to max size
    if (items.length > _maxItems) {
      items.removeRange(_maxItems, items.length);
    }

    await _saveItems(prefs, items);
  }

  /// Add an Eyes scan to history
  static Future<void> addEyesScan(EyesScanResult scan) async {
    final item = UnifiedHistoryItem.fromEyesScan(
      id: scan.id ?? 'scan_${DateTime.now().millisecondsSinceEpoch}',
      productName: scan.productNameGuess ?? '',
      rawText: scan.rawText,
      createdAt: scan.scannedAt,
      imagePath: scan.imagePath,
      extractedFields: scan.extractedFields,
    );
    await addItem(item);
  }

  /// Add an Eyes search to history
  static Future<void> addEyesSearch(SearchQuery search) async {
    final item = UnifiedHistoryItem.fromEyesSearch(
      id: 'search_${DateTime.now().millisecondsSinceEpoch}',
      query: search.fullQuery,
      platform: search.platform,
      createdAt: search.createdAt,
      contextChips: search.contextChips,
    );
    await addItem(item);
  }

  /// Add a Deal to history
  static Future<void> addDeal(DealRecord deal) async {
    final item = UnifiedHistoryItem.fromDeal(
      id: deal.id,
      productName: deal.displayName,
      platform: deal.selectedPlatform,
      createdAt: deal.createdAt,
      status: deal.status.arabicName,
      contextChips: deal.contextChips,
    );
    await addItem(item);
  }

  /// Add a GUL translation to history
  static Future<void> addTranslation({
    required String transcript,
    required String translation,
    required String fromLang,
    required String toLang,
  }) async {
    final item = UnifiedHistoryItem.fromTranslation(
      id: 'translation_${DateTime.now().millisecondsSinceEpoch}',
      transcript: transcript,
      translation: translation,
      fromLang: fromLang,
      toLang: toLang,
      createdAt: DateTime.now(),
    );
    await addItem(item);
  }

  /// Get item by ID
  static Future<UnifiedHistoryItem?> getItemById(String id) async {
    final items = await getAllHistory();
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete an item from history
  static Future<void> deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAllHistory();
    items.removeWhere((item) => item.id == id);
    await _saveItems(prefs, items);
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Get history count
  static Future<int> getHistoryCount() async {
    final items = await getAllHistory();
    return items.length;
  }

  /// Get history count by type
  static Future<Map<HistoryItemType, int>> getHistoryCountByType() async {
    final items = await getAllHistory();
    final counts = <HistoryItemType, int>{};
    
    for (final type in HistoryItemType.values) {
      counts[type] = items.where((item) => item.type == type).length;
    }
    
    return counts;
  }

  /// Save items to SharedPreferences
  static Future<void> _saveItems(
    SharedPreferences prefs,
    List<UnifiedHistoryItem> items,
  ) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }
}
