/// Voice Message Screen for Call Companion Mode
/// UI for translating voice messages received via share intent
///
/// Features:
/// - Display received voice message
/// - Transcribe & Translate button
/// - Show Arabic translation
/// - Record Arabic reply
/// - Generate Chinese voice file
/// - Share back to WeChat/WhatsApp

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/call_companion/voice_message.dart';
import '../../services/call_companion/whisper_stt_service.dart';
import '../../services/call_companion/mlkit_translation_service.dart';
import '../../services/call_companion/tts_to_file_service.dart';
import '../../services/call_companion/share_intent_handler.dart';
import '../../widgets/call_companion/voice_message_card.dart';

/// Screen for voice message translation
class VoiceMessageScreen extends StatefulWidget {
  /// Initial voice message to display (from share intent)
  final VoiceMessage? initialMessage;

  const VoiceMessageScreen({
    super.key,
    this.initialMessage,
  });

  @override
  State<VoiceMessageScreen> createState() => _VoiceMessageScreenState();
}

class _VoiceMessageScreenState extends State<VoiceMessageScreen> {
  final _sttService = WhisperSttService.instance;
  final _translationService = MlkitTranslationService.instance;
  final _ttsService = TtsToFileService.instance;
  final _shareHandler = ShareIntentHandler.instance;

  /// Current voice message being processed
  VoiceMessage? _currentMessage;

  /// List of processed voice messages
  final List<VoiceMessage> _messages = [];

  /// Whether currently recording a reply
  bool _isRecordingReply = false;

  /// Reply recording path
  String? _replyRecordingPath;

  /// Reply voice message
  VoiceMessage? _replyMessage;

  @override
  void initState() {
    super.initState();

    // Set initial message if provided
    if (widget.initialMessage != null) {
      _currentMessage = widget.initialMessage;
      _messages.add(widget.initialMessage!);
    }

    // Listen for new voice messages
    _shareHandler.voiceMessageStream.listen((message) {
      setState(() {
        _currentMessage = message;
        _messages.insert(0, message);
      });
    });
  }

  /// Process the current voice message (transcribe & translate)
  Future<void> _processMessage() async {
    if (_currentMessage == null) return;

    final message = _currentMessage!;

    try {
      // Update status to transcribing
      setState(() {
        message.startTranscribing();
      });

      // Convert to WAV if needed
      final wavPath = await _shareHandler.convertToWav(message.filePath);

      // Transcribe Chinese audio
      final transcription = await _sttService.transcribe(
        audioPath: wavPath,
        language: 'zh',
      );

      setState(() {
        message.setTranscription(transcription.text);
      });

      // Translate to Arabic
      final translation = await _translationService.translateChineseToArabic(
        transcription.text,
      );

      setState(() {
        message.setTranslation(translation);
      });
    } catch (e) {
      setState(() {
        message.markFailed(e.toString());
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في المعالجة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Start recording Arabic reply
  Future<void> _startRecordingReply() async {
    setState(() {
      _isRecordingReply = true;
    });

    // TODO: Start recording using record package
    // _replyRecordingPath = await Record().start(...);
  }

  /// Stop recording and process reply
  Future<void> _stopRecordingReply() async {
    if (!_isRecordingReply) return;

    setState(() {
      _isRecordingReply = false;
    });

    // TODO: Stop recording
    // await Record().stop();

    if (_replyRecordingPath == null) return;

    try {
      // Create reply voice message
      final reply = VoiceMessage.arabicReply(
        id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
        filePath: _replyRecordingPath!,
      );

      setState(() {
        _replyMessage = reply;
        reply.startTranscribing();
      });

      // Transcribe Arabic
      final transcription = await _sttService.transcribe(
        audioPath: _replyRecordingPath!,
        language: 'ar',
      );

      setState(() {
        reply.setTranscription(transcription.text);
      });

      // Translate to Chinese
      final translation = await _translationService.translateArabicToChinese(
        transcription.text,
      );

      setState(() {
        reply.setTranslation(translation);
      });

      // Generate Chinese voice file
      final ttsResult = await _ttsService.synthesizeChineseToFile(translation);

      setState(() {
        reply.setReplyAudio(ttsResult.filePath);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في معالجة الرد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Share the Chinese voice reply
  Future<void> _shareReply() async {
    if (_replyMessage?.replyAudioPath == null) return;

    await Share.shareXFiles(
      [XFile(_replyMessage!.replyAudioPath!)],
      text: _replyMessage!.translatedText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'ترجمة الرسائل الصوتية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Instructions
            _buildInstructions(),

            // Messages list
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return VoiceMessageCard(
                          message: message,
                          onProcess: message == _currentMessage &&
                                  message.status == VoiceMessageStatus.pending
                              ? _processMessage
                              : null,
                          isSelected: message == _currentMessage,
                        );
                      },
                    ),
            ),

            // Reply section
            if (_currentMessage?.isCompleted == true) _buildReplySection(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'كيفية الاستخدام',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. شارك رسالة صوتية من WeChat أو WhatsApp إلى زدني\n'
            '2. اضغط "ترجم" للحصول على الترجمة العربية\n'
            '3. سجل ردك بالعربية\n'
            '4. شارك الرد الصيني مع المورد',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد رسائل صوتية',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'شارك رسالة صوتية من تطبيق آخر للبدء',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'سجل ردك',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Reply status
          if (_replyMessage != null) ...[
            if (_replyMessage!.transcribedText != null)
              _buildReplyText('النص العربي:', _replyMessage!.transcribedText!),
            if (_replyMessage!.translatedText != null)
              _buildReplyText('الترجمة الصينية:', _replyMessage!.translatedText!),
          ],

          const SizedBox(height: 12),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Record button
              ElevatedButton.icon(
                onPressed: _isRecordingReply ? _stopRecordingReply : _startRecordingReply,
                icon: Icon(_isRecordingReply ? Icons.stop : Icons.mic),
                label: Text(_isRecordingReply ? 'إيقاف' : 'تسجيل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecordingReply ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),

              // Share button
              if (_replyMessage?.replyAudioPath != null)
                ElevatedButton.icon(
                  onPressed: _shareReply,
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyText(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
