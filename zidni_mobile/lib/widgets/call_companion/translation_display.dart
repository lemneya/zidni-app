/// Translation Display Widget for Call Companion Mode
/// Shows the history of translations during a call

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/call_companion/call_companion_screen.dart';
import '../../services/call_companion/audio_pipeline_service.dart';

/// Widget to display translation history
class TranslationDisplay extends StatelessWidget {
  /// List of translation entries
  final List<TranslationEntry> translations;

  /// Whether currently processing
  final bool isProcessing;

  /// Current processing state
  final PipelineState processingState;

  const TranslationDisplay({
    super.key,
    required this.translations,
    required this.isProcessing,
    required this.processingState,
  });

  @override
  Widget build(BuildContext context) {
    if (translations.isEmpty && !isProcessing) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: translations.length + (isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        // Show processing indicator at top
        if (isProcessing && index == 0) {
          return _buildProcessingIndicator();
        }

        // Adjust index for translations
        final translationIndex = isProcessing ? index - 1 : index;
        final entry = translations[translationIndex];

        return _TranslationCard(entry: entry);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.translate,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'جاهز للترجمة',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على "استمع" أو "تحدث" للبدء',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    String statusText;
    switch (processingState) {
      case PipelineState.recording:
        statusText = 'يسجل...';
        break;
      case PipelineState.transcribing:
        statusText = 'يحول الكلام إلى نص...';
        break;
      case PipelineState.translating:
        statusText = 'يترجم...';
        break;
      case PipelineState.speaking:
        statusText = 'يتحدث...';
        break;
      default:
        statusText = 'يعالج...';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            statusText,
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

/// Card for a single translation entry
class _TranslationCard extends StatelessWidget {
  final TranslationEntry entry;

  const _TranslationCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isChineseSource = entry.isChineseSource;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChineseSource
              ? Colors.green.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isChineseSource
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isChineseSource ? Icons.hearing : Icons.mic,
                  color: isChineseSource ? Colors.green : Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isChineseSource ? 'صيني → عربي' : 'عربي → صيني',
                  style: TextStyle(
                    color: isChineseSource ? Colors.green : Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(entry.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Source text
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChineseSource ? 'النص الصيني:' : 'النص العربي:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.sourceText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textDirection:
                      isChineseSource ? TextDirection.ltr : TextDirection.rtl,
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),

          // Translated text
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChineseSource ? 'الترجمة العربية:' : 'الترجمة الصينية:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.translatedText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection:
                      isChineseSource ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Copy source
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    color: Colors.white.withOpacity(0.5),
                    size: 18,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: entry.sourceText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ النص الأصلي'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'نسخ النص الأصلي',
                ),

                // Copy translation
                IconButton(
                  icon: Icon(
                    Icons.copy_all,
                    color: Colors.white.withOpacity(0.5),
                    size: 18,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: entry.translatedText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الترجمة'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'نسخ الترجمة',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
