import 'package:flutter/foundation.dart';

/// Which side is speaking in the conversation
enum SpeakerSide { arabic, chinese }

/// Current phase of the conversation turn
enum ConversationPhase {
  idle,       // Waiting for user to start
  recording,  // STT is actively recording
  transcribing, // Processing audio to text
  translating,  // Translating the transcript
  ready,      // Results ready, can speak or save
  speaking,   // TTS is playing
  error,      // Something went wrong
}

/// State controller for turn-taking conversation mode
/// 
/// This controller manages the state machine for AR ⇄ ZH conversations.
/// It tracks whose turn it is, what phase we're in, and the current
/// transcript/translation data.
class ConversationController extends ChangeNotifier {
  // State fields
  SpeakerSide _nextTurn = SpeakerSide.arabic;
  SpeakerSide? _activeRecording;
  ConversationPhase _phase = ConversationPhase.idle;
  String? _transcript;
  String? _translation;
  String? _errorMessage;
  bool _isBusy = false;
  
  // Getters
  SpeakerSide get nextTurn => _nextTurn;
  SpeakerSide? get activeRecording => _activeRecording;
  ConversationPhase get phase => _phase;
  String? get transcript => _transcript;
  String? get translation => _translation;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _isBusy;
  
  /// Check if a specific side can start recording
  bool canRecord(SpeakerSide side) {
    return !_isBusy && _phase == ConversationPhase.idle;
  }
  
  /// Check if we can play TTS
  bool get canSpeak => _phase == ConversationPhase.ready && !_isBusy;
  
  /// Check if we can save the exchange
  bool get canSave => _phase == ConversationPhase.ready && 
                      _transcript != null && 
                      _transcript!.isNotEmpty;
  
  /// Check if we can retry translation
  bool get canRetry => _phase == ConversationPhase.ready && 
                       _transcript != null &&
                       !_isBusy;
  
  /// Get the language code for a side
  String getLanguageCode(SpeakerSide side) {
    return side == SpeakerSide.arabic ? 'ar' : 'zh';
  }
  
  /// Get the display language name for a side
  String getLanguageName(SpeakerSide side) {
    return side == SpeakerSide.arabic ? 'العربية' : '中文';
  }
  
  /// Start recording for a specific side
  void startRecording(SpeakerSide side) {
    if (!canRecord(side)) return;
    
    _isBusy = true;
    _activeRecording = side;
    _phase = ConversationPhase.recording;
    _transcript = null;
    _translation = null;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Stop recording and move to transcribing phase
  void stopRecording() {
    if (_phase != ConversationPhase.recording) return;
    
    _phase = ConversationPhase.transcribing;
    notifyListeners();
  }
  
  /// Set the transcript result from STT
  void setTranscript(String text) {
    _transcript = text;
    _phase = ConversationPhase.translating;
    notifyListeners();
  }
  
  /// Set the translation result
  void setTranslation(String text) {
    _translation = text;
    _phase = ConversationPhase.ready;
    _isBusy = false;
    
    // Flip the turn to the other side
    _nextTurn = _activeRecording == SpeakerSide.arabic 
        ? SpeakerSide.chinese 
        : SpeakerSide.arabic;
    
    notifyListeners();
  }
  
  /// Set error state
  void setError(String message) {
    _errorMessage = message;
    _phase = ConversationPhase.error;
    _isBusy = false;
    notifyListeners();
  }
  
  /// Start TTS playback
  void startSpeaking() {
    if (!canSpeak) return;
    
    _isBusy = true;
    _phase = ConversationPhase.speaking;
    notifyListeners();
  }
  
  /// TTS playback finished
  void stopSpeaking() {
    _isBusy = false;
    _phase = ConversationPhase.ready;
    notifyListeners();
  }
  
  /// Reset to idle state for next turn
  void resetForNextTurn() {
    _phase = ConversationPhase.idle;
    _activeRecording = null;
    _transcript = null;
    _translation = null;
    _errorMessage = null;
    _isBusy = false;
    notifyListeners();
  }
  
  /// Full reset to initial state
  void reset() {
    _nextTurn = SpeakerSide.arabic;
    _activeRecording = null;
    _phase = ConversationPhase.idle;
    _transcript = null;
    _translation = null;
    _errorMessage = null;
    _isBusy = false;
    notifyListeners();
  }
  
  /// Get the text that should be spoken for TTS
  /// Returns the translation (other language) by default
  String? getTtsText(SpeakerSide targetLanguage) {
    if (_activeRecording == null) return null;
    
    // If target is the same as recording language, speak transcript
    // If target is different, speak translation
    if (targetLanguage == _activeRecording) {
      return _transcript;
    } else {
      return _translation;
    }
  }
  
  /// Build a proof block for saving
  String buildProofBlock() {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln('🎙️ Conversation Exchange');
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln();
    
    if (_activeRecording == SpeakerSide.arabic) {
      buffer.writeln('🇸🇦 Arabic (Original):');
      buffer.writeln(_transcript ?? '');
      buffer.writeln();
      buffer.writeln('🇨🇳 Chinese (Translation):');
      buffer.writeln(_translation ?? '');
    } else {
      buffer.writeln('🇨🇳 Chinese (Original):');
      buffer.writeln(_transcript ?? '');
      buffer.writeln();
      buffer.writeln('🇸🇦 Arabic (Translation):');
      buffer.writeln(_translation ?? '');
    }
    
    buffer.writeln();
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln('Captured via Zidni Conversation Mode');
    
    return buffer.toString();
  }
}
