/// TTS to File Service for Call Companion Mode
/// Generates audio files from text using system TTS
///
/// This service uses platform channels to access native TTS-to-file capabilities:
/// - Android: TextToSpeech.synthesizeToFile()
/// - iOS: AVSpeechSynthesizer write to file

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Result of TTS synthesis to file
class TtsFileResult {
  /// Path to the generated audio file
  final String filePath;

  /// Duration of the audio in milliseconds
  final int durationMs;

  /// Language code used
  final String languageCode;

  /// Original text that was synthesized
  final String text;

  TtsFileResult({
    required this.filePath,
    required this.durationMs,
    required this.languageCode,
    required this.text,
  });
}

/// Voice information
class TtsVoice {
  /// Voice identifier
  final String id;

  /// Display name
  final String name;

  /// Language code
  final String languageCode;

  /// Whether this is the default voice for the language
  final bool isDefault;

  TtsVoice({
    required this.id,
    required this.name,
    required this.languageCode,
    this.isDefault = false,
  });
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

  /// Available Chinese voices
  List<TtsVoice> _chineseVoices = [];

  /// Available Arabic voices
  List<TtsVoice> _arabicVoices = [];

  /// Whether Chinese TTS is available
  bool _chineseTtsAvailable = false;

  /// Whether Arabic TTS is available
  bool _arabicTtsAvailable = false;

  /// Check if Chinese TTS is available
  bool get isChineseTtsAvailable => _chineseTtsAvailable;

  /// Check if Arabic TTS is available
  bool get isArabicTtsAvailable => _arabicTtsAvailable;

  /// Get available Chinese voices
  List<TtsVoice> get chineseVoices => List.unmodifiable(_chineseVoices);

  /// Get available Arabic voices
  List<TtsVoice> get arabicVoices => List.unmodifiable(_arabicVoices);

  /// Initialize the service and check available voices
  Future<void> initialize() async {
    try {
      // Check available voices via platform channel
      final result = await _channel.invokeMethod<Map>('getAvailableVoices');

      if (result != null) {
        // Parse Chinese voices
        final chineseList = result['chinese'] as List? ?? [];
        _chineseVoices = chineseList.map((v) => TtsVoice(
              id: v['id'] as String,
              name: v['name'] as String,
              languageCode: 'zh',
              isDefault: v['isDefault'] as bool? ?? false,
            )).toList();
        _chineseTtsAvailable = _chineseVoices.isNotEmpty;

        // Parse Arabic voices
        final arabicList = result['arabic'] as List? ?? [];
        _arabicVoices = arabicList.map((v) => TtsVoice(
              id: v['id'] as String,
              name: v['name'] as String,
              languageCode: 'ar',
              isDefault: v['isDefault'] as bool? ?? false,
            )).toList();
        _arabicTtsAvailable = _arabicVoices.isNotEmpty;
      }
    } on PlatformException catch (e) {
      // Platform channel not available, use fallback
      print('TTS platform channel error: ${e.message}');
      _chineseTtsAvailable = false;
      _arabicTtsAvailable = false;
    } catch (e) {
      print('TTS initialization error: $e');
      _chineseTtsAvailable = false;
      _arabicTtsAvailable = false;
    }
  }

  /// Synthesize text to an audio file
  ///
  /// [text] - Text to synthesize
  /// [languageCode] - Language code ('zh' or 'ar')
  /// [voiceId] - Optional specific voice ID to use
  /// [outputFormat] - Output format ('m4a', 'wav', 'mp3')
  Future<TtsFileResult> synthesizeToFile({
    required String text,
    required String languageCode,
    String? voiceId,
    String outputFormat = 'm4a',
  }) async {
    // Validate language
    if (languageCode == 'zh' && !_chineseTtsAvailable) {
      throw Exception('Chinese TTS not available. Please install Chinese voice in system settings.');
    }
    if (languageCode == 'ar' && !_arabicTtsAvailable) {
      throw Exception('Arabic TTS not available. Please install Arabic voice in system settings.');
    }

    try {
      // Generate output file path
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'tts_${languageCode}_$timestamp.$outputFormat';
      final outputPath = '${directory.path}/$filename';

      // Call platform channel to synthesize
      final result = await _channel.invokeMethod<Map>('synthesizeToFile', {
        'text': text,
        'languageCode': languageCode,
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
        languageCode: languageCode,
        text: text,
      );
    } on PlatformException catch (e) {
      throw Exception('TTS synthesis failed: ${e.message}');
    }
  }

  /// Synthesize Chinese text to file
  Future<TtsFileResult> synthesizeChineseToFile(String text) async {
    return synthesizeToFile(text: text, languageCode: 'zh');
  }

  /// Synthesize Arabic text to file
  Future<TtsFileResult> synthesizeArabicToFile(String text) async {
    return synthesizeToFile(text: text, languageCode: 'ar');
  }

  /// Speak text immediately (not to file)
  Future<void> speak({
    required String text,
    required String languageCode,
    String? voiceId,
  }) async {
    try {
      await _channel.invokeMethod('speak', {
        'text': text,
        'languageCode': languageCode,
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
    if (Platform.isAndroid) {
      return languageCode == 'zh'
          ? 'لتثبيت الصوت الصيني:\n'
              '1. افتح إعدادات الهاتف\n'
              '2. اذهب إلى النظام > اللغات والإدخال > تحويل النص إلى كلام\n'
              '3. اختر محرك Google TTS\n'
              '4. قم بتنزيل اللغة الصينية'
          : 'لتثبيت الصوت العربي:\n'
              '1. افتح إعدادات الهاتف\n'
              '2. اذهب إلى النظام > اللغات والإدخال > تحويل النص إلى كلام\n'
              '3. اختر محرك Google TTS\n'
              '4. قم بتنزيل اللغة العربية';
    } else if (Platform.isIOS) {
      return languageCode == 'zh'
          ? 'لتثبيت الصوت الصيني:\n'
              '1. افتح الإعدادات\n'
              '2. اذهب إلى تسهيلات الاستخدام > المحتوى المنطوق > الأصوات\n'
              '3. اختر الصينية وقم بتنزيل صوت'
          : 'لتثبيت الصوت العربي:\n'
              '1. افتح الإعدادات\n'
              '2. اذهب إلى تسهيلات الاستخدام > المحتوى المنطوق > الأصوات\n'
              '3. اختر العربية وقم بتنزيل صوت';
    }
    return 'يرجى تثبيت الصوت من إعدادات النظام';
  }
}
