import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/screens/conversation/conversation_mode_screen.dart';

/// Service for storing Conversation Mode preferences
/// 
/// Manages:
/// - useLocationDefault: Auto-select target based on country
/// - loudMode: High volume TTS for noisy environments
/// - lastSelectedTarget: Remember last used target language
/// - lastCountryApplied: Prevent flip-flops on country changes
class ConversationPrefsService {
  static const String _keyUseLocationDefault = 'conv_use_location_default';
  static const String _keyLoudMode = 'conv_loud_mode';
  static const String _keyLastSelectedTarget = 'conv_last_selected_target';
  static const String _keyLastCountryApplied = 'conv_last_country_applied';
  
  SharedPreferences? _prefs;
  
  /// Initialize the service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Whether to auto-select target based on location
  bool get useLocationDefault {
    return _prefs?.getBool(_keyUseLocationDefault) ?? false;
  }
  
  Future<void> setUseLocationDefault(bool value) async {
    await _prefs?.setBool(_keyUseLocationDefault, value);
  }
  
  /// Whether loud mode is enabled for TTS
  bool get loudMode {
    return _prefs?.getBool(_keyLoudMode) ?? false;
  }
  
  Future<void> setLoudMode(bool value) async {
    await _prefs?.setBool(_keyLoudMode, value);
  }
  
  /// Last selected target language
  TargetLang get lastSelectedTarget {
    final code = _prefs?.getString(_keyLastSelectedTarget);
    if (code == null) return TargetLang.zh;
    return TargetLang.values.firstWhere(
      (t) => t.code == code,
      orElse: () => TargetLang.zh,
    );
  }
  
  Future<void> setLastSelectedTarget(TargetLang target) async {
    await _prefs?.setString(_keyLastSelectedTarget, target.code);
  }
  
  /// Last country code that triggered auto-selection
  String? get lastCountryApplied {
    return _prefs?.getString(_keyLastCountryApplied);
  }
  
  Future<void> setLastCountryApplied(String? countryCode) async {
    if (countryCode == null) {
      await _prefs?.remove(_keyLastCountryApplied);
    } else {
      await _prefs?.setString(_keyLastCountryApplied, countryCode);
    }
  }
}
