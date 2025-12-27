import 'package:flutter/services.dart';
import 'package:zidni_mobile/services/tts_service.dart';
import 'package:zidni_mobile/screens/conversation/conversation_mode_screen.dart';

/// Service for intro messages in Conversation Mode
/// 
/// Provides pre-written intro messages for each target language
/// that explain how to use the translation app.
class IntroMessageService {
  final TtsService _tts;
  
  IntroMessageService(this._tts);
  
  /// Intro message templates for each target language
  /// These are spoken to the other person to explain how to talk
  static const Map<TargetLang, String> _introTemplates = {
    TargetLang.zh: '你好！我会用这个应用和你用中文交流。请用中文说话，句子短一点，我会让手机翻译。谢谢。',
    TargetLang.en: "Hi! I'm going to talk with you using this app. Please speak in English and keep sentences short so the phone can translate. Thank you.",
    TargetLang.tr: 'Merhaba! Bu uygulamayla sizinle Türkçe konuşacağım. Lütfen Türkçe konuşun ve cümleleri kısa tutun; telefon çevirecek. Teşekkür ederim.',
    TargetLang.es: '¡Hola! Voy a hablar contigo usando esta aplicación. Por favor habla en español y usa frases cortas para que el teléfono traduzca. Gracias.',
  };
  
  /// Get the intro text for a given target language
  String introText(TargetLang lang) {
    return _introTemplates[lang] ?? _introTemplates[TargetLang.en]!;
  }
  
  /// Speak the intro message in the target language using TTS
  Future<void> speak(TargetLang lang) async {
    final text = introText(lang);
    await _tts.speak(text, lang.ttsLocale);
  }
  
  /// Copy the intro message to clipboard
  Future<void> copyToClipboard(TargetLang lang) async {
    final text = introText(lang);
    await Clipboard.setData(ClipboardData(text: text));
  }
}
