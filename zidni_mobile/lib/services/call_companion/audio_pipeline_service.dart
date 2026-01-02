/// Audio Pipeline Service for Call Companion Mode
/// Manages the complete audio processing flow:
/// Recording → Transcription → Translation → TTS Output
///
/// Supports multiple language pairs:
/// - Chinese ↔ Arabic
/// - English ↔ Arabic
/// - Turkish ↔ Arabic

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../models/call_companion/audio_chunk.dart';
import '../../models/call_companion/supported_language.dart';
import 'whisper_stt_service.dart';
import 'mlkit_translation_service.dart';
import 'tts_to_file_service.dart';

/// Current state of the audio pipeline
enum PipelineState {
  /// Idle, not processing
  idle,

  /// Recording audio
  recording,

  /// Processing recorded audio (transcribing)
  transcribing,

  /// Translating transcribed text
  translating,

  /// Speaking translated text via TTS
  speaking,

  /// Pipeline error
  error,
}

/// Mode of operation for the pipeline
enum PipelineMode {
  /// LISTEN mode: Capture foreign language → Show Arabic translation
  listen,

  /// SPEAK mode: Capture Arabic → Speak foreign language translation
  speak,
}

/// Result of a complete pipeline cycle
class PipelineResult {
  /// Original audio chunk
  final AudioChunk chunk;

  /// Transcribed text in source language
  final String transcribedText;

  /// Translated text in target language
  final String translatedText;

  /// Source language
  final SupportedLanguage sourceLanguage;

  /// Target language
  final SupportedLanguage targetLanguage;

  /// Path to TTS output file (only for SPEAK mode)
  final String? ttsOutputPath;

  /// Processing duration in milliseconds
  final int processingDurationMs;

  PipelineResult({
    required this.chunk,
    required this.transcribedText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.ttsOutputPath,
    required this.processingDurationMs,
  });
}

/// Callback for pipeline state changes
typedef PipelineStateCallback = void Function(PipelineState state);

/// Callback for pipeline results
typedef PipelineResultCallback = void Function(PipelineResult result);

/// Callback for pipeline errors
typedef PipelineErrorCallback = void Function(String error);

/// Service for managing the complete audio processing pipeline
class AudioPipelineService {
  static AudioPipelineService? _instance;

  /// Singleton instance
  static AudioPipelineService get instance {
    _instance ??= AudioPipelineService._();
    return _instance!;
  }

  AudioPipelineService._();

  /// Whisper STT service
  final _sttService = WhisperSttService.instance;

  /// ML Kit translation service
  final _translationService = MlkitTranslationService.instance;

  /// TTS to file service
  final _ttsService = TtsToFileService.instance;

  /// Current pipeline state
  PipelineState _state = PipelineState.idle;

  /// Current pipeline mode
  PipelineMode? _currentMode;

  /// Current target language (for LISTEN: foreign language, for SPEAK: foreign language)
  SupportedLanguage _targetLanguage = SupportedLanguage.chinese;

  /// State change callback
  PipelineStateCallback? onStateChanged;

  /// Result callback
  PipelineResultCallback? onResult;

  /// Error callback
  PipelineErrorCallback? onError;

  /// Recording stream subscription
  StreamSubscription? _recordingSubscription;

  /// Current recording path
  String? _currentRecordingPath;

  /// Recording start time
  DateTime? _recordingStartTime;

  /// Chunk counter for unique IDs
  int _chunkCounter = 0;

  /// Get current state
  PipelineState get state => _state;

  /// Get current mode
  PipelineMode? get currentMode => _currentMode;

  /// Get current target language
  SupportedLanguage get targetLanguage => _targetLanguage;

  /// Check if pipeline is active
  bool get isActive => _state != PipelineState.idle && _state != PipelineState.error;

  /// Check if recording
  bool get isRecording => _state == PipelineState.recording;

  /// Set target language for translation
  void setTargetLanguage(SupportedLanguage language) {
    if (language == SupportedLanguage.arabic) {
      throw ArgumentError('Target language cannot be Arabic. Arabic is always the user\'s language.');
    }
    _targetLanguage = language;
  }

  /// Initialize the pipeline
  Future<bool> initialize() async {
    try {
      // Initialize all services
      await _translationService.initialize();
      await _ttsService.initialize();

      return true;
    } catch (e) {
      _setError('Pipeline initialization failed: $e');
      return false;
    }
  }

  /// Start recording in LISTEN mode (Foreign → Arabic)
  /// [language] - The foreign language being spoken (Chinese, English, or Turkish)
  Future<void> startListening({SupportedLanguage? language}) async {
    if (language != null) {
      setTargetLanguage(language);
    }
    await _startRecording(PipelineMode.listen);
  }

  /// Start recording in SPEAK mode (Arabic → Foreign)
  /// [language] - The foreign language to translate to (Chinese, English, or Turkish)
  Future<void> startSpeaking({SupportedLanguage? language}) async {
    if (language != null) {
      setTargetLanguage(language);
    }
    await _startRecording(PipelineMode.speak);
  }

