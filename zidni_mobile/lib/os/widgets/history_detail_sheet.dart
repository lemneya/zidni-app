import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zidni_mobile/os/models/unified_history_item.dart';

/// History Detail Sheet Widget
/// Gate OS-1: GUL↔Eyes Bridge + Unified History
///
/// Shows full details of a history item (read-only)

class HistoryDetailSheet extends StatelessWidget {
  final UnifiedHistoryItem item;
  final ScrollController scrollController;

  const HistoryDetailSheet({
    super.key,
    required this.item,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A4E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 20),
                
                // Type-specific content
                _buildTypeContent(context),
                
                // Metadata
                if (item.metadata.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildMetadataSection(context),
                ],
                
                // Timestamp
                const SizedBox(height: 20),
                _buildTimestamp(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Type icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        
        // Title and type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.type.arabicName,
                style: TextStyle(
                  color: _getTypeColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Close button
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildTypeContent(BuildContext context) {
    switch (item.type) {
      case HistoryItemType.translation:
        return _buildTranslationContent(context);
      case HistoryItemType.eyesScan:
        return _buildEyesScanContent(context);
      case HistoryItemType.eyesSearch:
        return _buildEyesSearchContent(context);
      case HistoryItemType.deal:
        return _buildDealContent(context);
    }
  }

  Widget _buildTranslationContent(BuildContext context) {
    final transcript = item.metadata['transcript'] as String? ?? '';
    final translation = item.metadata['translation'] as String? ?? '';
    final fromLang = item.metadata['fromLang'] as String? ?? '';
    final toLang = item.metadata['toLang'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextBlock(
          context,
          title: 'النص الأصلي ($fromLang)',
          content: transcript,
          icon: Icons.record_voice_over,
        ),
        const SizedBox(height: 16),
        _buildTextBlock(
          context,
          title: 'الترجمة ($toLang)',
          content: translation,
          icon: Icons.translate,
        ),
      ],
    );
  }

  Widget _buildEyesScanContent(BuildContext context) {
    final rawText = item.metadata['rawText'] as String? ?? '';
    final extractedFields = item.metadata['extractedFields'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextBlock(
          context,
          title: 'النص المستخرج',
          content: rawText,
          icon: Icons.text_fields,
        ),
        
        if (extractedFields.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildFieldsGrid(extractedFields),
        ],
      ],
    );
  }

  Widget _buildEyesSearchContent(BuildContext context) {
    final query = item.metadata['query'] as String? ?? '';
    final platform = item.metadata['platform'] as String? ?? '';
    final contextChips = (item.metadata['contextChips'] as List<dynamic>?)
        ?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoRow('استعلام البحث', query),
        const SizedBox(height: 12),
        _buildInfoRow('المنصة', platform),
        
        if (contextChips.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'الفلاتر المستخدمة',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contextChips.map((chip) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                chip,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDealContent(BuildContext context) {
    final platform = item.metadata['platform'] as String? ?? '';
    final status = item.metadata['status'] as String? ?? '';
    final contextChips = (item.metadata['contextChips'] as List<dynamic>?)
        ?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoRow('المنصة', platform),
        const SizedBox(height: 12),
        _buildInfoRow('الحالة', status),
        
        if (contextChips.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'الفلاتر',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contextChips.map((chip) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                chip,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTextBlock(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white54, size: 18),
                  onPressed: () => _copyToClipboard(context, content),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.5,
              ),
              textDirection: _getTextDirection(content),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldsGrid(Map<String, dynamic> fields) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الحقول المستخرجة',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...fields.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildInfoRow(entry.key, entry.value.toString()),
          )),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.3), size: 16),
              const SizedBox(width: 8),
              Text(
                'معلومات إضافية',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${item.id}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Center(
      child: Text(
        '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year} ${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 12,
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getTypeColor() {
    switch (item.type) {
      case HistoryItemType.translation:
        return Colors.blue;
      case HistoryItemType.eyesScan:
        return Colors.purple;
      case HistoryItemType.eyesSearch:
        return Colors.orange;
      case HistoryItemType.deal:
        return Colors.green;
    }
  }

  IconData _getTypeIcon() {
    switch (item.type) {
      case HistoryItemType.translation:
        return Icons.mic;
      case HistoryItemType.eyesScan:
        return Icons.document_scanner;
      case HistoryItemType.eyesSearch:
        return Icons.search;
      case HistoryItemType.deal:
        return Icons.handshake;
    }
  }

  TextDirection _getTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    final firstChar = text.codeUnitAt(0);
    if (firstChar >= 0x0600 && firstChar <= 0x06FF) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
}
