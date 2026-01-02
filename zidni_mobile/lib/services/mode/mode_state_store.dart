import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_mode.dart';

/// Persistent storage for mode-related settings.
/// 
/// This store persists:
/// - autoModeEnabled: Whether automatic mode switching is enabled
/// - currentMode: The currently active app mode
/// - lastCountryCode: The last detected country code
/// - lastPromptedAt: When the user was last prompted for mode switch
/// - dontAskAgain: Whether user has opted out of mode suggestions
class ModeStateStore {
  ModeStateStore._();
  static final ModeStateStore instance = ModeStateStore._();

  static const String _keyAutoModeEnabled = 'mode_auto_enabled';
  static const String _keyCurrentMode = 'mode_current';
  static const String _keyLastCountryCode = 'mode_last_country';
  static const String _keyLastPromptedAt = 'mode_last_prompted';
  static const String _keyDontAskAgain = 'mode_dont_ask';

  SharedPreferences? _prefs;

  /// Initialize the store
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if auto mode switching is enabled
  bool get autoModeEnabled {
    return _prefs?.getBool(_keyAutoModeEnabled) ?? true;
  }

  /// Set auto mode switching enabled/disabled
  Future<void> setAutoModeEnabled(bool enabled) async {
    await _prefs?.setBool(_keyAutoModeEnabled, enabled);
  }

  /// Get the current app mode
  AppMode get currentMode {
    final modeId = _prefs?.getString(_keyCurrentMode);
    if (modeId == null) return AppMode.travel;
    return AppMode.fromId(modeId);
  }

  /// Set the current app mode
  Future<void> setCurrentMode(AppMode mode) async {
    await _prefs?.setString(_keyCurrentMode, mode.id);
  }

  /// Get the last detected country code
  String? get lastCountryCode {
    return _prefs?.getString(_keyLastCountryCode);
  }

  /// Set the last detected country code
  Future<void> setLastCountryCode(String countryCode) async {
    await _prefs?.setString(_keyLastCountryCode, countryCode);
  }

  /// Get when user was last prompted for mode switch
  DateTime? get lastPromptedAt {
    final timestamp = _prefs?.getString(_keyLastPromptedAt);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  /// Set when user was last prompted
  Future<void> setLastPromptedAt(DateTime timestamp) async {
    await _prefs?.setString(_keyLastPromptedAt, timestamp.toIso8601String());
  }

  /// Check if user has opted out of mode suggestions
  bool get dontAskAgain {
    return _prefs?.getBool(_keyDontAskAgain) ?? false;
  }

  /// Set don't ask again preference
  Future<void> setDontAskAgain(bool value) async {
    await _prefs?.setBool(_keyDontAskAgain, value);
  }

  /// Check if enough time has passed since last prompt (cooldown period)
  bool canPromptAgain({Duration cooldown = const Duration(hours: 24)}) {
    if (dontAskAgain) return false;
    
    final lastPrompted = lastPromptedAt;
    if (lastPrompted == null) return true;
    
    return DateTime.now().difference(lastPrompted) > cooldown;
  }

  /// Check if country has changed since last detection
  bool hasCountryChanged(String newCountryCode) {
    final lastCode = lastCountryCode;
    if (lastCode == null) return true;
    return lastCode.toUpperCase() != newCountryCode.toUpperCase();
  }

  /// Reset all mode settings to defaults
  Future<void> reset() async {
    await _prefs?.remove(_keyAutoModeEnabled);
    await _prefs?.remove(_keyCurrentMode);
    await _prefs?.remove(_keyLastCountryCode);
    await _prefs?.remove(_keyLastPromptedAt);
    await _prefs?.remove(_keyDontAskAgain);
  }

  /// Export current state as JSON (for debugging/logging)
  Map<String, dynamic> toJson() {
    return {
      'autoModeEnabled': autoModeEnabled,
      'currentMode': currentMode.id,
      'lastCountryCode': lastCountryCode,
      'lastPromptedAt': lastPromptedAt?.toIso8601String(),
      'dontAskAgain': dontAskAgain,
    };
  }
}
