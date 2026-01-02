import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service
///
/// Provides encrypted storage for sensitive data using flutter_secure_storage.
/// Uses AES-256 encryption on iOS/Android.
///
/// Use this for:
/// - User credentials and tokens
/// - Subscription/entitlement data (to prevent tampering)
/// - Offline companion URLs
/// - API keys
/// - Any PII (personally identifiable information)
///
/// For non-sensitive data, use SharedPreferences instead for better performance.
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Write a string value securely
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a string value securely
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all values (use with caution)
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Read all keys
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
