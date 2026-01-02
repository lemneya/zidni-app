/// Voice message model for Voice Message Translation feature
/// Represents a voice message received via share intent or recorded as reply

enum VoiceMessageStatus {
  /// Just received, not yet processed
  pending,

  /// Currently being transcribed
  transcribing,

  /// Currently being translated
  translating,

  /// Processing complete
  completed,

  /// Processing failed
  failed,
}

enum VoiceMessageType {
  /// Received from external app (WeChat, WhatsApp)
  received,

  /// Recorded as reply
  reply,
}

class VoiceMessage {
  /// Unique identifier
  final String id;

  /// Path to the audio file
  final String filePath;

  /// Original filename (if shared from external app)
  final String? originalFilename;

  /// Source app (e.g., 'WeChat', 'WhatsApp')
  final String? sourceApp;

  /// Message type
  final VoiceMessageType type;

  /// Source language
  final String sourceLanguage;

  /// Target language
  final String targetLanguage;

  /// Current processing status
  VoiceMessageStatus status;

  /// Transcribed text in source language
  String? transcribedText;

  /// Translated text in target language
  String? translatedText;

  /// Path to generated reply audio (for reply messages)
  String? replyAudioPath;

  /// Duration in milliseconds
  final int? durationMs;

  /// Timestamp when received/created
  final DateTime timestamp;

  /// Error message if processing failed
  String? errorMessage;

  VoiceMessage({
    required this.id,
    required this.filePath,
    this.originalFilename,
    this.sourceApp,
    required this.type,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.status = VoiceMessageStatus.pending,
    this.transcribedText,
    this.translatedText,
    this.replyAudioPath,
    this.durationMs,
    required this.timestamp,
    this.errorMessage,
  });

  /// Create a received Chinese voice message (to be translated to Arabic)
  factory VoiceMessage.receivedChinese({
    required String id,
    required String filePath,
    String? originalFilename,
    String? sourceApp,
    int? durationMs,
  }) {
    return VoiceMessage(
      id: id,
      filePath: filePath,
      originalFilename: originalFilename,
      sourceApp: sourceApp,
      type: VoiceMessageType.received,
      sourceLanguage: 'zh',
      targetLanguage: 'ar',
      durationMs: durationMs,
      timestamp: DateTime.now(),
    );
  }

  /// Create an Arabic reply (to be converted to Chinese voice)
  factory VoiceMessage.arabicReply({
    required String id,
    required String filePath,
    int? durationMs,
  }) {
    return VoiceMessage(
      id: id,
      filePath: filePath,
      type: VoiceMessageType.reply,
      sourceLanguage: 'ar',
      targetLanguage: 'zh',
      durationMs: durationMs,
      timestamp: DateTime.now(),
    );
  }

  /// Update status to transcribing
  void startTranscribing() {
    status = VoiceMessageStatus.transcribing;
  }

  /// Update with transcription result
  void setTranscription(String text) {
    transcribedText = text;
    status = VoiceMessageStatus.translating;
  }

  /// Update with translation result
  void setTranslation(String text) {
    translatedText = text;
    status = VoiceMessageStatus.completed;
  }

  /// Set reply audio path (for Arabic replies converted to Chinese)
  void setReplyAudio(String path) {
    replyAudioPath = path;
  }

  /// Mark as failed
  void markFailed(String error) {
    status = VoiceMessageStatus.failed;
    errorMessage = error;
  }

  /// Check if processing is complete
  bool get isCompleted => status == VoiceMessageStatus.completed;

  /// Check if this is a received message
  bool get isReceived => type == VoiceMessageType.received;

  /// Check if this is a reply
  bool get isReply => type == VoiceMessageType.reply;

  /// Get display name for source language
  String get sourceLanguageDisplay => sourceLanguage == 'zh' ? 'الصينية' : 'العربية';

  /// Get display name for target language
  String get targetLanguageDisplay => targetLanguage == 'zh' ? 'الصينية' : 'العربية';

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'originalFilename': originalFilename,
        'sourceApp': sourceApp,
        'type': type.name,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
        'status': status.name,
        'transcribedText': transcribedText,
        'translatedText': translatedText,
        'replyAudioPath': replyAudioPath,
        'durationMs': durationMs,
        'timestamp': timestamp.toIso8601String(),
        'errorMessage': errorMessage,
      };

  factory VoiceMessage.fromJson(Map<String, dynamic> json) => VoiceMessage(
        id: json['id'] as String,
        filePath: json['filePath'] as String,
        originalFilename: json['originalFilename'] as String?,
        sourceApp: json['sourceApp'] as String?,
        type: VoiceMessageType.values.byName(json['type'] as String),
        sourceLanguage: json['sourceLanguage'] as String,
        targetLanguage: json['targetLanguage'] as String,
        status: VoiceMessageStatus.values.byName(json['status'] as String),
        transcribedText: json['transcribedText'] as String?,
        translatedText: json['translatedText'] as String?,
        replyAudioPath: json['replyAudioPath'] as String?,
        durationMs: json['durationMs'] as int?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        errorMessage: json['errorMessage'] as String?,
      );
}
