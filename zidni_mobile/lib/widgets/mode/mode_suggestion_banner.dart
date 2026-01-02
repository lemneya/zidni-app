import 'package:flutter/material.dart';
import '../../models/app_mode.dart';
import '../../services/mode/mode_coordinator.dart';

/// A banner widget that suggests mode changes based on detected location.
/// 
/// This widget displays a non-intrusive banner at the top of the screen
/// when a mode change is suggested. It provides three options:
/// - Switch: Accept the suggestion and change mode
/// - Not now: Dismiss for now (will ask again after cooldown)
/// - Don't ask again: Permanently dismiss suggestions
class ModeSuggestionBanner extends StatefulWidget {
  /// Callback when mode is changed
  final VoidCallback? onModeChanged;

  const ModeSuggestionBanner({
    super.key,
    this.onModeChanged,
  });

  @override
  State<ModeSuggestionBanner> createState() => _ModeSuggestionBannerState();
}

class _ModeSuggestionBannerState extends State<ModeSuggestionBanner> {
  ModeSuggestion? _currentSuggestion;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _listenToSuggestions();
  }

  void _listenToSuggestions() {
    ModeCoordinator.instance.suggestionStream.listen((suggestion) {
      if (mounted) {
        setState(() {
          _currentSuggestion = suggestion;
          _isVisible = true;
        });
      }
    });
  }

  void _onSwitch() async {
    if (_currentSuggestion == null) return;
    
    await ModeCoordinator.instance.acceptSuggestion(_currentSuggestion!);
    _dismiss();
    widget.onModeChanged?.call();
  }

  void _onNotNow() async {
    if (_currentSuggestion == null) return;
    
    await ModeCoordinator.instance.declineSuggestion(_currentSuggestion!);
    _dismiss();
  }

  void _onDontAskAgain() async {
    if (_currentSuggestion == null) return;
    
    await ModeCoordinator.instance.declinePermanently(_currentSuggestion!);
    _dismiss();
  }

  void _dismiss() {
    setState(() {
      _isVisible = false;
      _currentSuggestion = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _currentSuggestion == null) {
      return const SizedBox.shrink();
    }

    final suggestion = _currentSuggestion!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getModeColor(suggestion.suggestedMode).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getModeColor(suggestion.suggestedMode).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and message
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _getModeIcon(suggestion.suggestedMode),
                    color: _getModeColor(suggestion.suggestedMode),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion.getLocalizedReason(
                        Localizations.localeOf(context).languageCode,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Switch button (primary)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSwitch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getModeColor(suggestion.suggestedMode),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isArabic ? 'تبديل' : 'Switch'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Not now button
                  TextButton(
                    onPressed: _onNotNow,
                    child: Text(isArabic ? 'ليس الآن' : 'Not now'),
                  ),
                  
                  // Don't ask again button
                  TextButton(
                    onPressed: _onDontAskAgain,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: Text(
                      isArabic ? 'لا تسأل مجدداً' : "Don't ask again",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModeColor(AppMode mode) {
    switch (mode) {
      case AppMode.immigration:
        return Colors.blue;
      case AppMode.cantonFair:
        return Colors.orange;
      case AppMode.home:
        return Colors.green;
      case AppMode.travel:
        return Colors.purple;
    }
  }

  IconData _getModeIcon(AppMode mode) {
    switch (mode) {
      case AppMode.immigration:
        return Icons.assignment_ind;
      case AppMode.cantonFair:
        return Icons.store;
      case AppMode.home:
        return Icons.home;
      case AppMode.travel:
        return Icons.flight;
    }
  }
}
