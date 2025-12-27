import 'package:flutter_tts/flutter_tts.dart';

/// Service for text-to-speech functionality
/// 
/// Wraps the flutter_tts package to provide a simple interface
/// for speaking text in different languages.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  
  /// Callback when TTS starts speaking
  Function()? onStart;
  
  /// Callback when TTS finishes speaking
  Function()? onComplete;
  
  /// Callback when TTS encounters an error
  Function(String)? onError;
  
  /// Initialize the TTS engine
  Future<void> init() async {
    if (_isInitialized) return;
    
    await _flutterTts.setSharedInstance(true);
    
    // Set up callbacks
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      onStart?.call();
    });
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      onComplete?.call();
    });
    
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      onError?.call(msg.toString());
    });
    
    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
    });
    
    _isInitialized = true;
  }
  
  /// Check if TTS is currently speaking
  bool get isSpeaking => _isSpeaking;
  
  /// Speak text in the specified language
  /// 
  /// [text] - The text to speak
  /// [langCode] - Language code ('ar' for Arabic, 'zh' for Chinese)
  Future<void> speak(String text, String langCode) async {
    if (!_isInitialized) {
      await init();
    }
    
    // Stop any current speech
    if (_isSpeaking) {
      await stop();
    }
    
    // Set language
    final locale = _getLocale(langCode);
    await _flutterTts.setLanguage(locale);
    
    // Set speech parameters
    await _flutterTts.setSpeechRate(0.5); // Slower for clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Speak
    await _flutterTts.speak(text);
  }
  
  /// Stop current speech
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }
  
  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await init();
    }
    
    final languages = await _flutterTts.getLanguages;
    return List<String>.from(languages ?? []);
  }
  
  /// Check if a language is available
  Future<bool> isLanguageAvailable(String langCode) async {
    final languages = await getAvailableLanguages();
    final locale = _getLocale(langCode);
    return languages.any((lang) => 
      lang.toLowerCase().startsWith(langCode.toLowerCase()) ||
      lang.toLowerCase() == locale.toLowerCase()
    );
  }
  
  /// Convert language code to locale
  String _getLocale(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'ar':
        return 'ar-SA'; // Arabic (Saudi Arabia)
      case 'zh':
        return 'zh-CN'; // Chinese (Simplified)
      case 'en':
        return 'en-US';
      default:
        return langCode;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _flutterTts.stop();
    _isInitialized = false;
  }
}
