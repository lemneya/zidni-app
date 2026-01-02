/// TTS to File Service for Call Companion Mode
/// Generates audio files from text using system TTS
///
/// Supported Languages:
/// - Arabic (ar)
/// - Chinese (zh)
/// - English (en)
/// - Turkish (tr)
///
/// This service uses platform channels to access native TTS-to-file capabilities:
/// - Android: TextToSpeech.synthesizeToFile()
/// - iOS: AVSpeechSynthesizer write to file

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/call_companion/supported_language.dart';

/// Result of TTS synthesis to file
class TtsFileResult {
  /// Path to the generated audio file
  final String filePath;

  /// Duration of the audio in milliseconds
  final int durationMs;

  /// Language used
  final SupportedLanguage language;

  /// Original text that was synthesized
  final String text;

  TtsFileResult({
    required this.filePath,
    required this.durationMs,
    required this.language,
    required this.text,
  });

  /// Legacy getter for language code
  String get languageCode => language.code;
}

/// Voice information
class TtsVoice {
  /// Voice identifier
  final String id;

  /// Display name
  final String name;

  /// Language
  final SupportedLanguage language;

  /// Whether this is the default voice for the language
  final bool isDefault;

  TtsVoice({
    required this.id,
    required this.name,
    required this.language,
    this.isDefault = false,
  });

  /// Legacy getter for language code
  String get languageCode => language.code;
}

/// Service for generating audio files from text using TTS
class TtsToFileService {
  static TtsToFileService? _instance;

  /// Singleton instance
  static TtsToFileService get instance {
    _instance ??= TtsToFileService._();
    return _instance!;
  }

  TtsToFileService._();

  /// Platform channel for native TTS
  static const _channel = MethodChannel('com.zidni.app/tts_to_file');

  /// Available voices by language
  final Map<SupportedLanguage, List<TtsVoice>> _voices = {
    SupportedLanguage.arabic: [],
    SupportedLanguage.chinese: [],
    SupportedLanguage.english: [],
    SupportedLanguage.turkish: [],
  };

  /// TTS availability by language
  final Map<SupportedLanguage, bool> _ttsAvailable = {
    SupportedLanguage.arabic: false,
    SupportedLanguage.chinese: false,
    SupportedLanguage.english: false,
    SupportedLanguage.turkish: false,
  };

  /// Check if TTS is available for a language
  bool isTtsAvailable(SupportedLanguage language) => _ttsAvailable[language] ?? false;

  /// Check if Arabic TTS is available
  bool get isArabicTtsAvailable => _ttsAvailable[SupportedLanguage.arabic] ?? false;

  /// Check if Chinese TTS is available
  bool get isChineseTtsAvailable => _ttsAvailable[SupportedLanguage.chinese] ?? false;

  /// Check if English TTS is available
  bool get isEnglishTtsAvailable => _ttsAvailable[SupportedLanguage.english] ?? false;

  /// Check if Turkish TTS is available
  bool get isTurkishTtsAvailable => _ttsAvailable[SupportedLanguage.turkish] ?? false;

  /// Get available voices for a language
  List<TtsVoice> getVoices(SupportedLanguage language) => 
      List.unmodifiable(_voices[language] ?? []);

  /// Legacy getters
  List<TtsVoice> get arabicVoices => getVoices(SupportedLanguage.arabic);
  List<TtsVoice> get chineseVoices => getVoices(SupportedLanguage.chinese);
  List<TtsVoice> get englishVoices => getVoices(SupportedLanguage.english);
  List<TtsVoice> get turkishVoices => getVoices(SupportedLanguage.turkish);

  /// Initialize the service and check available voices
  Future<void> initialize() async {
    try {
      // Check available voices via platform channel
      final result = await _channel.invokeMethod<Map>('getAvailableVoices');

      if (result != null) {
        // Parse voices for each language
        _parseVoices(result, 'arabic', SupportedLanguage.arabic);
        _parseVoices(result, 'chinese', SupportedLanguage.chinese);
        _parseVoices(result, 'english', SupportedLanguage.english);
        _parseVoices(result, 'turkish', SupportedLanguage.turkish);
      }
    } on PlatformException catch (e) {
      // Platform channel not available, use fallback
      print('TTS platform channel error: ${e.message}');
      _setAllUnavailable();
    } catch (e) {
      print('TTS initialization error: $e');
      _setAllUnavailable();
    }
  }

