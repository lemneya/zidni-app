/// Whisper STT Service for Call Companion Mode
/// Provides offline speech-to-text using Whisper.cpp via whisper_ggml
///
/// Note: This service wraps the whisper_ggml package for offline STT.
/// The actual Whisper model must be downloaded before use.

import 'dart:async';
import 'dart:io';

/// Result of a transcription operation
class TranscriptionResult {
  /// Transcribed text
  final String text;

  /// Detected language code
  final String? detectedLanguage;

  /// Confidence score (0.0 to 1.0)
  final double? confidence;

  /// Duration of audio processed in milliseconds
  final int durationMs;

  TranscriptionResult({
    required this.text,
    this.detectedLanguage,
    this.confidence,
    required this.durationMs,
  });

  /// Check if transcription is empty
  bool get isEmpty => text.trim().isEmpty;

  /// Check if transcription has content
  bool get isNotEmpty => text.trim().isNotEmpty;
}

/// Whisper model size options
enum WhisperModelSize {
  /// Tiny model (~75 MB) - fastest, lower accuracy
  tiny,

  /// Base model (~150 MB) - balanced
  base,

  /// Small model (~500 MB) - better accuracy
  small,
}

/// Service for offline speech-to-text using Whisper
class WhisperSttService {
  static WhisperSttService? _instance;

  /// Singleton instance
  static WhisperSttService get instance {
    _instance ??= WhisperSttService._();
    return _instance!;
  }

  WhisperSttService._();

  /// Whether the model is loaded and ready
  bool _isModelLoaded = false;

  /// Current model size
  WhisperModelSize? _currentModelSize;

  /// Path to the loaded model
  String? _modelPath;

  /// Check if service is ready
  bool get isReady => _isModelLoaded;

  /// Get current model size
  WhisperModelSize? get currentModelSize => _currentModelSize;

  /// Initialize the service with a model
  ///
  /// [modelPath] - Path to the Whisper GGML model file
  /// [modelSize] - Size of the model being loaded
  Future<bool> initialize({
    required String modelPath,
    required WhisperModelSize modelSize,
  }) async {
    try {
      // Verify model file exists
      final modelFile = File(modelPath);
      if (!await modelFile.exists()) {
        throw Exception('Model file not found: $modelPath');
      }

      // TODO: Initialize whisper_ggml with model
      // await WhisperGgml.loadModel(modelPath);

      _modelPath = modelPath;
      _currentModelSize = modelSize;
      _isModelLoaded = true;

      return true;
    } catch (e) {
      _isModelLoaded = false;
      rethrow;
    }
  }

  /// Transcribe an audio file
  ///
  /// [audioPath] - Path to the audio file (WAV format preferred)
  /// [language] - Expected language code ('zh' for Chinese, 'ar' for Arabic)
  /// [translate] - Whether to translate to English (not used, we use ML Kit)
  Future<TranscriptionResult> transcribe({
    required String audioPath,
    String? language,
    bool translate = false,
  }) async {
    if (!_isModelLoaded) {
      throw Exception('Whisper model not loaded. Call initialize() first.');
    }

    final audioFile = File(audioPath);
    if (!await audioFile.exists()) {
      throw Exception('Audio file not found: $audioPath');
    }

    try {
      // TODO: Implement actual Whisper transcription
      // final result = await WhisperGgml.transcribe(
      //   audioPath: audioPath,
      //   language: language,
      //   translate: translate,
      // );

      // Placeholder implementation for structure
      // In production, this calls whisper_ggml
      await Future.delayed(const Duration(milliseconds: 500));

      return TranscriptionResult(
        text: '[Transcription placeholder - Whisper integration pending]',
        detectedLanguage: language,
        confidence: 0.95,
        durationMs: 2500,
      );
    } catch (e) {
      throw Exception('Transcription failed: $e');
    }
  }

  /// Transcribe audio from bytes (for streaming)
  ///
  /// [audioBytes] - Raw audio bytes (PCM 16-bit, 16kHz mono)
  /// [language] - Expected language code
  Future<TranscriptionResult> transcribeBytes({
    required List<int> audioBytes,
    String? language,
  }) async {
    if (!_isModelLoaded) {
      throw Exception('Whisper model not loaded. Call initialize() first.');
    }

    try {
      // TODO: Implement byte-based transcription
      // final result = await WhisperGgml.transcribeBytes(
      //   bytes: audioBytes,
      //   language: language,
      // );

      await Future.delayed(const Duration(milliseconds: 300));

      return TranscriptionResult(
        text: '[Byte transcription placeholder]',
        detectedLanguage: language,
        confidence: 0.90,
        durationMs: audioBytes.length ~/ 32, // Rough estimate
      );
    } catch (e) {
      throw Exception('Byte transcription failed: $e');
    }
  }

  /// Release model resources
  Future<void> dispose() async {
    if (_isModelLoaded) {
      // TODO: Release whisper_ggml resources
      // await WhisperGgml.releaseModel();
      _isModelLoaded = false;
      _modelPath = null;
      _currentModelSize = null;
    }
  }

  /// Get model download URL for a given size
  static String getModelDownloadUrl(WhisperModelSize size) {
    const baseUrl = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main';
    switch (size) {
      case WhisperModelSize.tiny:
        return '$baseUrl/ggml-tiny.bin';
      case WhisperModelSize.base:
        return '$baseUrl/ggml-base.bin';
      case WhisperModelSize.small:
        return '$baseUrl/ggml-small.bin';
    }
  }

  /// Get expected model size in bytes
  static int getModelSizeBytes(WhisperModelSize size) {
    switch (size) {
      case WhisperModelSize.tiny:
        return 75 * 1024 * 1024; // ~75 MB
      case WhisperModelSize.base:
        return 150 * 1024 * 1024; // ~150 MB
      case WhisperModelSize.small:
        return 500 * 1024 * 1024; // ~500 MB
    }
  }

  /// Get model filename
  static String getModelFilename(WhisperModelSize size) {
    switch (size) {
      case WhisperModelSize.tiny:
        return 'ggml-tiny.bin';
      case WhisperModelSize.base:
        return 'ggml-base.bin';
      case WhisperModelSize.small:
        return 'ggml-small.bin';
    }
  }
}
