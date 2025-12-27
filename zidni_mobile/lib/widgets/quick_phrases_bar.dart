/// Quick Phrases Bar - Horizontal scrollable row of phrase pills
/// Each pill has Arabic label + speak/copy actions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../packs/quick_phrase_library.dart';
import '../screens/conversation/conversation_mode_screen.dart' show TargetLang, TargetLangExtension;
import '../services/tts_service.dart';

class QuickPhrasesBar extends StatelessWidget {
  final List<QuickPhrase> phrases;
  final TargetLang targetLang;
  final TtsService ttsService;
  final bool isDisabled;

  const QuickPhrasesBar({
    super.key,
    required this.phrases,
    required this.targetLang,
    required this.ttsService,
    this.isDisabled = false,
  });

  void _speakPhrase(BuildContext context, QuickPhrase phrase) {
    if (isDisabled) return;
    
    final text = phrase.getTranslation(targetLang);
    final locale = targetLang.ttsLocale;
    ttsService.speak(text, locale);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم تشغيل العبارة'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _copyPhrase(BuildContext context, QuickPhrase phrase) {
    if (isDisabled) return;
    
    final text = phrase.getTranslation(targetLang);
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم النسخ'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'عبارات سريعة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'اضغط 🔊 للنطق أو 📋 للنسخ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Horizontal scrollable pills
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: phrases.length,
              itemBuilder: (context, index) {
                final phrase = phrases[index];
                return _buildPhrasePill(context, phrase);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhrasePill(BuildContext context, QuickPhrase phrase) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: isDisabled ? null : () => _speakPhrase(context, phrase),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Arabic label
                Text(
                  phrase.arabicLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                
                // Speak button
                _buildActionButton(
                  context,
                  icon: Icons.volume_up,
                  color: Colors.green.shade600,
                  onTap: () => _speakPhrase(context, phrase),
                ),
                const SizedBox(width: 4),
                
                // Copy button
                _buildActionButton(
                  context,
                  icon: Icons.copy,
                  color: Colors.blue.shade600,
                  onTap: () => _copyPhrase(context, phrase),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDisabled ? Colors.grey : color,
        ),
      ),
    );
  }
}
