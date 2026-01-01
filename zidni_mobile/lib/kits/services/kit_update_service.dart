/// Kit Update Service
/// Gate LOC-3: Offline Kits + Safe Optional Updates
///
/// Checks for remote kit updates and safely caches them.
/// If anything fails, local kits are preserved.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offline_kit.dart';
import 'kit_service.dart';

/// Update check result
class KitUpdateResult {
  final bool success;
  final int newKitsCount;
  final int updatedKitsCount;
  final String? errorMessage;
  
  const KitUpdateResult({
    required this.success,
    this.newKitsCount = 0,
    this.updatedKitsCount = 0,
    this.errorMessage,
  });
  
  factory KitUpdateResult.success({int newKits = 0, int updatedKits = 0}) {
    return KitUpdateResult(
      success: true,
      newKitsCount: newKits,
      updatedKitsCount: updatedKits,
    );
  }
  
  factory KitUpdateResult.failure(String error) {
    return KitUpdateResult(
      success: false,
      errorMessage: error,
    );
  }
  
  bool get hasUpdates => newKitsCount > 0 || updatedKitsCount > 0;
}

class KitUpdateService {
  // Placeholder URL constant - replace with actual URL when backend is ready
  static const String _remoteKitsUrl = 'https://api.zidni.app/v1/kits.json';
  
  // Keys for tracking update state
  static const String _lastUpdateCheckKey = 'kits_last_update_check';
  static const String _updateAvailableKey = 'kits_update_available';
  
  // ============================================
  // Update Checking
  // ============================================
  
  /// Check for kit updates from remote
  /// Returns result with success/failure and counts
  /// SAFE: If anything fails, local kits are preserved
  static Future<KitUpdateResult> checkForUpdates() async {
    try {
      print('[KitUpdateService] Checking for updates...');
      
      // Fetch remote kits JSON
      final response = await http.get(
        Uri.parse(_remoteKitsUrl),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        print('[KitUpdateService] HTTP error: ${response.statusCode}');
        return KitUpdateResult.failure('HTTP error: ${response.statusCode}');
      }
      
      // Parse JSON
      final List<OfflineKit> remoteKits;
      try {
        remoteKits = _parseKitsJson(response.body);
      } catch (e) {
        print('[KitUpdateService] JSON parse error: $e');
        return KitUpdateResult.failure('Invalid JSON format');
      }
      
      // Validate kits
      if (!_validateKits(remoteKits)) {
        print('[KitUpdateService] Validation failed');
        return KitUpdateResult.failure('Invalid kit data');
      }
      
      // Compare with local kits
      final localKits = await KitService.getAllKits();
      int newCount = 0;
      int updatedCount = 0;
      
      for (final remote in remoteKits) {
        final local = localKits.where((k) => k.id == remote.id).firstOrNull;
        if (local == null) {
          newCount++;
        } else if (remote.version > local.version) {
          updatedCount++;
        }
      }
      
      // Cache remote kits if there are updates
      if (newCount > 0 || updatedCount > 0) {
        await KitService.cacheRemoteKits(remoteKits);
        await _setUpdateAvailable(true);
      } else {
        await _setUpdateAvailable(false);
      }
      
      // Record last check time
      await _setLastUpdateCheck(DateTime.now());
      
      print('[KitUpdateService] Update check complete: $newCount new, $updatedCount updated');
      return KitUpdateResult.success(newKits: newCount, updatedKits: updatedCount);
      
    } catch (e) {
      print('[KitUpdateService] Update check failed: $e');
      // SAFE: Local kits are preserved, just return failure
      return KitUpdateResult.failure(e.toString());
    }
  }
  
  /// Parse kits from JSON string
  static List<OfflineKit> _parseKitsJson(String jsonString) {
    final dynamic data = jsonDecode(jsonString);
    
    // Support both array and object with 'kits' key
    List<dynamic> kitsList;
    if (data is List) {
      kitsList = data;
    } else if (data is Map && data.containsKey('kits')) {
      kitsList = data['kits'] as List;
    } else {
      throw const FormatException('Invalid kits JSON structure');
    }
    
    return kitsList.map((j) => OfflineKit.fromJson(j)).toList();
  }
  
  /// Validate kit data
  static bool _validateKits(List<OfflineKit> kits) {
    for (final kit in kits) {
      // Basic validation
      if (kit.id.isEmpty) return false;
      if (kit.version < 1) return false;
      if (kit.titleAr.isEmpty && kit.titleEn.isEmpty) return false;
    }
    return true;
  }
  
  // ============================================
  // Update State
  // ============================================
  
  /// Check if an update is available (cached flag)
  static Future<bool> isUpdateAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_updateAvailableKey) ?? false;
  }
  
  /// Set update available flag
  static Future<void> _setUpdateAvailable(bool available) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_updateAvailableKey, available);
  }
  
  /// Clear update available flag (after user views updates)
  static Future<void> clearUpdateFlag() async {
    await _setUpdateAvailable(false);
  }
  
  /// Get last update check time
  static Future<DateTime?> getLastUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastUpdateCheckKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }
  
  /// Set last update check time
  static Future<void> _setLastUpdateCheck(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateCheckKey, time.toIso8601String());
  }
  
  /// Check if we should auto-check for updates (once per day)
  static Future<bool> shouldAutoCheck() async {
    final lastCheck = await getLastUpdateCheck();
    if (lastCheck == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastCheck);
    return difference.inHours >= 24;
  }
}
