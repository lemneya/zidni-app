/// Share Intent Handler for Call Companion Mode
/// Handles incoming shared audio files from WeChat, WhatsApp, etc.

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../models/call_companion/voice_message.dart';

/// Supported audio formats for voice messages
const supportedAudioFormats = [
  'm4a',
  'aac',
  'wav',
  'mp3',
  'ogg',
  'opus',
  'amr',
];

/// Result of handling a share intent
class ShareIntentResult {
  /// Whether the intent was handled successfully
  final bool success;

  /// The voice message created from the shared file
  final VoiceMessage? voiceMessage;

  /// Error message if handling failed
  final String? error;

  ShareIntentResult({
    required this.success,
    this.voiceMessage,
    this.error,
  });

  factory ShareIntentResult.success(VoiceMessage message) {
    return ShareIntentResult(success: true, voiceMessage: message);
  }

  factory ShareIntentResult.failure(String error) {
    return ShareIntentResult(success: false, error: error);
  }
}

/// Callback for when a voice message is received
typedef VoiceMessageReceivedCallback = void Function(VoiceMessage message);

/// Handler for share intents containing audio files
class ShareIntentHandler {
  static ShareIntentHandler? _instance;

  /// Singleton instance
  static ShareIntentHandler get instance {
    _instance ??= ShareIntentHandler._();
    return _instance!;
  }

  ShareIntentHandler._();

  /// Callback when a voice message is received
  VoiceMessageReceivedCallback? onVoiceMessageReceived;

  /// Stream controller for incoming voice messages
  final _voiceMessageController = StreamController<VoiceMessage>.broadcast();

  /// Stream of incoming voice messages
  Stream<VoiceMessage> get voiceMessageStream => _voiceMessageController.stream;

  /// Message counter for unique IDs
  int _messageCounter = 0;

  /// Initialize the handler and set up listeners
  Future<void> initialize() async {
    // TODO: Set up file_share_intent listeners
    // ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> files) {
    //   for (final file in files) {
    //     _handleSharedFile(file.path, file.type);
    //   }
    // });
    //
    // // Handle initial intent (app opened via share)
    // final initialMedia = await ReceiveSharingIntent.getInitialMedia();
    // for (final file in initialMedia) {
    //   _handleSharedFile(file.path, file.type);
    // }
  }

  /// Handle a shared file
  Future<ShareIntentResult> handleSharedFile({
    required String filePath,
    String? mimeType,
    String? sourceApp,
  }) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        return ShareIntentResult.failure('الملف غير موجود');
      }

      // Get file extension
      final extension = filePath.split('.').last.toLowerCase();

      // Check if format is supported
      if (!supportedAudioFormats.contains(extension)) {
        return ShareIntentResult.failure(
          'صيغة الملف غير مدعومة ($extension)\n'
          'الصيغ المدعومة: ${supportedAudioFormats.join(', ')}',
        );
      }

      // Copy file to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = 'voice_message_$timestamp.$extension';
      final newPath = '${appDir.path}/voice_messages/$newFileName';

      // Ensure directory exists
      await Directory('${appDir.path}/voice_messages').create(recursive: true);

      // Copy file
      await file.copy(newPath);

      // Create voice message
      final voiceMessage = VoiceMessage.receivedChinese(
        id: 'vm_${++_messageCounter}',
        filePath: newPath,
        originalFilename: filePath.split('/').last,
        sourceApp: sourceApp ?? _detectSourceApp(filePath),
      );

      // Notify listeners
      _voiceMessageController.add(voiceMessage);
      onVoiceMessageReceived?.call(voiceMessage);

      return ShareIntentResult.success(voiceMessage);
    } catch (e) {
      return ShareIntentResult.failure('فشل في معالجة الملف: $e');
    }
  }

  /// Detect source app from file path
  String? _detectSourceApp(String filePath) {
    final lowerPath = filePath.toLowerCase();
    if (lowerPath.contains('wechat') || lowerPath.contains('tencent')) {
      return 'WeChat';
    } else if (lowerPath.contains('whatsapp')) {
      return 'WhatsApp';
    } else if (lowerPath.contains('telegram')) {
      return 'Telegram';
    }
    return null;
  }

  /// Check if a file format is supported
  bool isFormatSupported(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return supportedAudioFormats.contains(extension);
  }

  /// Get list of supported formats as display string
  String get supportedFormatsDisplay => supportedAudioFormats.join(', ');

  /// Convert audio file to WAV format for processing
  Future<String> convertToWav(String inputPath) async {
    final extension = inputPath.split('.').last.toLowerCase();

    // If already WAV, return as-is
    if (extension == 'wav') {
      return inputPath;
    }

    // TODO: Use ffmpeg_kit to convert
    // final outputPath = inputPath.replaceAll('.$extension', '_converted.wav');
    // await FFmpegKit.execute('-i $inputPath -ar 16000 -ac 1 $outputPath');
    // return outputPath;

    // Placeholder: return original path
    return inputPath;
  }

  /// Clean up old voice message files
  Future<void> cleanupOldFiles({int maxAgeDays = 7}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final voiceMessagesDir = Directory('${appDir.path}/voice_messages');

      if (!await voiceMessagesDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeDays));

      await for (final entity in voiceMessagesDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Dispose resources
  void dispose() {
    _voiceMessageController.close();
  }
}
