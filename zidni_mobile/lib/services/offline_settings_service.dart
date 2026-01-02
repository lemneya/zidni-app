import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/core/secure_storage_service.dart';

/// Service to manage offline mode settings
///
/// SECURITY NOTES:
/// - Companion URL stored in SecureStorage to prevent tampering
/// - Default URL uses HTTPS (requires TLS setup on companion server)
/// - Offline mode flag uses SharedPreferences (non-sensitive)
class OfflineSettingsService {
  static const String _offlineModeKey = 'offline_mode_enabled';
  static const String _companionUrlKey = 'local_companion_url';

  // SECURITY FIX: Changed from http:// to https://
  // Companion server MUST be configured with TLS certificate
  static const String _defaultCompanionUrl = 'https://192.168.4.1:8787';

  static final _secureStorage = SecureStorageService();

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
    final url = await _secureStorage.read(_companionUrlKey);
    return url ?? _defaultCompanionUrl;
  }

  /// Set the local companion URL
  /// Validates that URL uses HTTPS for security
  static Future<void> setCompanionUrl(String url) async {
    // SECURITY: Validate URL uses HTTPS
    if (!url.startsWith('https://') && !url.startsWith('http://localhost')) {
      throw ArgumentError('Companion URL must use HTTPS for security');
    }
    await _secureStorage.write(_companionUrlKey, url);
  }

  /// Get default companion URL
  static String get defaultCompanionUrl => _defaultCompanionUrl;
}
