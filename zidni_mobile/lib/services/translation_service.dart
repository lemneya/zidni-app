/// Abstract interface for translation services
/// 
/// Future-proof signature for Google/DeepL/other implementations.
abstract class TranslationService {
  /// Translate text from source language to target language
  /// 
  /// [text] - The text to translate
  /// [fromLang] - Source language code: "ar", "zh", "en", "tr", "es", "fr"
  /// [toLang] - Target language code: "ar", "zh", "en", "tr", "es", "fr"
  /// 
  /// Returns the translated text
  Future<String> translate({
    required String text,
    required String fromLang,
    required String toLang,
  });
}

/// Stub implementation for UI testing (Gate #12-13)
/// 
/// Returns placeholder translations that indicate the translation would happen.
/// No external API calls in this gate.
class StubTranslationService implements TranslationService {
  /// Language code to prefix mapping
  static const Map<String, String> _prefixes = {
    'ar': '（عربي）',
    'zh': '（中文）',
    'en': '(English)',
    'tr': '(Türkçe)',
    'es': '(Español)',
    'fr': '(Français)',
  };
  
  @override
  Future<String> translate({
    required String text,
    required String fromLang,
    required String toLang,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get prefix for target language
    final prefix = _prefixes[toLang] ?? '[$toLang]';
    
    return '$prefix $text';
  }
}
