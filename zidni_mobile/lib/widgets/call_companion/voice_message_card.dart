/// Voice Message Card Widget for Call Companion Mode
/// Displays a voice message with transcription and translation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/call_companion/voice_message.dart';

/// Card for displaying a voice message
class VoiceMessageCard extends StatelessWidget {
  /// The voice message to display
  final VoiceMessage message;

  /// Callback to process the message
  final VoidCallback? onProcess;

  /// Whether this card is selected
  final bool isSelected;

  const VoiceMessageCard({
    super.key,
    required this.message,
    this.onProcess,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Colors.blue.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Audio player (placeholder)
          _buildAudioPlayer(),

          // Status / Processing
          if (message.status == VoiceMessageStatus.transcribing ||
              message.status == VoiceMessageStatus.translating)
            _buildProcessingIndicator(),

          // Transcription
          if (message.transcribedText != null) _buildTranscription(),

          // Translation
          if (message.translatedText != null) _buildTranslation(),

          // Error
          if (message.status == VoiceMessageStatus.failed) _buildError(),

          // Action button
          if (message.status == VoiceMessageStatus.pending && onProcess != null)
            _buildProcessButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(11),
          topRight: Radius.circular(11),
        ),
      ),
      child: Row(
        children: [
          // Source app icon
          Icon(
            _getSourceAppIcon(),
            color: Colors.white.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 8),

          // Source info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.sourceApp ?? 'رسالة صوتية',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (message.originalFilename != null)
                  Text(
                    message.originalFilename!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Timestamp
          Text(
            _formatTime(message.receivedAt),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Play button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.2),
            ),
            child: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.blue),
              onPressed: () {
                // TODO: Play audio
              },
              iconSize: 24,
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 12),

          // Waveform placeholder
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomPaint(
                painter: _WaveformPainter(),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Duration
          Text(
            message.durationDisplay,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    final statusText = message.status == VoiceMessageStatus.transcribing
        ? 'يحول الكلام إلى نص...'
        : 'يترجم...';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'النص الصيني:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.copy,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: message.transcribedText!),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message.transcribedText!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildTranslation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'الترجمة العربية:',
                style: TextStyle(
                  color: Colors.green.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.green, size: 16),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: message.translatedText!),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.translatedText!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.errorMessage ?? 'حدث خطأ',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onProcess,
          icon: const Icon(Icons.translate),
          label: const Text('ترجم'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  IconData _getSourceAppIcon() {
    switch (message.sourceApp?.toLowerCase()) {
      case 'wechat':
        return Icons.chat_bubble;
      case 'whatsapp':
        return Icons.chat;
      case 'telegram':
        return Icons.send;
      default:
        return Icons.audio_file;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Simple waveform painter
class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barCount = 30;
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      // Generate pseudo-random heights
      final height = (size.height * 0.3) +
          (size.height * 0.7 * ((i * 7 + 3) % 10) / 10);
      final x = i * barWidth + barWidth / 2;
      final y1 = (size.height - height) / 2;
      final y2 = y1 + height;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
