import 'package:shared_preferences/shared_preferences.dart';

/// Service to persist and retrieve the last used folder ID.
/// Uses SharedPreferences for local storage.
class LastFolderService {
  static const String _lastFolderIdKey = 'last_folder_id';
  static const String _lastFolderNameKey = 'last_folder_name';

  /// Save the last used folder ID and name
  static Future<void> setLastFolder(String folderId, String folderName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFolderIdKey, folderId);
    await prefs.setString(_lastFolderNameKey, folderName);
  }

  /// Get the last used folder ID (returns null if not set)
  static Future<String?> getLastFolderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastFolderIdKey);
  }

  /// Get the last used folder name (returns null if not set)
  static Future<String?> getLastFolderName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastFolderNameKey);
  }

  /// Clear the last folder (e.g., when folder is deleted)
  static Future<void> clearLastFolder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastFolderIdKey);
    await prefs.remove(_lastFolderNameKey);
  }
}
