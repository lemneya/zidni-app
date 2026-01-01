/// Kit Service
/// Gate LOC-3: Offline Kits + Safe Optional Updates
///
/// Manages kit installation, activation, and local storage.
/// Local-first: bundled kits always work offline.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offline_kit.dart';
import '../bundled_kits.dart';
import '../../context/context.dart';

class KitService {
  static const String _activeKitKey = 'kits_active_kit_id';
  static const String _installedKitsKey = 'kits_installed_kits';
  static const String _cachedKitsKey = 'kits_cached_remote_kits';
  
  // Cache
  static OfflineKit? _cachedActiveKit;
  static List<OfflineKit>? _cachedInstalledKits;
  
  // ============================================
  // Kit Loading
  // ============================================
  
  /// Get all available kits (bundled + downloaded)
  static Future<List<OfflineKit>> getAllKits() async {
    final bundled = BundledKits.all;
    final cached = await _getCachedRemoteKits();
    
    // Merge: bundled + cached (cached can update bundled versions)
    final Map<String, OfflineKit> kitsMap = {};
    
    // Add bundled first
    for (final kit in bundled) {
      kitsMap[kit.id] = kit;
    }
    
    // Add/update with cached (higher version wins)
    for (final kit in cached) {
      final existing = kitsMap[kit.id];
      if (existing == null || kit.version > existing.version) {
        kitsMap[kit.id] = kit;
      }
    }
    
    return kitsMap.values.toList();
  }
  
  /// Get installed kits
  static Future<List<OfflineKit>> getInstalledKits() async {
    if (_cachedInstalledKits != null) {
      return _cachedInstalledKits!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final installedIds = prefs.getStringList(_installedKitsKey) ?? [];
    
    // If no installed kits, default to bundled kits
    if (installedIds.isEmpty) {
      _cachedInstalledKits = BundledKits.all;
      return _cachedInstalledKits!;
    }
    
    final allKits = await getAllKits();
    _cachedInstalledKits = allKits.where((kit) => installedIds.contains(kit.id)).toList();
    
    // Ensure bundled kits are always installed
    for (final bundled in BundledKits.all) {
      if (!_cachedInstalledKits!.any((k) => k.id == bundled.id)) {
        _cachedInstalledKits!.add(bundled);
      }
    }
    
    return _cachedInstalledKits!;
  }
  
  // ============================================
  // Active Kit
  // ============================================
  
  /// Get the currently active kit
  static Future<OfflineKit> getActiveKit() async {
    if (_cachedActiveKit != null) {
      return _cachedActiveKit!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_activeKitKey);
    
    if (activeId != null) {
      final allKits = await getAllKits();
      try {
        _cachedActiveKit = allKits.firstWhere((kit) => kit.id == activeId);
        return _cachedActiveKit!;
      } catch (_) {
        // Kit not found, fall back to default
      }
    }
    
    // Default to Canton Fair kit
    _cachedActiveKit = BundledKits.defaultKit;
    return _cachedActiveKit!;
  }
  
  /// Activate a kit
  static Future<void> activateKit(OfflineKit kit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKitKey, kit.id);
    _cachedActiveKit = kit;
    
    // Also set the default context pack
    final pack = ContextPacks.getById(kit.defaultPackId);
    if (pack != null) {
      await ContextService.setSelectedPack(pack);
    }
    
    // Log activation
    print('[KitService] kit_activated: ${kit.id}');
  }
  
  // ============================================
  // Kit Installation
  // ============================================
  
  /// Install a kit (add to installed list)
  static Future<void> installKit(OfflineKit kit) async {
    final prefs = await SharedPreferences.getInstance();
    final installedIds = prefs.getStringList(_installedKitsKey) ?? [];
    
    if (!installedIds.contains(kit.id)) {
      installedIds.add(kit.id);
      await prefs.setStringList(_installedKitsKey, installedIds);
      _cachedInstalledKits = null; // Clear cache
    }
    
    print('[KitService] kit_installed: ${kit.id}');
  }
  
  /// Check if a kit is installed
  static Future<bool> isKitInstalled(String kitId) async {
    final installed = await getInstalledKits();
    return installed.any((kit) => kit.id == kitId);
  }
  
  // ============================================
  // Remote Kit Caching
  // ============================================
  
  /// Cache remote kits locally
  static Future<void> cacheRemoteKits(List<OfflineKit> kits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = kits.map((k) => k.toJson()).toList();
    await prefs.setString(_cachedKitsKey, jsonEncode(jsonList));
    
    print('[KitService] cached_remote_kits: ${kits.length}');
  }
  
  /// Get cached remote kits
  static Future<List<OfflineKit>> _getCachedRemoteKits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cachedKitsKey);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((j) => OfflineKit.fromJson(j)).toList();
    } catch (e) {
      print('[KitService] Error parsing cached kits: $e');
      return [];
    }
  }
  
  // ============================================
  // Utilities
  // ============================================
  
  /// Clear all caches (for testing)
  static void clearCache() {
    _cachedActiveKit = null;
    _cachedInstalledKits = null;
  }
  
  /// Check if an update is available for a kit
  static Future<bool> hasUpdate(String kitId) async {
    final allKits = await getAllKits();
    final bundled = BundledKits.getById(kitId);
    
    if (bundled == null) return false;
    
    try {
      final current = allKits.firstWhere((k) => k.id == kitId);
      return current.version > bundled.version;
    } catch (_) {
      return false;
    }
  }
}