  /// Start recording with specified mode
  Future<void> _startRecording(PipelineMode mode) async {
    if (_state != PipelineState.idle) {
      throw Exception('Pipeline is already active');
    }

    _currentMode = mode;
    _setState(PipelineState.recording);

    try {
      // Generate recording path
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/recording_$timestamp.wav';
      _recordingStartTime = DateTime.now();

      // TODO: Start actual recording using record package
      // await Record().start(
      //   path: _currentRecordingPath!,
      //   encoder: AudioEncoder.wav,
      //   samplingRate: 16000,
      //   numChannels: 1,
      // );

    } catch (e) {
      _setError('Failed to start recording: $e');
    }
  }

  /// Stop recording and process the audio
  Future<PipelineResult?> stopAndProcess() async {
    if (_state != PipelineState.recording) {
      return null;
    }

    final mode = _currentMode!;
    final recordingPath = _currentRecordingPath!;
    final startTime = _recordingStartTime!;
    final durationMs = DateTime.now().difference(startTime).inMilliseconds;

    try {
      // TODO: Stop actual recording
      // await Record().stop();

      // Determine source language based on mode
      final sourceLanguage = mode == PipelineMode.listen 
          ? _targetLanguage  // LISTEN: foreign language → Arabic
          : SupportedLanguage.arabic;  // SPEAK: Arabic → foreign language

      // Create audio chunk
      final chunk = AudioChunk(
        id: 'chunk_${++_chunkCounter}',
        filePath: recordingPath,
        durationMs: durationMs,
        sourceLanguage: sourceLanguage.code,
      );

      // Process the chunk
      return await _processChunk(chunk, mode);
    } catch (e) {
      _setError('Failed to stop and process: $e');
      return null;
    }
  }

  /// Process an audio chunk through the pipeline
  Future<PipelineResult> _processChunk(AudioChunk chunk, PipelineMode mode) async {
    final processingStart = DateTime.now();

    // Determine languages
    final SupportedLanguage sourceLanguage;
    final SupportedLanguage targetLang;
    final LanguagePair translationPair;

    if (mode == PipelineMode.listen) {
      // LISTEN: Foreign → Arabic
      sourceLanguage = _targetLanguage;
      targetLang = SupportedLanguage.arabic;
      translationPair = LanguagePair(source: _targetLanguage, target: SupportedLanguage.arabic);
    } else {
      // SPEAK: Arabic → Foreign
      sourceLanguage = SupportedLanguage.arabic;
      targetLang = _targetLanguage;
      translationPair = LanguagePair(source: SupportedLanguage.arabic, target: _targetLanguage);
    }

    // Step 1: Transcribe
    _setState(PipelineState.transcribing);
    final transcriptionResult = await _sttService.transcribe(
      audioPath: chunk.filePath,
      language: sourceLanguage.code,
    );
    final transcribedText = transcriptionResult.text;

    // Step 2: Translate
    _setState(PipelineState.translating);
    final translationResult = await _translationService.translate(
      text: transcribedText,
      pair: translationPair,
    );
    final translatedText = translationResult.translatedText;

    // Step 3: TTS (only for SPEAK mode)
    String? ttsOutputPath;
    if (mode == PipelineMode.speak) {
      _setState(PipelineState.speaking);
      final ttsResult = await _ttsService.synthesizeToFile(
        text: translatedText,
        language: targetLang,
      );
      ttsOutputPath = ttsResult.filePath;

      // Also speak it aloud
      await _ttsService.speak(text: translatedText, language: targetLang);
    }

    // Update chunk with results
    chunk.markProcessed(
      transcribed: transcribedText,
      translated: translatedText,
    );

    // Create result
    final processingDuration = DateTime.now().difference(processingStart).inMilliseconds;
    final result = PipelineResult(
      chunk: chunk,
      transcribedText: transcribedText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLang,
      ttsOutputPath: ttsOutputPath,
      processingDurationMs: processingDuration,
    );

    // Reset state
    _setState(PipelineState.idle);
    _currentMode = null;

    // Notify callback
    onResult?.call(result);

    return result;
  }

  /// Cancel current operation
  Future<void> cancel() async {
    if (_state == PipelineState.recording) {
      // TODO: Stop recording
      // await Record().stop();
    }

    if (_state == PipelineState.speaking) {
      await _ttsService.stop();
    }

    _setState(PipelineState.idle);
    _currentMode = null;
    _currentRecordingPath = null;
    _recordingStartTime = null;
  }

  /// Set pipeline state and notify
  void _setState(PipelineState newState) {
    _state = newState;
    onStateChanged?.call(newState);
  }

  /// Set error state
  void _setError(String error) {
    _state = PipelineState.error;
    onError?.call(error);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await cancel();
    _recordingSubscription?.cancel();
  }
}
