import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/context_pack.dart';
import '../context_packs.dart';

/// Context Service
/// Gate LOC-1: Context Packs + Mode Selector
///
/// Manages context pack selection, persistence, and auto-suggestion.
/// Offline-first, no GPS, uses only timezone/locale for suggestions.

class ContextService {
  static const String _selectedPackKey = 'context_selected_pack_id';
  static const String _suggestionDismissedKey = 'context_suggestion_dismissed';
  static const String _suggestionShownKey = 'context_suggestion_shown';
  
  // Cache
  static ContextPack? _cachedPack;
  
  // ============================================
  // Pack Selection
  // ============================================
  
  /// Get the currently selected context pack
  static Future<ContextPack> getSelectedPack() async {
    if (_cachedPack != null) {
      return _cachedPack!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final packId = prefs.getString(_selectedPackKey);
    
    if (packId != null) {
      final pack = ContextPacks.getById(packId);
      if (pack != null) {
        _cachedPack = pack;
        return pack;
      }
    }
    
    // Return default pack
    _cachedPack = ContextPacks.defaultPack;
    return ContextPacks.defaultPack;
  }
  
  /// Set the selected context pack
  static Future<void> setSelectedPack(ContextPack pack) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPackKey, pack.id);
    _cachedPack = pack;
    
    // Log the selection
    print('[ContextService] pack_selected: ${pack.id}');
  }
  
  /// Clear cache (for testing)
  static void clearCache() {
    _cachedPack = null;
  }
  
  // ============================================
  // Auto-Suggestion (Non-Creepy)
  // ============================================
  
  /// Check if we should show the suggestion modal
  static Future<bool> shouldShowSuggestion() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Already dismissed?
    if (prefs.getBool(_suggestionDismissedKey) == true) {
      return false;
    }
    
    // Already shown once?
    if (prefs.getBool(_suggestionShownKey) == true) {
      return false;
    }
    
    return true;
  }
  
  /// Mark suggestion as shown
  static Future<void> markSuggestionShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_suggestionShownKey, true);
  }
  
  /// Mark suggestion as dismissed
  static Future<void> dismissSuggestion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_suggestionDismissedKey, true);
  }
  
  /// Get suggested pack based on timezone/locale (no GPS!)
  static ContextPack getSuggestedPack() {
    // Check timezone
    final timezone = _getTimezone();
    final locale = _getLocale();
    
    // China indicators
    if (_isChinaTimezone(timezone) || _isChinaLocale(locale)) {
      return ContextPacks.guangzhouCantonFair;
    }
    
    // USA indicators
    if (_isUSATimezone(timezone) || _isUSALocale(locale)) {
      return ContextPacks.usa;
    }
    
    // Egypt indicators
    if (_isEgyptTimezone(timezone) || _isEgyptLocale(locale)) {
      return ContextPacks.egypt;
    }
    
    // Default
    return ContextPacks.travelDefault;
  }
  
  // ============================================
  // Timezone/Locale Detection (No GPS!)
  // ============================================
  
  static String _getTimezone() {
    try {
      return DateTime.now().timeZoneName;
    } catch (_) {
      return '';
    }
  }
  
  static String _getLocale() {
    try {
      return Platform.localeName;
    } catch (_) {
      return '';
    }
  }
  
  static bool _isChinaTimezone(String tz) {
    // China Standard Time indicators
    final chinaIndicators = [
      'CST', // China Standard Time (ambiguous but common)
      'Asia/Shanghai',
      'Asia/Hong_Kong',
      'Asia/Chongqing',
      'GMT+8',
      '+08',
    ];
    
    return chinaIndicators.any((indicator) => 
      tz.toUpperCase().contains(indicator.toUpperCase())
    );
  }
  
  static bool _isChinaLocale(String locale) {
    final chinaIndicators = ['zh', 'CN', 'Hans', 'Hant', 'HK', 'TW'];
    return chinaIndicators.any((indicator) => 
      locale.contains(indicator)
    );
  }
  
  static bool _isUSATimezone(String tz) {
    final usaIndicators = [
      'EST', 'EDT', 'CST', 'CDT', 'MST', 'MDT', 'PST', 'PDT',
      'America/New_York', 'America/Chicago', 'America/Denver',
      'America/Los_Angeles', 'America/Phoenix',
    ];
    
    // Note: CST is ambiguous (China/Central US), so we check locale too
    return usaIndicators.any((indicator) => 
      tz.toUpperCase().contains(indicator.toUpperCase())
    );
  }
  
  static bool _isUSALocale(String locale) {
    return locale.contains('US') || locale.contains('en_US');
  }
  
  static bool _isEgyptTimezone(String tz) {
    final egyptIndicators = [
      'EET', // Eastern European Time
      'Africa/Cairo',
      'GMT+2',
      '+02',
    ];
    
    return egyptIndicators.any((indicator) => 
      tz.toUpperCase().contains(indicator.toUpperCase())
    );
  }
  
  static bool _isEgyptLocale(String locale) {
    return locale.contains('EG') || locale.contains('ar_EG');
  }
  
  // ============================================
  // Pack Impacts
  // ============================================
  
  /// Get the default language pair for the current pack
  static Future<LanguagePair> getDefaultLanguagePair() async {
    final pack = await getSelectedPack();
    return pack.defaultLangPair;
  }
  
  /// Check if loud mode should be enabled by default
  static Future<bool> shouldEnableLoudMode() async {
    final pack = await getSelectedPack();
    return pack.loudModeDefault;
  }
  
  /// Get ordered quick packs for the current context
  static Future<List<QuickPack>> getQuickPacks() async {
    final pack = await getSelectedPack();
    return pack.quickPacks;
  }
  
  /// Get primary shortcuts for the current context
  static Future<List<PrimaryShortcut>> getPrimaryShortcuts() async {
    final pack = await getSelectedPack();
    return pack.primaryShortcuts;
  }
  
  // ============================================
  // Testing Helpers
  // ============================================
  
  /// Reset all context settings (for testing)
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedPackKey);
    await prefs.remove(_suggestionDismissedKey);
    await prefs.remove(_suggestionShownKey);
    _cachedPack = null;
  }
}