  void _parseVoices(Map result, String key, SupportedLanguage language) {
    final voiceList = result[key] as List? ?? [];
    _voices[language] = voiceList.map((v) => TtsVoice(
          id: v['id'] as String,
          name: v['name'] as String,
          language: language,
          isDefault: v['isDefault'] as bool? ?? false,
        )).toList();
    _ttsAvailable[language] = _voices[language]!.isNotEmpty;
  }

  void _setAllUnavailable() {
    for (final language in SupportedLanguage.values) {
      _ttsAvailable[language] = false;
    }
  }

  /// Synthesize text to an audio file
  ///
  /// [text] - Text to synthesize
  /// [language] - Target language
  /// [voiceId] - Optional specific voice ID to use
  /// [outputFormat] - Output format ('m4a', 'wav', 'mp3')
  Future<TtsFileResult> synthesizeToFile({
    required String text,
    required SupportedLanguage language,
    String? voiceId,
    String outputFormat = 'm4a',
  }) async {
    // Validate language availability
    if (!isTtsAvailable(language)) {
      throw Exception('${language.nameAr} TTS not available. Please install voice in system settings.');
    }

    try {
      // Generate output file path
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'tts_${language.code}_$timestamp.$outputFormat';
      final outputPath = '${directory.path}/$filename';

      // Call platform channel to synthesize
      final result = await _channel.invokeMethod<Map>('synthesizeToFile', {
        'text': text,
        'languageCode': language.code,
        'voiceId': voiceId,
        'outputPath': outputPath,
        'outputFormat': outputFormat,
      });

      if (result == null) {
        throw Exception('TTS synthesis returned null');
      }

      return TtsFileResult(
        filePath: result['filePath'] as String,
        durationMs: result['durationMs'] as int? ?? 0,
        language: language,
        text: text,
      );
    } on PlatformException catch (e) {
      throw Exception('TTS synthesis failed: ${e.message}');
    }
  }

  /// Synthesize Arabic text to file
  Future<TtsFileResult> synthesizeArabicToFile(String text) async {
    return synthesizeToFile(text: text, language: SupportedLanguage.arabic);
  }

  /// Synthesize Chinese text to file
  Future<TtsFileResult> synthesizeChineseToFile(String text) async {
    return synthesizeToFile(text: text, language: SupportedLanguage.chinese);
  }

  /// Synthesize English text to file
  Future<TtsFileResult> synthesizeEnglishToFile(String text) async {
    return synthesizeToFile(text: text, language: SupportedLanguage.english);
  }

  /// Synthesize Turkish text to file
  Future<TtsFileResult> synthesizeTurkishToFile(String text) async {
    return synthesizeToFile(text: text, language: SupportedLanguage.turkish);
  }

  /// Speak text immediately (not to file)
  Future<void> speak({
    required String text,
    required SupportedLanguage language,
    String? voiceId,
  }) async {
    try {
      await _channel.invokeMethod('speak', {
        'text': text,
        'languageCode': language.code,
        'voiceId': voiceId,
      });
    } on PlatformException catch (e) {
      throw Exception('TTS speak failed: ${e.message}');
    }
  }

  /// Stop any ongoing speech
  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (e) {
      // Ignore errors when stopping
    }
  }

  /// Get instructions for installing missing TTS voices
  String getVoiceInstallInstructions(String languageCode) {
    final language = SupportedLanguageExtension.fromCode(languageCode);
    
    if (Platform.isAndroid) {
      return 'لتثبيت صوت ${language.nameAr}:\n'
          '1. افتح إعدادات الهاتف\n'
          '2. اذهب إلى النظام > اللغات والإدخال > تحويل النص إلى كلام\n'
          '3. اختر محرك Google TTS\n'
          '4. قم بتنزيل ${language.nameAr}';
    } else if (Platform.isIOS) {
      return 'لتثبيت صوت ${language.nameAr}:\n'
          '1. افتح الإعدادات\n'
          '2. اذهب إلى تسهيلات الاستخدام > المحتوى المنطوق > الأصوات\n'
          '3. اختر ${language.nameAr} وقم بتنزيل صوت';
    }
    return 'يرجى تثبيت الصوت من إعدادات النظام';
  }

  /// Get instructions for a specific language
  String getVoiceInstallInstructionsForLanguage(SupportedLanguage language) {
    return getVoiceInstallInstructions(language.code);
  }
}
