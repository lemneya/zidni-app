/// Voice Command Router - Routes voice commands to OS-level actions
/// Gate OS-1: GUL↔Eyes Bridge
///
/// This service runs at the UI/router level, NOT in locked STT files.
/// It intercepts transcripts and detects command phrases to trigger actions.

/// Supported voice commands for Eyes launch
class VoiceCommand {
  static const eyesScanPhrases = [
    // Arabic
    'امسح هذا',
    'صور هذا',
    'امسح',
    'صور',
    'افتح الكاميرا',
    'افتح العين',
    'مسح',
    // English
    'scan this',
    'scan',
    'take a photo',
    'open camera',
    'open eyes',
    // Chinese
    '扫描',
    '扫一扫',
    '拍照',
    '打开相机',
  ];

  /// Check if text contains an Eyes scan command
  static bool isEyesScanCommand(String text) {
    final normalized = text.toLowerCase().trim();
    
    for (final phrase in eyesScanPhrases) {
      if (normalized.contains(phrase.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}

/// Result of voice command detection
enum VoiceCommandType {
  none,
  openEyes,
}

/// Voice command detection result
class VoiceCommandResult {
  final VoiceCommandType type;
  final String? matchedPhrase;
  final String originalText;

  const VoiceCommandResult({
    required this.type,
    this.matchedPhrase,
    required this.originalText,
  });

  bool get isCommand => type != VoiceCommandType.none;

  static const none = VoiceCommandResult(
    type: VoiceCommandType.none,
    originalText: '',
  );
}

/// Service to detect and route voice commands
class VoiceCommandRouter {
  /// Detect if the transcript contains a voice command
  /// Returns the command type and matched phrase if found
  static VoiceCommandResult detectCommand(String transcript) {
    if (transcript.isEmpty) {
      return VoiceCommandResult.none;
    }

    final normalized = transcript.toLowerCase().trim();

    // Check for Eyes scan command
    for (final phrase in VoiceCommand.eyesScanPhrases) {
      if (normalized.contains(phrase.toLowerCase())) {
        return VoiceCommandResult(
          type: VoiceCommandType.openEyes,
          matchedPhrase: phrase,
          originalText: transcript,
        );
      }
    }

    return VoiceCommandResult(
      type: VoiceCommandType.none,
      originalText: transcript,
    );
  }

  /// Check if transcript is ONLY a command (not mixed with other content)
  /// This helps decide whether to consume the transcript or pass it through
  static bool isPureCommand(String transcript) {
    final normalized = transcript.toLowerCase().trim();
    
    // Check if the entire transcript is just a command phrase
    for (final phrase in VoiceCommand.eyesScanPhrases) {
      if (normalized == phrase.toLowerCase()) {
        return true;
      }
    }
    
    // Also check for very short transcripts that are mostly command
    if (normalized.length < 20) {
      final result = detectCommand(transcript);
      if (result.isCommand && result.matchedPhrase != null) {
        // If the matched phrase is most of the transcript, it's a pure command
        final ratio = result.matchedPhrase!.length / normalized.length;
        return ratio > 0.7;
      }
    }
    
    return false;
  }
}
