import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/services/eyes_history_service.dart';

/// Product Insight Card - Displays OCR results with actions
/// Gate EYES-1: Product Insight Card with Copy, Save, Search
class ProductInsightCard extends StatefulWidget {
  final EyesScanResult result;
  final String? imagePath;
  final VoidCallback onRetake;
  final Function(EyesScanResult) onSaveComplete;

  const ProductInsightCard({
    super.key,
    required this.result,
    this.imagePath,
    required this.onRetake,
    required this.onSaveComplete,
  });

  @override
  State<ProductInsightCard> createState() => _ProductInsightCardState();
}

class _ProductInsightCardState extends State<ProductInsightCard> {
  bool _isSaving = false;
  bool _isSaved = false;

  String _getLanguageLabel(String? langCode) {
    switch (langCode) {
      case 'zh':
        return '🇨🇳 صينية';
      case 'ar':
        return '🇸🇦 عربية';
      case 'en':
        return '🇺🇸 إنجليزية';
      default:
        return '❓ غير محدد';
    }
  }

  Future<void> _copyText(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم نسخ $label'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _saveToHistory() async {
    if (_isSaving || _isSaved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final savedResult = await EyesHistoryService.saveToHistory(widget.result);
      setState(() {
        _isSaved = true;
        _isSaving = false;
      });
      widget.onSaveComplete(savedResult);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحفظ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSearchPlaceholder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A4E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'البحث عن المنتج',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'قريباً: البحث في 1688 و Alibaba',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              // Placeholder search results
              _buildPlaceholderSearchItem('1688.com', 'منصة الجملة الصينية'),
              _buildPlaceholderSearchItem('Alibaba.com', 'التجارة الدولية'),
              _buildPlaceholderSearchItem('أسواق قوانغتشو', 'الأسواق المحلية'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderSearchItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.3),
            size: 16,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image thumbnail
          if (widget.imagePath != null) _buildImageThumbnail(),

          const SizedBox(height: 16),

          // Product name guess card
          _buildProductNameCard(),

          const SizedBox(height: 12),

          // Detected language
          _buildLanguageChip(),

          const SizedBox(height: 12),

          // Extracted fields
          if (widget.result.extractedFields.isNotEmpty) ...[
            _buildExtractedFieldsCard(),
            const SizedBox(height: 12),
          ],

          // Raw OCR text
          _buildRawTextCard(),

          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(widget.imagePath!),
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'الصورة الملتقطة',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductNameCard() {
    final productName = widget.result.productNameGuess ?? 'لم يتم التعرف على اسم المنتج';
    final hasName = widget.result.productNameGuess != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasName ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasName ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasName ? Icons.check_circle : Icons.help_outline,
                color: hasName ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'اسم المنتج المقترح',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            productName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasName) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _copyText(productName, 'اسم المنتج'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy, color: Colors.blue.withOpacity(0.7), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'نسخ',
                    style: TextStyle(
                      color: Colors.blue.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          const Text(
            'اللغة المكتشفة:',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            _getLanguageLabel(widget.result.detectedLanguage),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text(
                'معلومات مستخرجة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.result.extractedFields.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _getFieldLabel(entry.key),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _copyText(entry.value, _getFieldLabel(entry.key)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Icon(Icons.copy, color: Colors.white.withOpacity(0.3), size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getFieldLabel(String key) {
    switch (key) {
      case 'brand':
        return 'العلامة:';
      case 'model':
        return 'الموديل:';
      case 'size':
        return 'المقاس:';
      case 'material':
        return 'المادة:';
      case 'sku':
        return 'الرمز:';
      default:
        return '$key:';
    }
  }

  Widget _buildRawTextCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.text_fields, color: Colors.white54, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'النص الكامل',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _copyText(widget.result.rawText, 'النص الكامل'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, color: Colors.blue, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'نسخ الكل',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Text(
                widget.result.rawText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action: Save to History
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving || _isSaved ? null : _saveToHistory,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_isSaved ? Icons.check : Icons.save),
            label: Text(_isSaved ? 'تم الحفظ' : 'حفظ في السجل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaved ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Secondary actions row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyText(widget.result.rawText, 'النص'),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('نسخ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showSearchPlaceholder,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('بحث'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
