import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage offline mode settings using SharedPreferences.
class OfflineSettingsService {
  static const String _offlineModeKey = 'offline_mode_enabled';
  static const String _companionUrlKey = 'local_companion_url';
  static const String _defaultCompanionUrl = 'http://192.168.4.1:8787';

  /// Check if offline mode is enabled
  static Future<bool> isOfflineModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineModeKey) ?? false;
  }

  /// Enable or disable offline mode
  static Future<void> setOfflineModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, enabled);
  }

  /// Get the local companion URL
  static Future<String> getCompanionUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companionUrlKey) ?? _defaultCompanionUrl;
  }

  /// Set the local companion URL
  static Future<void> setCompanionUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companionUrlKey, url);
  }

  /// Get default companion URL
  static String get defaultCompanionUrl => _defaultCompanionUrl;
}
