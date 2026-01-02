import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/app_mode.dart';
import '../../models/location_context.dart';
import '../location/location_service.dart';
import 'mode_rules.dart';
import 'mode_state_store.dart';

/// Coordinates mode detection, suggestion, and switching.
/// 
/// This service orchestrates the flow:
/// 1. Check location permission
/// 2. Get country from GPS or fallback
/// 3. Determine suggested mode
/// 4. Show suggestion if appropriate (respects cooldown, don't ask again)
/// 5. Apply mode change if user accepts
class ModeCoordinator {
  ModeCoordinator._();
  static final ModeCoordinator instance = ModeCoordinator._();

  final LocationService _locationService = LocationService.instance;
  final ModeStateStore _stateStore = ModeStateStore.instance;

  /// Stream controller for mode suggestion events
  final _suggestionController = StreamController<ModeSuggestion>.broadcast();
  Stream<ModeSuggestion> get suggestionStream => _suggestionController.stream;

  /// Stream controller for mode change events
  final _modeChangeController = StreamController<AppMode>.broadcast();
  Stream<AppMode> get modeChangeStream => _modeChangeController.stream;

  /// Initialize the coordinator
  Future<void> init() async {
    await _stateStore.init();
  }

  /// Maybe suggest a mode change based on current location.
  /// 
  /// This method:
  /// 1. Checks if auto mode is enabled
  /// 2. Checks if we can prompt (cooldown, don't ask again)
  /// 3. Gets current location
  /// 4. Determines if mode suggestion is appropriate
  /// 5. Emits suggestion event if needed
  Future<ModeSuggestion?> maybeSuggestMode() async {
    // Check if auto mode is enabled
    if (!_stateStore.autoModeEnabled) {
      debugPrint('ModeCoordinator: Auto mode disabled, skipping suggestion');
      return null;
    }

    // Check if we can prompt
    if (!_stateStore.canPromptAgain()) {
      debugPrint('ModeCoordinator: Cooldown active or dont ask again, skipping');
      return null;
    }

    // Get location
    final context = await _locationService.getLastKnownCountry();
    if (context == null) {
      debugPrint('ModeCoordinator: No location available');
      return null;
    }

    // Check if country changed
    final countryChanged = _stateStore.hasCountryChanged(context.countryCode);
    if (!countryChanged) {
      debugPrint('ModeCoordinator: Country unchanged, skipping suggestion');
      return null;
    }

    // Get suggested mode
    final suggestedMode = ModeRules.getSuggestedMode(context.countryCode);
    final currentMode = _stateStore.currentMode;

    // Skip if already in suggested mode
    if (suggestedMode == currentMode) {
      debugPrint('ModeCoordinator: Already in suggested mode');
      await _stateStore.setLastCountryCode(context.countryCode);
      return null;
    }

    // Create and emit suggestion
    final suggestion = ModeSuggestion(
      currentMode: currentMode,
      suggestedMode: suggestedMode,
      countryCode: context.countryCode,
      countryName: context.countryName,
      reason: ModeRules.getSuggestionReason(context.countryCode),
      reasonEnglish: ModeRules.getSuggestionReason(context.countryCode, arabic: false),
    );

    _suggestionController.add(suggestion);
    return suggestion;
  }

  /// Accept mode suggestion and switch to new mode
  Future<void> acceptSuggestion(ModeSuggestion suggestion) async {
    await _stateStore.setCurrentMode(suggestion.suggestedMode);
    await _stateStore.setLastCountryCode(suggestion.countryCode);
    await _stateStore.setLastPromptedAt(DateTime.now());
    
    _modeChangeController.add(suggestion.suggestedMode);
    
    _logAction('accepted', suggestion);
  }

  /// Decline mode suggestion (not now)
  Future<void> declineSuggestion(ModeSuggestion suggestion) async {
    await _stateStore.setLastPromptedAt(DateTime.now());
    
    _logAction('declined', suggestion);
  }

  /// Decline mode suggestion permanently (don't ask again)
  Future<void> declinePermanently(ModeSuggestion suggestion) async {
    await _stateStore.setDontAskAgain(true);
    await _stateStore.setLastPromptedAt(DateTime.now());
    
    _logAction('declined_permanently', suggestion);
  }

  /// Manually set app mode (from settings)
  Future<void> setMode(AppMode mode) async {
    await _stateStore.setCurrentMode(mode);
    _modeChangeController.add(mode);
    
    debugPrint('ModeCoordinator: Mode manually set to ${mode.id}');
  }

  /// Get current app mode
  AppMode get currentMode => _stateStore.currentMode;

  /// Log action for telemetry (local only)
  void _logAction(String action, ModeSuggestion suggestion) {
    debugPrint('ModeCoordinator: $action - '
        'from=${suggestion.currentMode.id}, '
        'to=${suggestion.suggestedMode.id}, '
        'country=${suggestion.countryCode}');
  }

  /// Dispose resources
  void dispose() {
    _suggestionController.close();
    _modeChangeController.close();
  }
}

/// Represents a mode suggestion to be shown to the user
class ModeSuggestion {
  /// Current app mode
  final AppMode currentMode;
  
  /// Suggested new mode
  final AppMode suggestedMode;
  
  /// Detected country code
  final String countryCode;
  
  /// Optional country name
  final String? countryName;
  
  /// Arabic reason/message for suggestion
  final String reason;
  
  /// English reason/message for suggestion
  final String reasonEnglish;

  const ModeSuggestion({
    required this.currentMode,
    required this.suggestedMode,
    required this.countryCode,
    this.countryName,
    required this.reason,
    required this.reasonEnglish,
  });

  /// Get localized reason
  String getLocalizedReason(String locale) {
    return locale.startsWith('ar') ? reason : reasonEnglish;
  }
}
