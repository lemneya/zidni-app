/// Abstract interface for translation services
/// 
/// Future-proof signature for Google/DeepL/other implementations.
abstract class TranslationService {
  /// Translate text from source language to target language
  /// 
  /// [text] - The text to translate
  /// [fromLang] - Source language code: "ar" or "zh"
  /// [toLang] - Target language code: "ar" or "zh"
  /// 
  /// Returns the translated text
  Future<String> translate({
    required String text,
    required String fromLang,
    required String toLang,
  });
}

/// Stub implementation for UI testing (Gate #12)
/// 
/// Returns placeholder translations that indicate the translation would happen.
/// No external API calls in this gate.
class StubTranslationService implements TranslationService {
  @override
  Future<String> translate({
    required String text,
    required String fromLang,
    required String toLang,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Stub behavior per spec:
    // If from=ar, to=zh => return （中文）$text
    // If from=zh, to=ar => return （عربي）$text
    if (fromLang == 'ar' && toLang == 'zh') {
      return '（中文）$text';
    } else if (fromLang == 'zh' && toLang == 'ar') {
      return '（عربي）$text';
    }
    
    // Fallback
    return '[$toLang] $text';
  }
}
