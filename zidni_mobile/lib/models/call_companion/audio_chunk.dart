/// Audio chunk model for Call Companion Mode
/// Represents a segment of recorded audio for processing

class AudioChunk {
  /// Unique identifier for this chunk
  final String id;

  /// Path to the audio file
  final String filePath;

  /// Duration in milliseconds
  final int durationMs;

  /// Timestamp when recording started
  final DateTime timestamp;

  /// Source language code (e.g., 'zh', 'ar')
  final String sourceLanguage;

  /// Whether this chunk has been processed
  bool isProcessed;

  /// Transcribed text (populated after STT)
  String? transcribedText;

  /// Translated text (populated after translation)
  String? translatedText;

  AudioChunk({
    required this.id,
    required this.filePath,
    required this.durationMs,
    required this.timestamp,
    required this.sourceLanguage,
    this.isProcessed = false,
    this.transcribedText,
    this.translatedText,
  });

  /// Create a new chunk for Chinese audio (from supplier)
  factory AudioChunk.chinese({
    required String id,
    required String filePath,
    required int durationMs,
  }) {
    return AudioChunk(
      id: id,
      filePath: filePath,
      durationMs: durationMs,
      timestamp: DateTime.now(),
      sourceLanguage: 'zh',
    );
  }

  /// Create a new chunk for Arabic audio (from user)
  factory AudioChunk.arabic({
    required String id,
    required String filePath,
    required int durationMs,
  }) {
    return AudioChunk(
      id: id,
      filePath: filePath,
      durationMs: durationMs,
      timestamp: DateTime.now(),
      sourceLanguage: 'ar',
    );
  }

  /// Mark chunk as processed with results
  void markProcessed({
    required String transcribed,
    required String translated,
  }) {
    transcribedText = transcribed;
    translatedText = translated;
    isProcessed = true;
  }

  /// Get target language based on source
  String get targetLanguage => sourceLanguage == 'zh' ? 'ar' : 'zh';

  /// Check if this is Chinese audio
  bool get isChinese => sourceLanguage == 'zh';

  /// Check if this is Arabic audio
  bool get isArabic => sourceLanguage == 'ar';

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'durationMs': durationMs,
        'timestamp': timestamp.toIso8601String(),
        'sourceLanguage': sourceLanguage,
        'isProcessed': isProcessed,
        'transcribedText': transcribedText,
        'translatedText': translatedText,
      };

  factory AudioChunk.fromJson(Map<String, dynamic> json) => AudioChunk(
        id: json['id'] as String,
        filePath: json['filePath'] as String,
        durationMs: json['durationMs'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        sourceLanguage: json['sourceLanguage'] as String,
        isProcessed: json['isProcessed'] as bool? ?? false,
        transcribedText: json['transcribedText'] as String?,
        translatedText: json['translatedText'] as String?,
      );
}
