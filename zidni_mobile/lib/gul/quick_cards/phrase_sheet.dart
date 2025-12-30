/// Phrase Sheet Bottom Sheet Widget
/// Gate QT-2: Service Cards + Phrase Sheet (Arabic-first)
///
/// Displays a list of phrases for a service with Speak and Copy buttons.
/// Arabic is shown big, target language below.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'phrase_pack_model.dart';

/// Shows the phrase sheet bottom sheet for a service
Future<void> showPhraseSheet({
  required BuildContext context,
  required ServiceType service,
  required String targetLangCode,
  required Future<void> Function(String text, String langCode) onSpeak,
}) async {
  // Load phrases from JSON
  final phrases = await _loadPhrases(service);
  
  if (!context.mounted) return;
  
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PhraseSheetContent(
      service: service,
      phrases: phrases,
      targetLangCode: targetLangCode,
      onSpeak: onSpeak,
    ),
  );
}

/// Load phrases for a service from the JSON asset
Future<List<Phrase>> _loadPhrases(ServiceType service) async {
  try {
    final jsonString = await rootBundle.loadString(
      'assets/phrases/phrase_packs_v1.json',
    );
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final packs = data['packs'] as List;
    
    for (final packJson in packs) {
      final pack = PhrasePack.fromJson(packJson as Map<String, dynamic>);
      if (pack.service == service) {
        return pack.phrases;
      }
    }
  } catch (e) {
    debugPrint('Error loading phrases: $e');
  }
  return [];
}

/// The content of the phrase sheet
class _PhraseSheetContent extends StatelessWidget {
  final ServiceType service;
  final List<Phrase> phrases;
  final String targetLangCode;
  final Future<void> Function(String text, String langCode) onSpeak;

  const _PhraseSheetContent({
    required this.service,
    required this.phrases,
    required this.targetLangCode,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          _buildHeader(context),
          // Divider
          const Divider(height: 1),
          // Phrase list
          Flexible(
            child: phrases.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: phrases.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) => _PhraseItem(
                      phrase: phrases[index],
                      targetLangCode: targetLangCode,
                      serviceColor: service.color,
                      onSpeak: onSpeak,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            service.icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 8),
          Text(
            service.arabicLabel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: service.color,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }
}

/// Individual phrase item with Speak and Copy buttons
class _PhraseItem extends StatelessWidget {
  final Phrase phrase;
  final String targetLangCode;
  final Color serviceColor;
  final Future<void> Function(String text, String langCode) onSpeak;

  const _PhraseItem({
    required this.phrase,
    required this.targetLangCode,
    required this.serviceColor,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final translation = phrase.getTranslation(targetLangCode);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Arabic text (big)
          Text(
            phrase.arabic,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 4),
          // Target language text (smaller, grey)
          Text(
            translation,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.3,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Copy Arabic
              _ActionButton(
                icon: Icons.copy,
                label: 'نسخ',
                color: Colors.grey[600]!,
                onTap: () => _copyToClipboard(context, phrase.arabic),
              ),
              const SizedBox(width: 8),
              // Speak Arabic
              _ActionButton(
                icon: Icons.volume_up,
                label: 'عربي',
                color: Colors.blue,
                onTap: () => onSpeak(phrase.arabic, 'ar-SA'),
              ),
              const SizedBox(width: 8),
              // Speak Target
              _ActionButton(
                icon: Icons.volume_up,
                label: _getTargetLabel(targetLangCode),
                color: serviceColor,
                onTap: () => onSpeak(translation, _getTtsLocale(targetLangCode)),
              ),
              const SizedBox(width: 8),
              // Copy Target
              _ActionButton(
                icon: Icons.copy,
                label: _getTargetLabel(targetLangCode),
                color: serviceColor.withOpacity(0.7),
                onTap: () => _copyToClipboard(context, translation),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ', textDirection: TextDirection.rtl),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _getTargetLabel(String langCode) {
    switch (langCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'EN';
      case 'tr':
        return 'TR';
      case 'es':
        return 'ES';
      default:
        return langCode.toUpperCase();
    }
  }

  String _getTtsLocale(String langCode) {
    switch (langCode) {
      case 'zh':
        return 'zh-CN';
      case 'en':
        return 'en-US';
      case 'tr':
        return 'tr-TR';
      case 'es':
        return 'es-ES';
      default:
        return langCode;
    }
  }
}

/// Small action button for Speak/Copy
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
